import 'package:serverpod/serverpod.dart';
import 'package:top_attempt_global_client/top_attempt_client.dart' as gc;

import '../generated/protocol.dart';
import 'global_site_connection.dart';
import 'site_connection_config.dart';

/// Local setup endpoint: connects this instance to its site's global
/// instance by verifying with the **global credentials of the site admin**
/// (the one chosen at site creation). Fills the local `memberships` row for
/// the admin (identity: their global authUserId) plus their
/// `profile_details` row and creates the local `local-admin` login with
/// the same password.
class SiteSetupEndpoint extends Endpoint {
  /// Verifies the entered global credentials against the global backend,
  /// stores the enrollment and starts the connection worker.
  ///
  /// When the global user is site admin of several sites the first call
  /// returns `requiresSiteSelection` with the candidates; retry with the
  /// chosen [siteId].
  Future<SiteSetupResult> enterSetup(
    final Session session, {
    required final String email,
    required final String password,
    final int? siteId,
  }) async {
    final globalApiUrl = SiteConnectionConfig.globalApiUrlFor(
      session.serverpod.config.runMode,
    );
    if (globalApiUrl == null) {
      throw SiteSetupException(
        message: 'siteConnection.globalApiUrl fehlt in der lokale Config.',
      );
    }

    final globalClient = gc.Client(globalApiUrl);
    final gc.SiteEnrollmentInfo info;
    try {
      info = await globalClient.siteEnrollment.enroll(
        email: email,
        password: password,
        siteId: siteId,
      );
    } on gc.ServerpodClientException catch (e) {
      throw SiteSetupException(
        message: 'Enrollment fehlgeschlagen: $e',
      );
    }

    if (info.requiresSiteSelection) {
      return SiteSetupResult(
        requiresSiteSelection: true,
        candidates: [
          for (final candidate in info.candidates)
            SiteCandidateLocal(
              siteId: candidate.siteId,
              siteName: candidate.siteName,
            ),
        ],
      );
    }

    final transfer = info.transfer!;
    await GlobalSiteConnection.instance.applySetup(
      session,
      globalApiUrl: globalApiUrl,
      transfer: transfer,
      adminPassword: password,
    );

    return SiteSetupResult(
      candidates: const [],
      siteId: transfer.siteId,
      siteName: transfer.siteName,
    );
  }

  /// The current local connection state (App-Bar chip in the admin UI).
  Future<SiteConnectionInfo> connectionStatus(final Session session) async {
    return GlobalSiteConnection.instance.status();
  }

  /// Everything the local admin UI displays about this instance:
  /// connection state + site snapshot + the admin's mirrored person data
  /// (local `member_profile` copy, joined via the exchange id
  /// `site_connections.adminAuthUserId`). The default of the state
  /// is `noneSetup` with an empty snapshot until the instance is enrolled.
  Future<LocalAdminInfo> adminInfo(final Session session) async {
    final status = GlobalSiteConnection.instance.status();
    final connection = await SiteConnection.db.findFirstRow(session);

    MemberProfile? adminProfile;
    final adminAuthUserId = connection?.adminAuthUserId;
    if (adminAuthUserId != null) {
      adminProfile = await MemberProfile.db.findFirstRow(
        session,
        where: (t) => t.globalAuthUserId.equals(adminAuthUserId),
      );
    }
    final site = connection;

    return LocalAdminInfo(
      connectionState: status.state,
      connectionError: status.lastError,
      lastConnectedAt: status.lastConnectedAt,
      siteId: site?.siteId,
      siteName: site?.siteName,
      siteStreet: site?.siteStreet,
      siteZipCode: site?.siteZipCode,
      siteCity: site?.siteCity,
      siteCountry: site?.siteCountry,
      siteCompanyEmail: site?.siteCompanyEmail,
      adminEmail: adminProfile?.email,
      adminFirstName: adminProfile?.firstName,
      adminLastName: adminProfile?.lastName,
      adminBirthday: adminProfile?.birthday,
      adminImageUrl: adminProfile?.imageUrl,
    );
  }
}
