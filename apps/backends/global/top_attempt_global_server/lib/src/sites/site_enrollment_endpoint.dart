import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_idp_server/core.dart';
import 'package:serverpod_auth_idp_server/providers/email.dart';

import '../generated/protocol.dart';
import 'site_device_authentication.dart';

/// Public endpoint for the local instance enrollment.
///
/// The local instance verifies here with the **global credentials of the
/// site admin** (chosen at site creation). Neither one-time passwords nor
/// transferred passwords are involved:
///
/// - Fresh setup: the site flips to `registered`, the local instance
///   receives site/admin data plus the device session key (SAS session,
///   `method: 'device'`, token-level scope `site-device`, non-rotating,
///   write-once on the local side).
/// - Recovery: same verification path; the previously issued device
///   session is revoked and replaced. The transfer data is omitted — the
///   local instance keeps its already stored admin/member data.
///
/// Rate limiting and blocked-user handling come for free with the email
/// IdP verification (no info leak on wrong credentials).
class SiteEnrollmentEndpoint extends Endpoint {
  /// Lists the active `siteAdmin` memberships of a verified user — used by
  /// the local setup mask when the admin runs more than one site.
  Future<List<SiteAdminMembershipCandidate>> listSiteAdminCandidates(
    final Session session, {
    required final String email,
    required final String password,
  }) async {
    final authUserId = await _verifyCredentials(session, email, password);
    final memberships = await _siteAdminMemberships(session, authUserId);
    return [
      for (final membership in memberships)
        SiteAdminMembershipCandidate(
          siteId: membership.siteId,
          siteName: membership.site?.name ?? '-',
        ),
    ];
  }

  /// Enrolls the local instance for the site of the verified site admin.
  ///
  /// Without [siteId] this resolves the site automatically when the admin
  /// has exactly one active `siteAdmin` membership. If they own several,
  /// the response comes back with `requiresSiteSelection = true` and the
  /// candidates to pick from.
  Future<SiteEnrollmentInfo> enroll(
    final Session session, {
    required final String email,
    required final String password,
    final int? siteId,
  }) async {
    final authUserId = await _verifyCredentials(session, email, password);

    var memberships = await _siteAdminMemberships(session, authUserId);
    if (siteId != null) {
      memberships = memberships.where((m) => m.siteId == siteId).toList();
    }
    if (memberships.isEmpty) {
      if (siteId == null) {
        throw SiteAdminException(
          message: 'Dieser Nutzer ist kein aktiver Site-Admin einer Site.',
        );
      }
      throw SiteAdminException(
        message: 'Site nicht gefunden oder keine Admin-Mitgliedschaft.',
      );
    }

    if (memberships.length > 1 && siteId == null) {
      return SiteEnrollmentInfo(
        requiresSiteSelection: true,
        candidates: [
          for (final membership in memberships)
            SiteAdminMembershipCandidate(
              siteId: membership.siteId,
              siteName: membership.site?.name ?? '-',
            ),
        ],
      );
    }

    final membership = memberships.first;
    final site = membership.site;
    if (site == null) {
      throw SiteAdminException(message: 'Site des Admins fehlt.');
    }

    final wasPendingSetup = site.status == SiteSetupStatus.pendingSetup;
    if (wasPendingSetup) {
      await Site.db.updateRow(
        session,
        site.copyWith(
          status: SiteSetupStatus.registered,
          registeredAt: DateTime.now(),
        ),
      );
    } else {
      // Recovery: drop the previous device session for this site so that
      // exactly one connection credential remains active.
      final previous = await SiteDeviceSession.db.find(
        session,
        where: (t) => t.siteId.equals(site.id!),
      );
      for (final row in previous) {
        await SiteDeviceAuthentication.sessions.revokeSession(
          session,
          serverSideSessionId: row.serverSideSessionId,
        );
        await SiteDeviceSession.db.deleteRow(session, row);
      }
    }

    final issued = await SiteDeviceAuthentication.issueDeviceSession(
      session,
      authUserId: authUserId,
    );

    final enrolledSiteId = site.id!;

    await SiteDeviceSession.db.insertRow(
      session,
      SiteDeviceSession(
        siteId: enrolledSiteId,
        serverSideSessionId: issued.serverSideSessionId,
      ),
    );

    final adminProfile = await AuthServices.instance.userProfiles
        .maybeFindUserProfileByUserId(session, authUserId);

    return SiteEnrollmentInfo(
      candidates: const [],
      transfer: SiteTransferInfo(
        siteId: enrolledSiteId,
        siteName: site.name,
        adminEmail: email.trim().toLowerCase(),
        adminAuthUserId: authUserId,
        adminFullName: adminProfile?.fullName,
        deviceSessionKey: issued.sessionKey,
      ),
    );
  }

  // -- Private helpers

  /// Verifies the global credentials without issuing a token; rate limiting
  /// and blocked-user handling are inherited from the IdP. The check is
  /// internally wrapped by the IdP server exception mapper.
  Future<UuidValue> _verifyCredentials(
    final Session session,
    final String email,
    final String password,
  ) async {
    final emailValue = email.trim().toLowerCase();
    try {
      return await AuthServices.getIdentityProvider<EmailIdp>()
          .utils
          .authentication
          .authenticate(
            session,
            email: emailValue,
            password: password,
            transaction: null,
          );
    } on EmailAuthenticationInvalidCredentialsException {
      throw SiteAdminException(
        message: 'E-Mail oder Passwort ist nicht korrekt.',
      );
    } on EmailAccountNotFoundException {
      throw SiteAdminException(
        message:
            'Kein Konto für diese E-Mail (Nutzer registriert sich global).',
      );
    } on EmailAuthenticationTooManyAttemptsException {
      throw SiteAdminException(
        message: 'Zu viele Versuche — bitte später erneut probieren.',
      );
    }
  }

  Future<List<SiteMembership>> _siteAdminMemberships(
    final Session session,
    final UuidValue authUserId,
  ) async {
    return SiteMembership.db.find(
      session,
      where: (t) =>
          t.authUserId.equals(authUserId) &
          t.role.equals(SiteRole.siteAdmin) &
          t.active.equals(true),
      include: SiteMembership.include(site: Site.include()),
    );
  }
}
