import 'package:serverpod/serverpod.dart';

import '../auth/scopes.dart';
import '../generated/protocol.dart';

/// Device connection endpoint for the local instance.
///
/// The local instance opens a long-lived method stream on [connect] and
/// keeps sending [SitePing]s. Each ping refreshes `site.lastSeenAt` (the
/// per-site connection chip in the admin UI derives its state from that).
/// The site is resolved from the enrolled `SiteDeviceSession` mapping via
/// the SAS session id (`session.authenticated!.authId`).
///
/// Live status broadcast to admin clients (Serverpod message central) is a
/// To-do; the admin list currently polls.
class SiteConnectionEndpoint extends Endpoint {
  @override
  Set<Scope> get requiredScopes => {const Scope(kSiteDeviceScope)};

  /// The device connection stream. Pings keep the connection and the site
  /// freshness alive; the stream stays open until the client closes it or
  /// an error occurs (client handles reconnects; if the credential was
  /// revoked, a reconnect fails with an auth error and the local instance
  /// switches to `needsReSetup`).
  Stream<SiteEvent> connect(
    final Session session,
    final Stream<SitePing> pings,
  ) async* {
    final site = await _requireSite(session);

    await _touch(session, site);
    await for (final ping in pings) {
      await _touch(session, site);
      yield SiteEvent(
        pongSentAtMs: DateTime.now().millisecondsSinceEpoch,
        pingSentAtMs: ping.sentAtMs,
        sentAtMs: DateTime.now().millisecondsSinceEpoch,
      );
    }
  }

  // -- Private helpers

  /// Resolves the site of this device session via the SAS session id.
  Future<Site> _requireSite(final Session session) async {
    final authInfo = session.authenticated;
    final sessionId = authInfo?.authId;
    if (authInfo == null || sessionId == null) {
      throw SiteAdminException(message: 'Nicht authentifiziert.');
    }

    final deviceSession = await SiteDeviceSession.db.findFirstRow(
      session,
      where: (t) => t.serverSideSessionId.equals(
        UuidValue.fromString(sessionId),
      ),
    );
    if (deviceSession == null) {
      throw SiteAdminException(
        message:
            'Device-Session unbekannt oder widerrufen — bitte neu einrichten.',
      );
    }

    final site = await Site.db.findFirstRow(
      session,
      where: (t) => t.id.equals(deviceSession.siteId),
    );
    if (site == null) {
      throw SiteAdminException(message: 'Site fehlt — bitte neu einrichten.');
    }
    return site;
  }

  Future<void> _touch(final Session session, final Site site) async {
    await Site.db.updateRow(
      session,
      site.copyWith(lastSeenAt: DateTime.now()),
    );
  }
}
