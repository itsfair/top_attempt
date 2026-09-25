import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_idp_server/core.dart';

import '../auth/scopes.dart';

/// Single point of access for the site device credential issuance:
/// constructs the [ServerSideSessions] config/instance once and makes it
/// available to `server.dart` (for auth service registration) and to the
/// site endpoints (for issuing/revoking device sessions).
///
/// The pepper comes from `passwords.yaml` (key
/// `serverSideSessionKeyHashPepper`); it must stay identical between the
/// config used for validation (registered in `initializeAuthServices`) and
/// the config used for issuance.
class SiteDeviceAuthentication {
  static ServerSideSessionsConfig? _config;
  static ServerSideSessions? _sessions;

  static ServerSideSessionsConfig get config {
    final pepper = Serverpod.instance.getPassword(
      'serverSideSessionKeyHashPepper',
    );
    if (pepper == null || pepper.isEmpty) {
      throw StateError(
        'Missing password key "serverSideSessionKeyHashPepper" in '
        'config/passwords.yaml (site device session keys require it).',
      );
    }
    return _config ??= ServerSideSessionsConfig(
      sessionKeyHashPepper: pepper,
    );
  }

  static ServerSideSessions get sessions =>
      _sessions ??= ServerSideSessions(config: config);

  /// Issues a new device session for [authUserId] (the site admin) with
  /// token-level scope `site-device` and returns the (plain) SAS session
  /// key plus its server side session id for the mapping row.
  static Future<({String sessionKey, UuidValue serverSideSessionId})>
  issueDeviceSession(
    final Session session, {
    required final UuidValue authUserId,
  }) async {
    final success = await sessions.createSession(
      session,
      authUserId: authUserId,
      method: 'device',
      scopes: {const Scope(kSiteDeviceScope)},
      // No absolute expiry / inactivity timeout: the device link lives until
      // it is revoked (recovery/flakiness is handled by re-setup).
    );

    final sessionId = success.serverSideSessionId;
    return (sessionKey: success.token, serverSideSessionId: sessionId);
  }

  /// Revokes all server-side sessions with `method: 'device'` of the given
  /// user (kill-switch for site connections when the admin is blocked).
  ///
  /// Note: `revokeAllSessions` filters on the user only in the module, so a
  /// manual `method` filter is applied beforehand to not delete later
  /// non-device sessions unexpectedly (device-only today; kept explicit).
  static Future<void> revokeDeviceSessions(
    final Session session, {
    required final UuidValue authUserId,
  }) async {
    final rows = await ServerSideSession.db.find(
      session,
      where: (t) => t.authUserId.equals(authUserId) & t.method.equals('device'),
    );
    for (final row in rows) {
      await sessions.revokeSession(session, serverSideSessionId: row.id!);
    }
  }
}
