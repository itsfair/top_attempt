import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_idp_server/core.dart';

import '../auth/scopes.dart';
import '../generated/protocol.dart';
import 'secret_generator.dart';
import 'site_setup_crypto.dart';

/// Admin endpoint for creating and viewing sites ("Betriebe").
///
/// Access is enforced declaratively via [requiredScopes] (`global-admin`).
///
/// Stage 2 will add: the enrollment endpoint the local instance calls with
/// the one-time password (burns the OTP, issues the device credential,
/// delivers the initial admin password and marks the site registered), plus
/// WS connection handling.
class SitesAdminEndpoint extends Endpoint {
  /// Maximum sites per page (the client asks about 50; the server clamps).
  static const int pageSize = 50;

  @override
  Set<Scope> get requiredScopes => {const Scope(kGlobalAdminScope)};

  /// Creates a site, generates the one-time password for the local
  /// instance's enrollment and the initial password for the local admin
  /// (the local AuthUser is created at first connect with it), seeds the
  /// site admin membership and returns everything in plain text exactly
  /// once ([CreatedSiteInfo]).
  Future<CreatedSiteInfo> createSite(
    final Session session, {
    required final String name,
    required final String street,
    required final String zipCode,
    required final String city,
    required final String country,
    required final String companyEmail,
    required final UuidValue firstAdminId,
  }) async {
    final nameValue = _requireField(name, 'name');
    final streetValue = _requireField(street, 'street');
    final zipCodeValue = _requireField(zipCode, 'zipCode');
    final cityValue = _requireField(city, 'city');
    final countryValue = _requireField(country, 'country');
    final emailValue = _requireValidEmail(companyEmail);

    final firstAdmin = await AuthServices.instance.authUsers.get(
      session,
      authUserId: firstAdminId,
    );
    if (firstAdmin.blocked) {
      throw SiteAdminException(
        message: 'Der gewählte Admin-Nutzer ist gesperrt.',
      );
    }

    final oneTimePassword = SecretGenerator.generateOneTimePassword();
    final initialAdminPassword = SecretGenerator.generateInitialAdminPassword();

    final site = await Site.db.insertRow(
      session,
      Site(
        name: nameValue,
        street: streetValue,
        zipCode: zipCodeValue,
        city: cityValue,
        country: countryValue,
        companyEmail: emailValue,
        firstAdminId: firstAdminId,
        oneTimePasswordHash: SiteSetupCrypto.oneTimePasswordHash(
          oneTimePassword,
        ),
        initialAdminPasswordEncrypted: await SiteSetupCrypto.encrypt(
          session: session,
          plaintext: initialAdminPassword,
        ),
      ),
    );

    await SiteMembership.db.insertRow(
      session,
      SiteMembership(
        siteId: site.id!,
        authUserId: firstAdminId,
        role: SiteRole.siteAdmin,
      ),
    );

    return CreatedSiteInfo(
      siteId: site.id!,
      oneTimePassword: oneTimePassword,
      initialAdminPassword: initialAdminPassword,
    );
  }

  /// Lists sites, newest first, paginated. [query] filters by name,
  /// company email or city (case-insensitive substring).
  Future<List<Site>> listSites(
    final Session session, {
    final String? query,
    final int offset = 0,
    final int limit = pageSize,
  }) async {
    final q = query?.trim() ?? '';
    final filter = q.isEmpty
        ? null
        : (t) =>
              Site.t.name.ilike('%${_escapeLike(q)}%') |
              Site.t.companyEmail.ilike('%${_escapeLike(q)}%') |
              Site.t.city.ilike('%${_escapeLike(q)}%');

    return Site.db.find(
      session,
      where: filter,
      limit: limit.clamp(1, pageSize),
      offset: offset < 0 ? 0 : offset,
      orderByList: (t) => [t.createdAt.desc(), t.id.desc()],
    );
  }

  /// Number of sites matching the given [query] (for the "more available"
  /// hint in the UI).
  Future<int> countSites(final Session session, {final String? query}) async {
    final q = query?.trim() ?? '';
    final filter = q.isEmpty
        ? null
        : (t) =>
              Site.t.name.ilike('%${_escapeLike(q)}%') |
              Site.t.companyEmail.ilike('%${_escapeLike(q)}%') |
              Site.t.city.ilike('%${_escapeLike(q)}%');

    return Site.db.count(
      session,
      where: filter,
    );
  }

  /// Returns a single site (detail route/deep links in the UI).
  Future<Site> getSite(
    final Session session, {
    required final int siteId,
  }) async {
    final site = await Site.db.findById(session, siteId);
    if (site == null) {
      throw SiteAdminException(message: 'Site wurde nicht gefunden.');
    }
    return site;
  }

  // -- Private helpers

  String _requireField(final String value, final String field) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      throw SiteAdminException(message: '$field ist erforderlich.');
    }
    return trimmed;
  }

  String _requireValidEmail(final String input) {
    final value = _requireField(input, 'companyEmail').toLowerCase();
    if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(value)) {
      throw SiteAdminException(message: 'companyEmail ist nicht gültig.');
    }
    return value;
  }

  String _escapeLike(final String value) {
    return value
        .replaceAll('\\', r'\\')
        .replaceAll('%', r'\%')
        .replaceAll('_', r'\_');
  }
}
