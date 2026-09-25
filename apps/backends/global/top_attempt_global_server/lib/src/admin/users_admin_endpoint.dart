import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_idp_server/core.dart';

import '../auth/scopes.dart';
import '../generated/protocol.dart';

/// Admin endpoint for viewing and managing users of the global instance.
///
/// Access is enforced declaratively via [requiredScopes]: only authenticated
/// users carrying the `global-admin` scope pass endpoint dispatch
/// (unauthenticated -> unauthenticated, no scope -> insufficient access).
class UsersAdminEndpoint extends Endpoint {
  /// Maximum users per page (the client asks about 50; the server clamps).
  static const int pageSize = 50;

  @override
  Set<Scope> get requiredScopes => {const Scope(kGlobalAdminScope)};

  /// Lists users, newest first, paginated.
  ///
  /// Pass [query] to filter by e-mail or full name (case-insensitive
  /// substring match). [total] lets the UI warn when more pages exist.
  Future<AdminUserPage> listUsers(
    final Session session, {
    final String? query,
    final int offset = 0,
    final int limit = pageSize,
  }) async {
    final clampedLimit = limit.clamp(1, pageSize);
    final cleanOffset = offset < 0 ? 0 : offset;
    final filter = _buildFilter(query);

    final items = await UserProfile.db.find(
      session,
      where: (t) => filter,
      limit: clampedLimit,
      offset: cleanOffset,
      orderByList: (t) => [t.createdAt.desc(), t.id.desc()],
    );

    final total = await UserProfile.db.count(session, where: (t) => filter);

    return AdminUserPage(
      items: items.map(_toSummary).toList(),
      offset: cleanOffset,
      total: total,
    );
  }

  /// Returns a single user (used by the detail route/deep links in the UI).
  Future<AdminUserSummary> getUser(
    final Session session, {
    required final UuidValue authUserId,
  }) async {
    return _getSummary(session, authUserId);
  }

  /// Blocks or unblocks the given auth user. Blocked users cannot sign in
  /// and their sessions are revoked.
  Future<AdminUserSummary> setBlocked(
    final Session session, {
    required final UuidValue authUserId,
    required final bool blocked,
  }) async {
    if (authUserId == session.authenticated!.authUserId) {
      throw UserAdminException(
        message: 'Die eigene Sperre ist über die Verwaltung nicht erlaubt.',
      );
    }

    await AuthServices.instance.authUsers.update(
      session,
      authUserId: authUserId,
      blocked: blocked,
    );

    await _revokeUserSessions(session, authUserId);

    return _getSummary(session, authUserId);
  }

  /// Grants (`isGlobalAdmin == true`) or removes the `global-admin` scope.
  ///
  /// Because scopes are baked into the tokens, existing sessions are revoked
  /// so the change takes effect immediately (instead of leaving the old
  /// scope valid until token expiration).
  ///
  /// Revoking one's own admin scope is rejected: the admin would lock
  /// themselves out of this management UI with no way back through this
  /// endpoint. Use a second admin account or manual DB intervention instead.
  Future<AdminUserSummary> setGlobalAdmin(
    final Session session, {
    required final UuidValue authUserId,
    required final bool isGlobalAdmin,
  }) async {
    if (authUserId == session.authenticated!.authUserId) {
      if (isGlobalAdmin) {
        return _getSummary(session, authUserId);
      }
      throw UserAdminException(
        message:
            'Die eigene Global-Admin-Rolle kann nicht entzogen werden. '
            'Nutze ein zweites Admin-Konto oder ein DB-Update.',
      );
    }

    final current = await AuthServices.instance.authUsers.get(
      session,
      authUserId: authUserId,
    );

    final currentUserIsAdmin = current.scopeNames.contains(kGlobalAdminScope);
    if (isGlobalAdmin == currentUserIsAdmin) {
      return _getSummary(session, authUserId);
    }

    final newScopes = isGlobalAdmin
        ? {...current.scopes, const Scope(kGlobalAdminScope)}
        : current.scopes.where((s) => s.name != kGlobalAdminScope).toSet();

    await AuthServices.instance.authUsers.update(
      session,
      authUserId: authUserId,
      scopes: newScopes,
    );

    await _revokeUserSessions(session, authUserId);

    return _getSummary(session, authUserId);
  }

  // -- Private helpers

  /// Deletes all refresh tokens of the user and publishes a revocation
  /// message. Old access tokens stay valid until they expire, but the client
  /// cannot obtain new tokens; sign-in from that point happens from a clean
  /// state and picks up the updated scope/block status.
  Future<void> _revokeUserSessions(
    final Session session,
    final UuidValue authUserId,
  ) async {
    await AuthServices.instance.tokenManager.revokeAllTokens(
      session,
      authUserId: authUserId,
    );

    await session.messages.authenticationRevoked(
      authUserId.uuid,
      RevokedAuthenticationUser(),
    );
  }

  /// E-mail and full name are matched case-insensitively; `_`, `%` and `\`
  /// in the query are escaped so they are matched literally.
  Expression _buildFilter(final String? query) {
    final q = query?.trim() ?? '';
    if (q.isEmpty) return Constant.bool(true);

    final pattern = '%${_escapeLike(q)}%';
    return UserProfile.t.email.ilike(pattern) |
        UserProfile.t.fullName.ilike(pattern);
  }

  String _escapeLike(final String value) {
    return value
        .replaceAll('\\', r'\\')
        .replaceAll('%', r'\%')
        .replaceAll('_', r'\_');
  }

  AdminUserSummary _toSummary(final UserProfile profile) {
    final authUser = profile.authUser;

    return AdminUserSummary(
      authUserId: profile.authUserId,
      email: profile.email,
      fullName: profile.fullName,
      scopeNames: authUser?.scopeNames.toList() ?? const [],
      blocked: authUser?.blocked ?? false,
      createdAt: profile.createdAt,
    );
  }

  Future<AdminUserSummary> _getSummary(
    final Session session,
    final UuidValue authUserId,
  ) async {
    final profile = await UserProfile.db.findFirstRow(
      session,
      where: (t) => t.authUserId.equals(authUserId),
      include: UserProfile.include(authUser: AuthUser.include()),
    );

    if (profile == null) {
      throw UserAdminException(message: 'Benutzer wurde nicht gefunden.');
    }

    return _toSummary(profile);
  }
}
