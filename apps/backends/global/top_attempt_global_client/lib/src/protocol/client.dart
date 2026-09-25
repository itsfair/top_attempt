/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters
// ignore_for_file: invalid_use_of_internal_member

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _ida;
import 'dart:typed_data' as _idt;
import 'package:http/http.dart' as _i85jenna;
import 'package:serverpod_auth_core_client/serverpod_auth_core_client.dart'
    as _iacc;
import 'package:serverpod_auth_idp_client/serverpod_auth_idp_client.dart'
    as _iaic;
import 'package:serverpod_client/serverpod_client.dart' as _isc;
import 'package:top_attempt_global_client/src/protocol/admin/user_admin_page.dart'
    as _iyafgxxo;
import 'package:top_attempt_global_client/src/protocol/admin/user_admin_summary.dart'
    as _i6vy2x4g;
import 'package:top_attempt_global_client/src/protocol/greetings/greeting.dart'
    as _i3comy50;
import 'package:top_attempt_global_client/src/protocol/profile/profile_details.dart'
    as _ibs1lgmn;
import 'package:top_attempt_global_client/src/protocol/sites/created_site_info.dart'
    as _ipl3mql7;
import 'package:top_attempt_global_client/src/protocol/sites/site.dart'
    as _i2twafne;
import 'protocol.dart' as _il2as5qe;

/// Admin endpoint for viewing and managing users of the global instance.
///
/// Access is enforced declaratively via [requiredScopes]: only authenticated
/// users carrying the `global-admin` scope pass endpoint dispatch
/// (unauthenticated -> unauthenticated, no scope -> insufficient access).
/// {@category Endpoint}
class EndpointUsersAdmin extends _isc.EndpointRef {
  EndpointUsersAdmin(_isc.EndpointCaller caller) : super(caller);

  @override
  String get name => 'usersAdmin';

  /// Lists users, newest first, paginated.
  ///
  /// Pass [query] to filter by e-mail or full name (case-insensitive
  /// substring match). [total] lets the UI warn when more pages exist.
  _ida.Future<_iyafgxxo.AdminUserPage> listUsers({
    String? query,
    required int offset,
    required int limit,
  }) => caller.callServerEndpoint<_iyafgxxo.AdminUserPage>(
    'usersAdmin',
    'listUsers',
    {
      'query': query,
      'offset': offset,
      'limit': limit,
    },
  );

  /// Returns a single user (used by the detail route/deep links in the UI).
  _ida.Future<_i6vy2x4g.AdminUserSummary> getUser({
    required _isc.UuidValue authUserId,
  }) => caller.callServerEndpoint<_i6vy2x4g.AdminUserSummary>(
    'usersAdmin',
    'getUser',
    {'authUserId': authUserId},
  );

  /// Blocks or unblocks the given auth user. Blocked users cannot sign in
  /// and their sessions are revoked.
  _ida.Future<_i6vy2x4g.AdminUserSummary> setBlocked({
    required _isc.UuidValue authUserId,
    required bool blocked,
  }) => caller.callServerEndpoint<_i6vy2x4g.AdminUserSummary>(
    'usersAdmin',
    'setBlocked',
    {
      'authUserId': authUserId,
      'blocked': blocked,
    },
  );

  /// Grants (`isGlobalAdmin == true`) or removes the `global-admin` scope.
  ///
  /// Because scopes are baked into the tokens, existing sessions are revoked
  /// so the change takes effect immediately (instead of leaving the old
  /// scope valid until token expiration).
  ///
  /// Revoking one's own admin scope is rejected: the admin would lock
  /// themselves out of this management UI with no way back through this
  /// endpoint. Use a second admin account or manual DB intervention instead.
  _ida.Future<_i6vy2x4g.AdminUserSummary> setGlobalAdmin({
    required _isc.UuidValue authUserId,
    required bool isGlobalAdmin,
  }) => caller.callServerEndpoint<_i6vy2x4g.AdminUserSummary>(
    'usersAdmin',
    'setGlobalAdmin',
    {
      'authUserId': authUserId,
      'isGlobalAdmin': isGlobalAdmin,
    },
  );
}

/// By extending [EmailIdpBaseEndpoint], the email identity provider endpoints
/// are made available on the server and enable the corresponding sign-in widget
/// on the client.
/// {@category Endpoint}
class EndpointEmailIdp extends _iaic.EndpointEmailIdpBase {
  EndpointEmailIdp(_isc.EndpointCaller caller) : super(caller);

  @override
  String get name => 'emailIdp';

  /// Logs in the user and returns a new session.
  ///
  /// Throws an [EmailAccountLoginException] in case of errors, with reason:
  /// - [EmailAccountLoginExceptionReason.invalidCredentials] if the email or
  ///   password is incorrect.
  /// - [EmailAccountLoginExceptionReason.tooManyAttempts] if there have been
  ///   too many failed login attempts.
  ///
  /// Throws an [AuthUserBlockedException] if the auth user is blocked.
  @override
  _ida.Future<_iacc.AuthSuccess> login({
    required String email,
    required String password,
  }) => caller.callServerEndpoint<_iacc.AuthSuccess>(
    'emailIdp',
    'login',
    {
      'email': email,
      'password': password,
    },
  );

  /// Starts the registration for a new user account with an email-based login
  /// associated to it.
  ///
  /// Upon successful completion of this method, an email will have been
  /// sent to [email] with a verification link, which the user must open to
  /// complete the registration.
  ///
  /// Always returns a account request ID, which can be used to complete the
  /// registration. If the email is already registered, the returned ID will not
  /// be valid.
  @override
  _ida.Future<_isc.UuidValue> startRegistration({required String email}) =>
      caller.callServerEndpoint<_isc.UuidValue>(
        'emailIdp',
        'startRegistration',
        {'email': email},
      );

  /// Verifies an account request code and returns a token
  /// that can be used to complete the account creation.
  ///
  /// Throws an [EmailAccountRequestException] in case of errors, with reason:
  /// - [EmailAccountRequestExceptionReason.expired] if the account request has
  ///   already expired.
  /// - [EmailAccountRequestExceptionReason.policyViolation] if the password
  ///   does not comply with the password policy.
  /// - [EmailAccountRequestExceptionReason.invalid] if no request exists
  ///   for the given [accountRequestId] or [verificationCode] is invalid.
  @override
  _ida.Future<String> verifyRegistrationCode({
    required _isc.UuidValue accountRequestId,
    required String verificationCode,
  }) => caller.callServerEndpoint<String>(
    'emailIdp',
    'verifyRegistrationCode',
    {
      'accountRequestId': accountRequestId,
      'verificationCode': verificationCode,
    },
  );

  /// Completes a new account registration, creating a new auth user with a
  /// profile and attaching the given email account to it.
  ///
  /// Throws an [EmailAccountRequestException] in case of errors, with reason:
  /// - [EmailAccountRequestExceptionReason.expired] if the account request has
  ///   already expired.
  /// - [EmailAccountRequestExceptionReason.policyViolation] if the password
  ///   does not comply with the password policy.
  /// - [EmailAccountRequestExceptionReason.invalid] if the [registrationToken]
  ///   is invalid.
  ///
  /// Throws an [AuthUserBlockedException] if the auth user is blocked.
  ///
  /// Returns a session for the newly created user.
  @override
  _ida.Future<_iacc.AuthSuccess> finishRegistration({
    required String registrationToken,
    required String password,
  }) => caller.callServerEndpoint<_iacc.AuthSuccess>(
    'emailIdp',
    'finishRegistration',
    {
      'registrationToken': registrationToken,
      'password': password,
    },
  );

  /// Requests a password reset for [email].
  ///
  /// If the email address is registered, an email with reset instructions will
  /// be send out. If the email is unknown, this method will have no effect.
  ///
  /// Always returns a password reset request ID, which can be used to complete
  /// the reset. If the email is not registered, the returned ID will not be
  /// valid.
  ///
  /// Throws an [EmailAccountPasswordResetException] in case of errors, with reason:
  /// - [EmailAccountPasswordResetExceptionReason.tooManyAttempts] if the user has
  ///   made too many attempts trying to request a password reset.
  ///
  @override
  _ida.Future<_isc.UuidValue> startPasswordReset({required String email}) =>
      caller.callServerEndpoint<_isc.UuidValue>(
        'emailIdp',
        'startPasswordReset',
        {'email': email},
      );

  /// Verifies a password reset code and returns a finishPasswordResetToken
  /// that can be used to finish the password reset.
  ///
  /// Throws an [EmailAccountPasswordResetException] in case of errors, with reason:
  /// - [EmailAccountPasswordResetExceptionReason.expired] if the password reset
  ///   request has already expired.
  /// - [EmailAccountPasswordResetExceptionReason.tooManyAttempts] if the user has
  ///   made too many attempts trying to verify the password reset.
  /// - [EmailAccountPasswordResetExceptionReason.invalid] if no request exists
  ///   for the given [passwordResetRequestId] or [verificationCode] is invalid.
  ///
  /// If multiple steps are required to complete the password reset, this endpoint
  /// should be overridden to return credentials for the next step instead
  /// of the credentials for setting the password.
  @override
  _ida.Future<String> verifyPasswordResetCode({
    required _isc.UuidValue passwordResetRequestId,
    required String verificationCode,
  }) => caller.callServerEndpoint<String>(
    'emailIdp',
    'verifyPasswordResetCode',
    {
      'passwordResetRequestId': passwordResetRequestId,
      'verificationCode': verificationCode,
    },
  );

  /// Completes a password reset request by setting a new password.
  ///
  /// The [verificationCode] returned from [verifyPasswordResetCode] is used to
  /// validate the password reset request.
  ///
  /// Throws an [EmailAccountPasswordResetException] in case of errors, with reason:
  /// - [EmailAccountPasswordResetExceptionReason.expired] if the password reset
  ///   request has already expired.
  /// - [EmailAccountPasswordResetExceptionReason.policyViolation] if the new
  ///   password does not comply with the password policy.
  /// - [EmailAccountPasswordResetExceptionReason.invalid] if no request exists
  ///   for the given [passwordResetRequestId] or [verificationCode] is invalid.
  ///
  /// Throws an [AuthUserBlockedException] if the auth user is blocked.
  @override
  _ida.Future<void> finishPasswordReset({
    required String finishPasswordResetToken,
    required String newPassword,
  }) => caller.callServerEndpoint<void>(
    'emailIdp',
    'finishPasswordReset',
    {
      'finishPasswordResetToken': finishPasswordResetToken,
      'newPassword': newPassword,
    },
  );

  @override
  _ida.Future<bool> hasAccount() => caller.callServerEndpoint<bool>(
    'emailIdp',
    'hasAccount',
    {},
  );
}

/// By extending [RefreshJwtTokensEndpoint], the JWT token refresh endpoint
/// is made available on the server and enables automatic token refresh on the client.
/// {@category Endpoint}
class EndpointJwtRefresh extends _iacc.EndpointRefreshJwtTokens {
  EndpointJwtRefresh(_isc.EndpointCaller caller) : super(caller);

  @override
  String get name => 'jwtRefresh';

  /// Creates a new token pair for the given [refreshToken].
  ///
  /// If [refreshToken] is omitted, cookie-mode web clients fall back to the
  /// configured HttpOnly refresh cookie. When neither source is present this
  /// throws [RefreshTokenNotFoundException], the same public "no usable refresh
  /// credential" exception used for unknown refresh tokens.
  ///
  /// Can throw the following exceptions:
  /// -[RefreshTokenMalformedException]: refresh token is malformed and could
  ///   not be parsed. Not expected to happen for tokens issued by the server.
  /// -[RefreshTokenNotFoundException]: refresh token is unknown to the server.
  ///   Either the token was deleted or generated by a different server.
  /// -[RefreshTokenExpiredException]: refresh token has expired. Will happen
  ///   only if it has not been used within configured `refreshTokenLifetime`.
  /// -[RefreshTokenInvalidSecretException]: refresh token is incorrect, meaning
  ///   it does not refer to the current secret refresh token. This indicates
  ///   either a malfunctioning client or a malicious attempt by someone who has
  ///   obtained the refresh token. In this case the underlying refresh token
  ///   will be deleted, and access to it will expire fully when the last access
  ///   token is elapsed.
  ///
  /// This endpoint is unauthenticated, meaning the client won't include any
  /// authentication information with the call.
  @override
  _ida.Future<_iacc.AuthSuccess> refreshAccessToken({String? refreshToken}) =>
      caller.callServerEndpoint<_iacc.AuthSuccess>(
        'jwtRefresh',
        'refreshAccessToken',
        {'refreshToken': refreshToken},
        authenticated: false,
      );
}

/// Exposes the built-in user profile management endpoints of the
/// authentication module to the app (get, set/remove image, change names).
/// {@category Endpoint}
class EndpointUserProfileEdit extends _iacc.EndpointUserProfileEditBase {
  EndpointUserProfileEdit(_isc.EndpointCaller caller) : super(caller);

  @override
  String get name => 'userProfileEdit';

  /// Replaces the profile image. The previous image (database row + file in
  /// storage) is removed first, so replacing an image does not pile up old
  /// files. This is a no-op if the user has no image yet.
  @override
  _ida.Future<_iacc.UserProfileModel> setUserImage(_idt.ByteData image) =>
      caller.callServerEndpoint<_iacc.UserProfileModel>(
        'userProfileEdit',
        'setUserImage',
        {'image': image},
      );

  /// Removes the user's uploaded image, setting it to null.
  ///
  /// The client should handle displaying a placeholder for users without images.
  @override
  _ida.Future<_iacc.UserProfileModel> removeUserImage() =>
      caller.callServerEndpoint<_iacc.UserProfileModel>(
        'userProfileEdit',
        'removeUserImage',
        {},
      );

  /// Changes the name of a user.
  @override
  _ida.Future<_iacc.UserProfileModel> changeUserName(String? userName) =>
      caller.callServerEndpoint<_iacc.UserProfileModel>(
        'userProfileEdit',
        'changeUserName',
        {'userName': userName},
      );

  /// Changes the full name of a user.
  @override
  _ida.Future<_iacc.UserProfileModel> changeFullName(String? fullName) =>
      caller.callServerEndpoint<_iacc.UserProfileModel>(
        'userProfileEdit',
        'changeFullName',
        {'fullName': fullName},
      );

  /// Returns the user profile of the current user.
  @override
  _ida.Future<_iacc.UserProfileModel> get() =>
      caller.callServerEndpoint<_iacc.UserProfileModel>(
        'userProfileEdit',
        'get',
        {},
      );
}

/// This is an example endpoint that returns a greeting message through
/// its [hello] method.
/// {@category Endpoint}
class EndpointGreeting extends _isc.EndpointRef {
  EndpointGreeting(_isc.EndpointCaller caller) : super(caller);

  @override
  String get name => 'greeting';

  /// Returns a personalized greeting message: "Hello {name}".
  _ida.Future<_i3comy50.Greeting> hello(String name) =>
      caller.callServerEndpoint<_i3comy50.Greeting>(
        'greeting',
        'hello',
        {'name': name},
      );
}

/// Endpoint for the user's own profile details (first name, last name and
/// birthday). Email, user id and the profile image are managed by the
/// built-in authentication module endpoints (see UserProfileEditEndpoint).
/// {@category Endpoint}
class EndpointProfileDetails extends _isc.EndpointRef {
  EndpointProfileDetails(_isc.EndpointCaller caller) : super(caller);

  @override
  String get name => 'profileDetails';

  /// Returns the profile details of the signed-in user, or null if they have
  /// never been saved yet.
  _ida.Future<_ibs1lgmn.ProfileDetails?> get() =>
      caller.callServerEndpoint<_ibs1lgmn.ProfileDetails?>(
        'profileDetails',
        'get',
        {},
      );

  /// Validates and saves the profile details of the signed-in user.
  /// The name is also written to the built-in user profile so that other
  /// parts of the system see a consistent full name.
  _ida.Future<_ibs1lgmn.ProfileDetails> save({
    required String firstName,
    required String lastName,
    required DateTime birthday,
  }) => caller.callServerEndpoint<_ibs1lgmn.ProfileDetails>(
    'profileDetails',
    'save',
    {
      'firstName': firstName,
      'lastName': lastName,
      'birthday': birthday,
    },
  );
}

/// Admin endpoint for creating and viewing sites ("Betriebe").
///
/// Access is enforced declaratively via [requiredScopes] (`global-admin`).
///
/// Stage 2 will add: the enrollment endpoint the local instance calls with
/// the one-time password (burns the OTP, issues the device credential,
/// delivers the initial admin password and marks the site registered), plus
/// WS connection handling.
/// {@category Endpoint}
class EndpointSitesAdmin extends _isc.EndpointRef {
  EndpointSitesAdmin(_isc.EndpointCaller caller) : super(caller);

  @override
  String get name => 'sitesAdmin';

  /// Creates a site, generates the one-time password for the local
  /// instance's enrollment and the initial password for the local admin
  /// (the local AuthUser is created at first connect with it), seeds the
  /// site admin membership and returns everything in plain text exactly
  /// once ([CreatedSiteInfo]).
  _ida.Future<_ipl3mql7.CreatedSiteInfo> createSite({
    required String name,
    required String street,
    required String zipCode,
    required String city,
    required String country,
    required String companyEmail,
    required _isc.UuidValue firstAdminId,
  }) => caller.callServerEndpoint<_ipl3mql7.CreatedSiteInfo>(
    'sitesAdmin',
    'createSite',
    {
      'name': name,
      'street': street,
      'zipCode': zipCode,
      'city': city,
      'country': country,
      'companyEmail': companyEmail,
      'firstAdminId': firstAdminId,
    },
  );

  /// Lists sites, newest first, paginated. [query] filters by name,
  /// company email or city (case-insensitive substring).
  _ida.Future<List<_i2twafne.Site>> listSites({
    String? query,
    required int offset,
    required int limit,
  }) => caller.callServerEndpoint<List<_i2twafne.Site>>(
    'sitesAdmin',
    'listSites',
    {
      'query': query,
      'offset': offset,
      'limit': limit,
    },
  );

  /// Number of sites matching the given [query] (for the "more available"
  /// hint in the UI).
  _ida.Future<int> countSites({String? query}) =>
      caller.callServerEndpoint<int>(
        'sitesAdmin',
        'countSites',
        {'query': query},
      );

  /// Returns a single site (detail route/deep links in the UI).
  _ida.Future<_i2twafne.Site> getSite({required int siteId}) =>
      caller.callServerEndpoint<_i2twafne.Site>(
        'sitesAdmin',
        'getSite',
        {'siteId': siteId},
      );
}

class Modules {
  Modules(Client client) {
    serverpod_auth_idp = _iaic.Caller(client);
    serverpod_auth_core = _iacc.Caller(client);
  }

  late final _iaic.Caller serverpod_auth_idp;

  late final _iacc.Caller serverpod_auth_core;
}

class Client extends _isc.ServerpodClientShared {
  Client(
    String host, {
    dynamic securityContext,
    Duration? streamingConnectionTimeout,
    Duration? connectionTimeout,
    Function(
      _isc.MethodCallContext,
      Object,
      StackTrace,
    )?
    onFailedCall,
    Function(_isc.MethodCallContext)? onSucceededCall,
    bool? disconnectStreamsOnLostInternetConnection,
    _i85jenna.Client? httpClientOverride,
  }) : super(
         host,
         _il2as5qe.Protocol(),
         securityContext: securityContext,
         streamingConnectionTimeout: streamingConnectionTimeout,
         connectionTimeout: connectionTimeout,
         onFailedCall: onFailedCall,
         onSucceededCall: onSucceededCall,
         disconnectStreamsOnLostInternetConnection:
             disconnectStreamsOnLostInternetConnection,
         httpClientOverride: httpClientOverride,
       ) {
    usersAdmin = EndpointUsersAdmin(this);
    emailIdp = EndpointEmailIdp(this);
    jwtRefresh = EndpointJwtRefresh(this);
    userProfileEdit = EndpointUserProfileEdit(this);
    greeting = EndpointGreeting(this);
    profileDetails = EndpointProfileDetails(this);
    sitesAdmin = EndpointSitesAdmin(this);
    modules = Modules(this);
  }

  late final EndpointUsersAdmin usersAdmin;

  late final EndpointEmailIdp emailIdp;

  late final EndpointJwtRefresh jwtRefresh;

  late final EndpointUserProfileEdit userProfileEdit;

  late final EndpointGreeting greeting;

  late final EndpointProfileDetails profileDetails;

  late final EndpointSitesAdmin sitesAdmin;

  late final Modules modules;

  @override
  Map<String, _isc.EndpointRef> get endpointRefLookup => {
    'usersAdmin': usersAdmin,
    'emailIdp': emailIdp,
    'jwtRefresh': jwtRefresh,
    'userProfileEdit': userProfileEdit,
    'greeting': greeting,
    'profileDetails': profileDetails,
    'sitesAdmin': sitesAdmin,
  };

  @override
  Map<String, _isc.ModuleEndpointCaller> get moduleLookup => {
    'serverpod_auth_idp': modules.serverpod_auth_idp,
    'serverpod_auth_core': modules.serverpod_auth_core,
  };
}
