/// Scope that marks an auth user as platform administrator ("global admin")
/// of the global instance.
///
/// Admin endpoints (e.g. `UsersAdminEndpoint`) declare this via
/// `requiredScopes`, so Serverpod enforces it during endpoint dispatch
/// (unauthenticated -> failure "unauthenticated", no scope ->
/// "insufficientAccess").
///
/// See docs/serverpod: scopes are baked into the access token. After granting
/// or revoking scopes, the user's tokens must be revoked (`AuthServices
/// .instance.tokenManager.revokeAllTokens`), otherwise the change only takes
/// effect on the next login. Users of this scope are managed via
/// `AuthUsers.update` (server code; never per raw SQL while users are active).
const String kGlobalAdminScope = 'global-admin';
