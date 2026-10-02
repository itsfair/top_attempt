import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_core_client/serverpod_auth_core_client.dart';
import 'package:serverpod_auth_idp_server/core.dart'
    hide AuthSuccess, AuthStrategy;
import 'package:serverpod_auth_idp_server/providers/email.dart'
    hide AuthSuccess;
import 'package:top_attempt_global_client/top_attempt_client.dart' as gc;

import '../generated/protocol.dart';

/// Scope of the local site admin on this local instance (created at setup).
const String kLocalAdminScope = 'local-admin';

/// Token-level scope of the device session the global backend issued at
/// enrollment (informational here; the local client presents the plain SAS
/// session key).
const String kSiteDeviceScope = 'site-device';

/// Storage implementation for the global client's auth session manager.
/// The device credential is the non-rotating SAS session key stored in the
/// `site_connections` row (written once at enrollment; nothing rotates).
class SiteConnectionAuthStorage implements ClientAuthSuccessStorage {
  AuthSuccess? _cached;

  Future<SiteConnection?> _loadRow() {
    return Serverpod.instance.withSession(
      (session) => SiteConnection.db.findFirstRow(session),
    );
  }

  @override
  Future<AuthSuccess?> get() async {
    final cached = _cached;
    if (cached != null) return cached;

    final row = await _loadRow();
    if (row == null || row.deviceSessionKey == null) return null;

    final auth = AuthSuccess(
      authStrategy: AuthStrategy.session.name,
      token: row.deviceSessionKey!,
      authUserId: row.adminAuthUserId!,
      scopeNames: {kSiteDeviceScope},
    );
    _cached = auth;
    return auth;
  }

  @override
  Future<void> set(final AuthSuccess? data) async {
    // SAS session keys do not rotate: the enrollment already persisted the
    // key in the row, so `set` only refreshes the cache.
    _cached = data;
  }

  void clearCache() => _cached = null;
}

/// In-process manager of the device connection between this local instance
/// and the site's global backend.
///
/// - Owns the generated global `Client` with a `ClientAuthSessionManager`
///   wired to [SiteConnectionAuthStorage] (non-rotating SAS session key).
/// - Holds the long-lived method stream to the global
///   `SiteConnectionEndpoint.connect` open and pings every [_pingInterval].
/// - Reconnects with backoff; flips to `needsReSetup` when the credential is
///   no longer accepted (the local admin then re-runs setup with their
///   global credentials — no global-admin involvement needed).
class GlobalSiteConnection {
  GlobalSiteConnection._();

  static final GlobalSiteConnection instance = GlobalSiteConnection._();

  static const Duration _pingInterval = Duration(seconds: 30);
  static const Duration _initialRetryDelay = Duration(seconds: 5);
  static const Duration _maxRetryDelay = Duration(seconds: 60);

  /// True once this instance is enrolled at a global instance
  /// (`state != noneSetup`). The frontend reads this via
  /// `siteSetup.connectionStatus` polling and drives its redirects.
  bool get isEnrolled => _state != SiteConnectionState.noneSetup;

  // -- State (surfaced via siteSetup.connectionStatus)

  SiteConnectionState _state = SiteConnectionState.noneSetup;
  String? _lastError;
  DateTime? _lastConnectedAt;
  String? _siteName;

  SiteConnectionInfo status() => SiteConnectionInfo(
    state: _state,
    siteName: _siteName,
    lastError: _lastError,
    lastConnectedAt: _lastConnectedAt,
  );

  void _setState(
    final SiteConnectionState state, {
    final String? lastError,
  }) {
    _state = state;
    if (state == SiteConnectionState.connected) {
      _lastError = null;
    } else if (lastError != null) {
      _lastError = lastError;
    }
  }

  // -- Enrollment application (from siteSetup.enterSetup)

  /// Applies a successful enrollment (fresh setup) or recovery to the local
  /// configuration, processes the admin transfer (local memberships row +
  /// profile_details + local `local-admin` login with the *same password*
  /// the admin just used for the global verification), and starts the
  /// connection worker.
  Future<void> applySetup(
    final Session session, {
    required final String globalApiUrl,
    required final gc.SiteTransferInfo transfer,
    required final String adminPassword,
  }) async {
    if (await _upsertConnectionRow(session, transfer, globalApiUrl) != null) {
      await _processTransfer(session, transfer, adminPassword);
    }

    _siteName = transfer.siteName;
    _setState(SiteConnectionState.connecting);
    unawaited(_connectWithRetry());
  }

  /// Creates or refreshes the single `site_connections` row: connection
  /// config + full site snapshot from the transfer (person data lives in
  /// profile_details via the memberships table, only the identity pointer
  /// is stored here).
  Future<SiteConnection?> _upsertConnectionRow(
    final Session session,
    final gc.SiteTransferInfo transfer,
    final String globalApiUrl,
  ) async {
    var row = await SiteConnection.db.findFirstRow(session);
    if (row == null) {
      row = await SiteConnection.db.insertRow(
        session,
        SiteConnection(
          globalApiUrl: globalApiUrl,
          siteId: transfer.siteId,
          siteName: transfer.siteName,
          siteStreet: transfer.siteStreet,
          siteZipCode: transfer.siteZipCode,
          siteCity: transfer.siteCity,
          siteCountry: transfer.siteCountry,
          siteCompanyEmail: transfer.siteCompanyEmail,
          adminAuthUserId: transfer.adminAuthUserId,
          deviceSessionKey: transfer.deviceSessionKey,
        ),
      );
    } else {
      await SiteConnection.db.updateRow(
        session,
        row.copyWith(
          globalApiUrl: globalApiUrl,
          siteId: transfer.siteId,
          siteName: transfer.siteName,
          siteStreet: transfer.siteStreet,
          siteZipCode: transfer.siteZipCode,
          siteCity: transfer.siteCity,
          siteCountry: transfer.siteCountry,
          siteCompanyEmail: transfer.siteCompanyEmail,
          adminAuthUserId: transfer.adminAuthUserId,
          deviceSessionKey: transfer.deviceSessionKey,
        ),
      );
    }
    return row;
  }

  /// Fresh-setup processing only (recovery keeps local data as-is):
  /// 1. fail-fast: image bytes are downloaded FIRST (server-to-server from
  ///    the global instance) — if this fails, nothing is created at all
  ///    (no half-created persons; see AGENTS.md).
  /// 2. one DB transaction: local AuthUser (`local-admin` scope) + email
  ///    login with the same password the admin just verified with + local
  ///    `member_profile` copy (globalAuthUserId noted, auth link set).
  /// 3. image upload into the local RustFS at the same deterministic path
  ///    (`member_images/<globalAuthUserId>.jpg`, overwrite semantics) and
  ///    `imageUrl` set on the profile copy.
  Future<void> _processTransfer(
    final Session session,
    final gc.SiteTransferInfo transfer,
    final String adminPassword,
  ) async {
    final existing = await MemberProfile.db.findFirstRow(
      session,
      where: (t) => t.globalAuthUserId.equals(transfer.adminAuthUserId),
    );
    if (existing != null) {
      return;
    }

    // -- Fail-fast image transfer (no local fallback).
    final imagePath = _imagePath(transfer.adminAuthUserId);
    final imageUrlText = transfer.adminImageUrl;
    ByteData? imageBytes;
    if (imageUrlText != null && imageUrlText.isNotEmpty) {
      imageBytes = await _downloadBytes(imageUrlText);
      if (imageBytes == null) {
        throw SiteSetupException(
          message:
              'Transfer des Profilbilds fehlgeschlagen — '
              'Einrichtung wird abgebrochen (bitte erneut versuchen).',
        );
      }
    }

    // -- One transaction for all person-related rows.
    await session.db.transaction((final transaction) async {
      final localAuthUser = await AuthServices.instance.authUsers.create(
        session,
        scopes: {const Scope(kLocalAdminScope)},
        transaction: transaction,
      );

      final adminEmail = transfer.adminEmail!;

      await AuthServices.getIdentityProvider<EmailIdp>().admin
          .createEmailAuthentication(
            session,
            authUserId: localAuthUser.id,
            email: adminEmail,
            password: adminPassword,
            transaction: transaction,
          );

      var memberProfile = await MemberProfile.db.insertRow(
        session,
        MemberProfile(
          authUserId: localAuthUser.id,
          globalAuthUserId: transfer.adminAuthUserId,
          email: adminEmail,
          firstName: transfer.adminFirstName,
          lastName: transfer.adminLastName,
          birthday: transfer.adminBirthday,
        ),
        transaction: transaction,
      );

      // image upload (storage is not transaction-aware; upload before the
      // rows are committed happens inside the transaction block, so a
      // failure rolls the rows back — a leftover object in the bucket is
      // acceptable and logged).
      if (imageBytes != null) {
        await session.storage.storeFile(
          storageId: 'public',
          path: imagePath,
          byteData: imageBytes,
        );
        final publicUrl = await session.storage.publicDownloadUrl(
          storageId: 'public',
          path: imagePath,
        );
        memberProfile = await MemberProfile.db.updateRow(
          session,
          memberProfile.copyWith(imageUrl: publicUrl.toString()),
          transaction: transaction,
        );
      }
    });
  }

  /// Deterministic image object path (parity: same value as the global
  /// instance).
  String _imagePath(final UuidValue globalAuthUserId) =>
      'member_images/$globalAuthUserId.jpg';

  /// Server-to-server download of an arbitrary URL.
  Future<ByteData?> _downloadBytes(final String url) async {
    final client = HttpClient();
    try {
      final request = await client.getUrl(Uri.parse(url));
      final response = await request.close();
      if (response.statusCode != HttpStatus.ok) {
        return null;
      }
      final builder = BytesBuilder(copy: false);
      await for (final chunk in response) {
        builder.add(chunk);
      }
      return ByteData.sublistView(builder.takeBytes());
    } finally {
      client.close(force: true);
    }
  }

  // -- Worker

  Timer? _retryTimer;
  StreamSubscription<gc.SiteEvent>? _streamSubscription;
  Timer? _pingTimer;
  StreamController<gc.SitePing>? _pingController;
  Duration _retryDelay = _initialRetryDelay;
  bool _connecting = false;

  Future<SiteConnection?> _loadRow() {
    return Serverpod.instance.withSession(
      (session) => SiteConnection.db.findFirstRow(session),
    );
  }

  /// Starts (or restarts after a setup) the connection loop when this
  /// instance is enrolled. Called at startup and after a setup.
  Future<void> start() async {
    final row = await _loadRow();
    if (row == null || row.deviceSessionKey == null) {
      _setState(SiteConnectionState.noneSetup);
      return;
    }
    _siteName = row.siteName;
    _setState(SiteConnectionState.connecting);
    unawaited(_connectWithRetry());
  }

  Future<void> _connectWithRetry() async {
    if (_connecting) return;
    _connecting = true;
    try {
      await _closeStreams();
      _setState(SiteConnectionState.connecting);

      final row = await _loadRow();
      if (row == null || row.deviceSessionKey == null) {
        _setState(SiteConnectionState.noneSetup);
        return;
      }

      final client = gc.Client(row.globalApiUrl);
      final storage = SiteConnectionAuthStorage();
      final sessionManager = ClientAuthSessionManager(storage: storage);
      client.authSessionManager = sessionManager;
      await sessionManager.updateSignedInUser(await storage.get());

      final controller = StreamController<gc.SitePing>();
      _pingController = controller;

      _pingTimer?.cancel();
      _pingTimer = Timer.periodic(_pingInterval, (_) {
        if (!controller.isClosed) {
          controller.add(
            gc.SitePing(
              sentAtMs: DateTime.now().millisecondsSinceEpoch,
            ),
          );
        }
      });

      final stream = client.siteConnection.connect(controller.stream);
      final subscription = stream.listen(
        (event) {
          _lastConnectedAt = DateTime.now();
          _retryDelay = _initialRetryDelay;
          if (_state != SiteConnectionState.connected) {
            _setState(SiteConnectionState.connected);
          }
        },
        onError: (Object error) => _handleStreamError(error),
        // Stream closed gracefully (identity change or server stop):
        // reconnect like any other failure.
        onDone: () => _scheduleRetry(),
      );
      _streamSubscription = subscription;
    } catch (error) {
      _handleStreamError(error);
    } finally {
      _connecting = false;
    }
  }

  void _handleStreamError(final Object error) {
    if (_isCredentialError(error)) {
      _setState(
        SiteConnectionState.needsReSetup,
        lastError:
            'Device credential no longer accepted — please re-run setup.',
      );
      unawaited(_closeStreams());
      return;
    }

    _scheduleRetry(error: error);
  }

  /// Schedules a reconnect with backoff, keeping `needsReSetup` sticky.
  void _scheduleRetry({final Object? error}) {
    _setState(
      _state == SiteConnectionState.needsReSetup
          ? SiteConnectionState.needsReSetup
          : SiteConnectionState.reconnecting,
      lastError: error?.toString(),
    );
    unawaited(_closeStreams());
    _retryTimer?.cancel();
    _retryTimer = Timer(_retryDelay, () => unawaited(_connectWithRetry()));
    _retryDelay = _retryDelay * 2;
    if (_retryDelay > _maxRetryDelay) {
      _retryDelay = _maxRetryDelay;
    }
  }

  bool _isCredentialError(final Object error) {
    final message = error.toString().toLowerCase();
    return message.contains('unauthorized') ||
        message.contains('insufficient') ||
        message.contains('nicht authentifiziert') ||
        message.contains('unbekannt oder widerrufen') ||
        message.contains('neu einrichten');
  }

  Future<void> _closeStreams() async {
    _pingTimer?.cancel();
    _pingTimer = null;
    final controller = _pingController;
    _pingController = null;
    if (controller != null && !controller.isClosed) {
      await controller.close();
    }
    final subscription = _streamSubscription;
    _streamSubscription = null;
    if (subscription != null) {
      await subscription.cancel();
    }
  }
}
