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
import 'dart:typed_data' as _idt;
import 'package:serverpod/serverpod.dart' as _is;
import 'package:serverpod_auth_core_server/serverpod_auth_core_server.dart'
    as _iacs;
import 'package:serverpod_auth_idp_server/serverpod_auth_idp_server.dart'
    as _iais;
import 'package:top_attempt_global_server/src/generated/sites/site_ping.dart'
    as _ijzkrm2i;
import '../admin/users_admin_endpoint.dart' as _i9qj2dak;
import '../auth/email_idp_endpoint.dart' as _iuc1hd5t;
import '../auth/jwt_refresh_endpoint.dart' as _inwq3ztq;
import '../auth/user_profile_edit_endpoint.dart' as _ije0zjyg;
import '../greetings/greeting_endpoint.dart' as _il624ik7;
import '../profile/profile_details_endpoint.dart' as _iev396g5;
import '../sites/site_connection_endpoint.dart' as _iy15yji6;
import '../sites/site_enrollment_endpoint.dart' as _ii29ea4g;
import '../sites/sites_admin_endpoint.dart' as _i6ok1ur0;

class Endpoints extends _is.EndpointDispatch {
  @override
  void initializeEndpoints(_is.Server server) {
    var endpoints = <String, _is.Endpoint>{
      'usersAdmin': _i9qj2dak.UsersAdminEndpoint()
        ..initialize(
          server,
          'usersAdmin',
          null,
        ),
      'emailIdp': _iuc1hd5t.EmailIdpEndpoint()
        ..initialize(
          server,
          'emailIdp',
          null,
        ),
      'jwtRefresh': _inwq3ztq.JwtRefreshEndpoint()
        ..initialize(
          server,
          'jwtRefresh',
          null,
        ),
      'userProfileEdit': _ije0zjyg.UserProfileEditEndpoint()
        ..initialize(
          server,
          'userProfileEdit',
          null,
        ),
      'greeting': _il624ik7.GreetingEndpoint()
        ..initialize(
          server,
          'greeting',
          null,
        ),
      'profileDetails': _iev396g5.ProfileDetailsEndpoint()
        ..initialize(
          server,
          'profileDetails',
          null,
        ),
      'siteConnection': _iy15yji6.SiteConnectionEndpoint()
        ..initialize(
          server,
          'siteConnection',
          null,
        ),
      'siteEnrollment': _ii29ea4g.SiteEnrollmentEndpoint()
        ..initialize(
          server,
          'siteEnrollment',
          null,
        ),
      'sitesAdmin': _i6ok1ur0.SitesAdminEndpoint()
        ..initialize(
          server,
          'sitesAdmin',
          null,
        ),
    };
    connectors['usersAdmin'] = _is.EndpointConnector(
      name: 'usersAdmin',
      endpoint: endpoints['usersAdmin']!,
      methodConnectors: {
        'listUsers': _is.MethodConnector(
          name: 'listUsers',
          params: {
            'query': _is.ParameterDescription(
              name: 'query',
              type: _is.getType<String?>(),
              nullable: true,
            ),
            'offset': _is.ParameterDescription(
              name: 'offset',
              type: _is.getType<int>(),
              nullable: false,
            ),
            'limit': _is.ParameterDescription(
              name: 'limit',
              type: _is.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['usersAdmin'] as _i9qj2dak.UsersAdminEndpoint)
                      .listUsers(
                        session,
                        query: params['query'],
                        offset: params['offset'],
                        limit: params['limit'],
                      ),
        ),
        'getUser': _is.MethodConnector(
          name: 'getUser',
          params: {
            'authUserId': _is.ParameterDescription(
              name: 'authUserId',
              type: _is.getType<_is.UuidValue>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['usersAdmin'] as _i9qj2dak.UsersAdminEndpoint)
                      .getUser(
                        session,
                        authUserId: params['authUserId'],
                      ),
        ),
        'setBlocked': _is.MethodConnector(
          name: 'setBlocked',
          params: {
            'authUserId': _is.ParameterDescription(
              name: 'authUserId',
              type: _is.getType<_is.UuidValue>(),
              nullable: false,
            ),
            'blocked': _is.ParameterDescription(
              name: 'blocked',
              type: _is.getType<bool>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['usersAdmin'] as _i9qj2dak.UsersAdminEndpoint)
                      .setBlocked(
                        session,
                        authUserId: params['authUserId'],
                        blocked: params['blocked'],
                      ),
        ),
        'setGlobalAdmin': _is.MethodConnector(
          name: 'setGlobalAdmin',
          params: {
            'authUserId': _is.ParameterDescription(
              name: 'authUserId',
              type: _is.getType<_is.UuidValue>(),
              nullable: false,
            ),
            'isGlobalAdmin': _is.ParameterDescription(
              name: 'isGlobalAdmin',
              type: _is.getType<bool>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['usersAdmin'] as _i9qj2dak.UsersAdminEndpoint)
                      .setGlobalAdmin(
                        session,
                        authUserId: params['authUserId'],
                        isGlobalAdmin: params['isGlobalAdmin'],
                      ),
        ),
      },
    );
    connectors['emailIdp'] = _is.EndpointConnector(
      name: 'emailIdp',
      endpoint: endpoints['emailIdp']!,
      methodConnectors: {
        'login': _is.MethodConnector(
          name: 'login',
          params: {
            'email': _is.ParameterDescription(
              name: 'email',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'password': _is.ParameterDescription(
              name: 'password',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['emailIdp'] as _iuc1hd5t.EmailIdpEndpoint).login(
                    session,
                    email: params['email'],
                    password: params['password'],
                  ),
        ),
        'startRegistration': _is.MethodConnector(
          name: 'startRegistration',
          params: {
            'email': _is.ParameterDescription(
              name: 'email',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['emailIdp'] as _iuc1hd5t.EmailIdpEndpoint)
                  .startRegistration(
                    session,
                    email: params['email'],
                  ),
        ),
        'verifyRegistrationCode': _is.MethodConnector(
          name: 'verifyRegistrationCode',
          params: {
            'accountRequestId': _is.ParameterDescription(
              name: 'accountRequestId',
              type: _is.getType<_is.UuidValue>(),
              nullable: false,
            ),
            'verificationCode': _is.ParameterDescription(
              name: 'verificationCode',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['emailIdp'] as _iuc1hd5t.EmailIdpEndpoint)
                  .verifyRegistrationCode(
                    session,
                    accountRequestId: params['accountRequestId'],
                    verificationCode: params['verificationCode'],
                  ),
        ),
        'finishRegistration': _is.MethodConnector(
          name: 'finishRegistration',
          params: {
            'registrationToken': _is.ParameterDescription(
              name: 'registrationToken',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'password': _is.ParameterDescription(
              name: 'password',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['emailIdp'] as _iuc1hd5t.EmailIdpEndpoint)
                  .finishRegistration(
                    session,
                    registrationToken: params['registrationToken'],
                    password: params['password'],
                  ),
        ),
        'startPasswordReset': _is.MethodConnector(
          name: 'startPasswordReset',
          params: {
            'email': _is.ParameterDescription(
              name: 'email',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['emailIdp'] as _iuc1hd5t.EmailIdpEndpoint)
                  .startPasswordReset(
                    session,
                    email: params['email'],
                  ),
        ),
        'verifyPasswordResetCode': _is.MethodConnector(
          name: 'verifyPasswordResetCode',
          params: {
            'passwordResetRequestId': _is.ParameterDescription(
              name: 'passwordResetRequestId',
              type: _is.getType<_is.UuidValue>(),
              nullable: false,
            ),
            'verificationCode': _is.ParameterDescription(
              name: 'verificationCode',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['emailIdp'] as _iuc1hd5t.EmailIdpEndpoint)
                  .verifyPasswordResetCode(
                    session,
                    passwordResetRequestId: params['passwordResetRequestId'],
                    verificationCode: params['verificationCode'],
                  ),
        ),
        'finishPasswordReset': _is.MethodConnector(
          name: 'finishPasswordReset',
          params: {
            'finishPasswordResetToken': _is.ParameterDescription(
              name: 'finishPasswordResetToken',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'newPassword': _is.ParameterDescription(
              name: 'newPassword',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['emailIdp'] as _iuc1hd5t.EmailIdpEndpoint)
                  .finishPasswordReset(
                    session,
                    finishPasswordResetToken:
                        params['finishPasswordResetToken'],
                    newPassword: params['newPassword'],
                  ),
        ),
        'hasAccount': _is.MethodConnector(
          name: 'hasAccount',
          params: {},
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['emailIdp'] as _iuc1hd5t.EmailIdpEndpoint)
                  .hasAccount(session),
        ),
      },
    );
    connectors['jwtRefresh'] = _is.EndpointConnector(
      name: 'jwtRefresh',
      endpoint: endpoints['jwtRefresh']!,
      methodConnectors: {
        'refreshAccessToken': _is.MethodConnector(
          name: 'refreshAccessToken',
          params: {
            'refreshToken': _is.ParameterDescription(
              name: 'refreshToken',
              type: _is.getType<String?>(),
              nullable: true,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['jwtRefresh'] as _inwq3ztq.JwtRefreshEndpoint)
                      .refreshAccessToken(
                        session,
                        refreshToken: params['refreshToken'],
                      ),
        ),
      },
    );
    connectors['userProfileEdit'] = _is.EndpointConnector(
      name: 'userProfileEdit',
      endpoint: endpoints['userProfileEdit']!,
      methodConnectors: {
        'setUserImage': _is.MethodConnector(
          name: 'setUserImage',
          params: {
            'image': _is.ParameterDescription(
              name: 'image',
              type: _is.getType<_idt.ByteData>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['userProfileEdit']
                          as _ije0zjyg.UserProfileEditEndpoint)
                      .setUserImage(
                        session,
                        params['image'],
                      ),
        ),
        'removeUserImage': _is.MethodConnector(
          name: 'removeUserImage',
          params: {},
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['userProfileEdit']
                          as _ije0zjyg.UserProfileEditEndpoint)
                      .removeUserImage(session),
        ),
        'changeUserName': _is.MethodConnector(
          name: 'changeUserName',
          params: {
            'userName': _is.ParameterDescription(
              name: 'userName',
              type: _is.getType<String?>(),
              nullable: true,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['userProfileEdit']
                          as _ije0zjyg.UserProfileEditEndpoint)
                      .changeUserName(
                        session,
                        params['userName'],
                      ),
        ),
        'changeFullName': _is.MethodConnector(
          name: 'changeFullName',
          params: {
            'fullName': _is.ParameterDescription(
              name: 'fullName',
              type: _is.getType<String?>(),
              nullable: true,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['userProfileEdit']
                          as _ije0zjyg.UserProfileEditEndpoint)
                      .changeFullName(
                        session,
                        params['fullName'],
                      ),
        ),
        'get': _is.MethodConnector(
          name: 'get',
          params: {},
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['userProfileEdit']
                          as _ije0zjyg.UserProfileEditEndpoint)
                      .get(session),
        ),
      },
    );
    connectors['greeting'] = _is.EndpointConnector(
      name: 'greeting',
      endpoint: endpoints['greeting']!,
      methodConnectors: {
        'hello': _is.MethodConnector(
          name: 'hello',
          params: {
            'name': _is.ParameterDescription(
              name: 'name',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['greeting'] as _il624ik7.GreetingEndpoint).hello(
                    session,
                    params['name'],
                  ),
        ),
      },
    );
    connectors['profileDetails'] = _is.EndpointConnector(
      name: 'profileDetails',
      endpoint: endpoints['profileDetails']!,
      methodConnectors: {
        'get': _is.MethodConnector(
          name: 'get',
          params: {},
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['profileDetails']
                          as _iev396g5.ProfileDetailsEndpoint)
                      .get(session),
        ),
        'save': _is.MethodConnector(
          name: 'save',
          params: {
            'firstName': _is.ParameterDescription(
              name: 'firstName',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'lastName': _is.ParameterDescription(
              name: 'lastName',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'birthday': _is.ParameterDescription(
              name: 'birthday',
              type: _is.getType<DateTime>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['profileDetails']
                          as _iev396g5.ProfileDetailsEndpoint)
                      .save(
                        session,
                        firstName: params['firstName'],
                        lastName: params['lastName'],
                        birthday: params['birthday'],
                      ),
        ),
      },
    );
    connectors['siteConnection'] = _is.EndpointConnector(
      name: 'siteConnection',
      endpoint: endpoints['siteConnection']!,
      methodConnectors: {
        'connect': _is.MethodStreamConnector(
          name: 'connect',
          params: {},
          streamParams: {
            'pings': _is.StreamParameterDescription<_ijzkrm2i.SitePing>(
              name: 'pings',
              nullable: false,
            ),
          },
          returnType: _is.MethodStreamReturnType.streamType,
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
                Map<String, Stream> streamParams,
              ) =>
                  (endpoints['siteConnection']
                          as _iy15yji6.SiteConnectionEndpoint)
                      .connect(
                        session,
                        streamParams['pings']!.cast<_ijzkrm2i.SitePing>(),
                      ),
        ),
      },
    );
    connectors['siteEnrollment'] = _is.EndpointConnector(
      name: 'siteEnrollment',
      endpoint: endpoints['siteEnrollment']!,
      methodConnectors: {
        'listSiteAdminCandidates': _is.MethodConnector(
          name: 'listSiteAdminCandidates',
          params: {
            'email': _is.ParameterDescription(
              name: 'email',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'password': _is.ParameterDescription(
              name: 'password',
              type: _is.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['siteEnrollment']
                          as _ii29ea4g.SiteEnrollmentEndpoint)
                      .listSiteAdminCandidates(
                        session,
                        email: params['email'],
                        password: params['password'],
                      ),
        ),
        'enroll': _is.MethodConnector(
          name: 'enroll',
          params: {
            'email': _is.ParameterDescription(
              name: 'email',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'password': _is.ParameterDescription(
              name: 'password',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'siteId': _is.ParameterDescription(
              name: 'siteId',
              type: _is.getType<int?>(),
              nullable: true,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['siteEnrollment']
                          as _ii29ea4g.SiteEnrollmentEndpoint)
                      .enroll(
                        session,
                        email: params['email'],
                        password: params['password'],
                        siteId: params['siteId'],
                      ),
        ),
      },
    );
    connectors['sitesAdmin'] = _is.EndpointConnector(
      name: 'sitesAdmin',
      endpoint: endpoints['sitesAdmin']!,
      methodConnectors: {
        'createSite': _is.MethodConnector(
          name: 'createSite',
          params: {
            'name': _is.ParameterDescription(
              name: 'name',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'street': _is.ParameterDescription(
              name: 'street',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'zipCode': _is.ParameterDescription(
              name: 'zipCode',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'city': _is.ParameterDescription(
              name: 'city',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'country': _is.ParameterDescription(
              name: 'country',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'companyEmail': _is.ParameterDescription(
              name: 'companyEmail',
              type: _is.getType<String>(),
              nullable: false,
            ),
            'firstAdminId': _is.ParameterDescription(
              name: 'firstAdminId',
              type: _is.getType<_is.UuidValue>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['sitesAdmin'] as _i6ok1ur0.SitesAdminEndpoint)
                      .createSite(
                        session,
                        name: params['name'],
                        street: params['street'],
                        zipCode: params['zipCode'],
                        city: params['city'],
                        country: params['country'],
                        companyEmail: params['companyEmail'],
                        firstAdminId: params['firstAdminId'],
                      ),
        ),
        'listSites': _is.MethodConnector(
          name: 'listSites',
          params: {
            'query': _is.ParameterDescription(
              name: 'query',
              type: _is.getType<String?>(),
              nullable: true,
            ),
            'offset': _is.ParameterDescription(
              name: 'offset',
              type: _is.getType<int>(),
              nullable: false,
            ),
            'limit': _is.ParameterDescription(
              name: 'limit',
              type: _is.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['sitesAdmin'] as _i6ok1ur0.SitesAdminEndpoint)
                      .listSites(
                        session,
                        query: params['query'],
                        offset: params['offset'],
                        limit: params['limit'],
                      ),
        ),
        'countSites': _is.MethodConnector(
          name: 'countSites',
          params: {
            'query': _is.ParameterDescription(
              name: 'query',
              type: _is.getType<String?>(),
              nullable: true,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['sitesAdmin'] as _i6ok1ur0.SitesAdminEndpoint)
                      .countSites(
                        session,
                        query: params['query'],
                      ),
        ),
        'getSite': _is.MethodConnector(
          name: 'getSite',
          params: {
            'siteId': _is.ParameterDescription(
              name: 'siteId',
              type: _is.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['sitesAdmin'] as _i6ok1ur0.SitesAdminEndpoint)
                      .getSite(
                        session,
                        siteId: params['siteId'],
                      ),
        ),
        'revokeSiteConnection': _is.MethodConnector(
          name: 'revokeSiteConnection',
          params: {
            'siteId': _is.ParameterDescription(
              name: 'siteId',
              type: _is.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _is.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['sitesAdmin'] as _i6ok1ur0.SitesAdminEndpoint)
                      .revokeSiteConnection(
                        session,
                        siteId: params['siteId'],
                      ),
        ),
      },
    );
    modules['serverpod_auth_idp'] = _iais.Endpoints()
      ..initializeEndpoints(server);
    modules['serverpod_auth_core'] = _iacs.Endpoints()
      ..initializeEndpoints(server);
  }
}
