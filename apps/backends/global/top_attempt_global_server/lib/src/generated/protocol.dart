/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters
// ignore_for_file: invalid_use_of_internal_member
// ignore_for_file: dead_code, unnecessary_type_check

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:serverpod/protocol.dart' as _isp;
import 'package:serverpod/serverpod.dart' as _is;
import 'package:serverpod_auth_core_server/serverpod_auth_core_server.dart'
    as _iacs;
import 'package:serverpod_auth_idp_server/serverpod_auth_idp_server.dart'
    as _iais;
import 'package:top_attempt_global_server/src/generated/sites/site.dart'
    as _ieymp251;
import 'package:top_attempt_global_server/src/generated/sites/site_admin_membership_candidate.dart'
    as _iscolcca;
import 'admin/user_admin_exception.dart' as _ipzw5jrh;
import 'admin/user_admin_page.dart' as _ib47g35s;
import 'admin/user_admin_summary.dart' as _idu811wg;
import 'greetings/greeting.dart' as _izw8z7ou;
import 'profile/profile_details.dart' as _is7ofcfc;
import 'sites/site.dart' as _ilajh623;
import 'sites/site_admin_exception.dart' as _ie4pusq6;
import 'sites/site_admin_membership_candidate.dart' as _ib7ux6dk;
import 'sites/site_device_session.dart' as _iuoqdo0q;
import 'sites/site_enrollment_info.dart' as _itnt8dpd;
import 'sites/site_event.dart' as _iw3gj98k;
import 'sites/site_membership.dart' as _iioeq9li;
import 'sites/site_ping.dart' as _icfqqkiq;
import 'sites/site_role.dart' as _iuk2ydaa;
import 'sites/site_setup_status.dart' as _ijgbvr7h;
import 'sites/site_transfer_info.dart' as _i1cuvu3u;
export 'admin/user_admin_exception.dart';
export 'admin/user_admin_page.dart';
export 'admin/user_admin_summary.dart';
export 'greetings/greeting.dart';
export 'profile/profile_details.dart';
export 'sites/site.dart';
export 'sites/site_admin_exception.dart';
export 'sites/site_admin_membership_candidate.dart';
export 'sites/site_device_session.dart';
export 'sites/site_enrollment_info.dart';
export 'sites/site_event.dart';
export 'sites/site_membership.dart';
export 'sites/site_ping.dart';
export 'sites/site_role.dart';
export 'sites/site_setup_status.dart';
export 'sites/site_transfer_info.dart';

class Protocol extends _is.DatabaseSerializationManager {
  Protocol._();

  factory Protocol() => _instance;

  static final Protocol _instance = Protocol._().._registerHostProtocols();

  static List<_isp.TableDefinition> get targetTableDefinitions => [
    _isp.TableDefinition(
      name: 'profile_details',
      dartName: 'ProfileDetails',
      schema: 'public',
      module: 'top_attempt_global',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'serial',
        ),
        _isp.ColumnDefinition(
          name: 'authUserId',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isp.ColumnDefinition(
          name: 'firstName',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _isp.ColumnDefinition(
          name: 'lastName',
          columnType: _isp.ColumnType.text,
          isNullable: true,
          dartType: 'String?',
        ),
        _isp.ColumnDefinition(
          name: 'birthday',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
      ],
      foreignKeys: [
        _isp.ForeignKeyDefinition(
          constraintName: 'profile_details_fk_0',
          columns: ['authUserId'],
          referenceTable: 'serverpod_auth_core_user',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.cascade,
          matchType: null,
        ),
      ],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'profile_details_auth_user_unique_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'authUserId',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'site_device_sessions',
      dartName: 'SiteDeviceSession',
      schema: 'public',
      module: 'top_attempt_global',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'serial',
        ),
        _isp.ColumnDefinition(
          name: 'siteId',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'serverSideSessionId',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isp.ColumnDefinition(
          name: 'createdAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
      ],
      foreignKeys: [
        _isp.ForeignKeyDefinition(
          constraintName: 'site_device_sessions_fk_0',
          columns: ['siteId'],
          referenceTable: 'sites',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.cascade,
          matchType: null,
        ),
      ],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'site_unique_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'siteId',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'site_memberships',
      dartName: 'SiteMembership',
      schema: 'public',
      module: 'top_attempt_global',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'serial',
        ),
        _isp.ColumnDefinition(
          name: 'siteId',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _isp.ColumnDefinition(
          name: 'authUserId',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isp.ColumnDefinition(
          name: 'role',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'protocol:SiteRole',
          columnDefault: '\'member\'',
        ),
        _isp.ColumnDefinition(
          name: 'active',
          columnType: _isp.ColumnType.boolean,
          isNullable: false,
          dartType: 'bool',
        ),
        _isp.ColumnDefinition(
          name: 'createdAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
      ],
      foreignKeys: [
        _isp.ForeignKeyDefinition(
          constraintName: 'site_memberships_fk_0',
          columns: ['siteId'],
          referenceTable: 'sites',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.cascade,
          matchType: null,
        ),
        _isp.ForeignKeyDefinition(
          constraintName: 'site_memberships_fk_1',
          columns: ['authUserId'],
          referenceTable: 'serverpod_auth_core_user',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.cascade,
          matchType: null,
        ),
      ],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'site_role_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'siteId',
            ),
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'authUserId',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    _isp.TableDefinition(
      name: 'sites',
      dartName: 'Site',
      schema: 'public',
      module: 'top_attempt_global',
      columns: [
        _isp.ColumnDefinition(
          name: 'id',
          columnType: _isp.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'serial',
        ),
        _isp.ColumnDefinition(
          name: 'name',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'street',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'zipCode',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'city',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'country',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'companyEmail',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _isp.ColumnDefinition(
          name: 'status',
          columnType: _isp.ColumnType.text,
          isNullable: false,
          dartType: 'protocol:SiteSetupStatus',
        ),
        _isp.ColumnDefinition(
          name: 'firstAdminId',
          columnType: _isp.ColumnType.uuid,
          isNullable: false,
          dartType: 'UuidValue',
        ),
        _isp.ColumnDefinition(
          name: 'registeredAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
        _isp.ColumnDefinition(
          name: 'lastSeenAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
        _isp.ColumnDefinition(
          name: 'createdAt',
          columnType: _isp.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
      ],
      foreignKeys: [
        _isp.ForeignKeyDefinition(
          constraintName: 'sites_fk_0',
          columns: ['firstAdminId'],
          referenceTable: 'serverpod_auth_core_user',
          referenceTableSchema: 'public',
          referenceColumns: ['id'],
          onUpdate: _isp.ForeignKeyAction.noAction,
          onDelete: _isp.ForeignKeyAction.noAction,
          matchType: null,
        ),
      ],
      indexes: [
        _isp.IndexDefinition(
          indexName: 'company_email_idx',
          tableSpace: null,
          elements: [
            _isp.IndexElementDefinition(
              type: _isp.IndexElementDefinitionType.column,
              definition: 'companyEmail',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    ..._iais.Protocol.targetTableDefinitions,
    ..._iacs.Protocol.targetTableDefinitions,
    ..._isp.Protocol.targetTableDefinitions,
  ];

  static String? getClassNameFromObjectJson(dynamic data) {
    if (data is! Map) return null;
    final className = data['__className__'] as String?;
    return className;
  }

  @override
  T deserialize<T>(
    dynamic data, [
    Type? t,
  ]) {
    t ??= T;

    final dataClassName = getClassNameFromObjectJson(data);
    if (dataClassName != null && dataClassName != getClassNameForType(t)) {
      try {
        return deserializeByClassName({
          'className': dataClassName,
          'data': data,
        });
      } on _is.DeserializationClassNameNotFoundException catch (_) {
        // If the className is not recognized (e.g., older client receiving
        // data with a new subtype), fall back to deserializing without the
        // className, using the expected type T.
      }
    }

    if (t == _ipzw5jrh.UserAdminException) {
      return _ipzw5jrh.UserAdminException.fromJson(data) as T;
    }
    if (t == _ib47g35s.AdminUserPage) {
      return _ib47g35s.AdminUserPage.fromJson(data) as T;
    }
    if (t == _idu811wg.AdminUserSummary) {
      return _idu811wg.AdminUserSummary.fromJson(data) as T;
    }
    if (t == _izw8z7ou.Greeting) {
      return _izw8z7ou.Greeting.fromJson(data) as T;
    }
    if (t == _is7ofcfc.ProfileDetails) {
      return _is7ofcfc.ProfileDetails.fromJson(data) as T;
    }
    if (t == _ilajh623.Site) {
      return _ilajh623.Site.fromJson(data) as T;
    }
    if (t == _ie4pusq6.SiteAdminException) {
      return _ie4pusq6.SiteAdminException.fromJson(data) as T;
    }
    if (t == _ib7ux6dk.SiteAdminMembershipCandidate) {
      return _ib7ux6dk.SiteAdminMembershipCandidate.fromJson(data) as T;
    }
    if (t == _iuoqdo0q.SiteDeviceSession) {
      return _iuoqdo0q.SiteDeviceSession.fromJson(data) as T;
    }
    if (t == _itnt8dpd.SiteEnrollmentInfo) {
      return _itnt8dpd.SiteEnrollmentInfo.fromJson(data) as T;
    }
    if (t == _iw3gj98k.SiteEvent) {
      return _iw3gj98k.SiteEvent.fromJson(data) as T;
    }
    if (t == _iioeq9li.SiteMembership) {
      return _iioeq9li.SiteMembership.fromJson(data) as T;
    }
    if (t == _icfqqkiq.SitePing) {
      return _icfqqkiq.SitePing.fromJson(data) as T;
    }
    if (t == _iuk2ydaa.SiteRole) {
      return _iuk2ydaa.SiteRole.fromJson(data) as T;
    }
    if (t == _ijgbvr7h.SiteSetupStatus) {
      return _ijgbvr7h.SiteSetupStatus.fromJson(data) as T;
    }
    if (t == _i1cuvu3u.SiteTransferInfo) {
      return _i1cuvu3u.SiteTransferInfo.fromJson(data) as T;
    }
    if (t == _is.getType<_ipzw5jrh.UserAdminException?>()) {
      return (data != null ? _ipzw5jrh.UserAdminException.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_ib47g35s.AdminUserPage?>()) {
      return (data != null ? _ib47g35s.AdminUserPage.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_idu811wg.AdminUserSummary?>()) {
      return (data != null ? _idu811wg.AdminUserSummary.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_izw8z7ou.Greeting?>()) {
      return (data != null ? _izw8z7ou.Greeting.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_is7ofcfc.ProfileDetails?>()) {
      return (data != null ? _is7ofcfc.ProfileDetails.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_ilajh623.Site?>()) {
      return (data != null ? _ilajh623.Site.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_ie4pusq6.SiteAdminException?>()) {
      return (data != null ? _ie4pusq6.SiteAdminException.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_ib7ux6dk.SiteAdminMembershipCandidate?>()) {
      return (data != null
              ? _ib7ux6dk.SiteAdminMembershipCandidate.fromJson(data)
              : null)
          as T;
    }
    if (t == _is.getType<_iuoqdo0q.SiteDeviceSession?>()) {
      return (data != null ? _iuoqdo0q.SiteDeviceSession.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_itnt8dpd.SiteEnrollmentInfo?>()) {
      return (data != null ? _itnt8dpd.SiteEnrollmentInfo.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_iw3gj98k.SiteEvent?>()) {
      return (data != null ? _iw3gj98k.SiteEvent.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_iioeq9li.SiteMembership?>()) {
      return (data != null ? _iioeq9li.SiteMembership.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_icfqqkiq.SitePing?>()) {
      return (data != null ? _icfqqkiq.SitePing.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_iuk2ydaa.SiteRole?>()) {
      return (data != null ? _iuk2ydaa.SiteRole.fromJson(data) : null) as T;
    }
    if (t == _is.getType<_ijgbvr7h.SiteSetupStatus?>()) {
      return (data != null ? _ijgbvr7h.SiteSetupStatus.fromJson(data) : null)
          as T;
    }
    if (t == _is.getType<_i1cuvu3u.SiteTransferInfo?>()) {
      return (data != null ? _i1cuvu3u.SiteTransferInfo.fromJson(data) : null)
          as T;
    }
    if (t == List<_idu811wg.AdminUserSummary>) {
      return (data as List)
              .map((e) => deserialize<_idu811wg.AdminUserSummary>(e))
              .toList()
          as T;
    }
    if (t == List<String>) {
      return (data as List).map((e) => deserialize<String>(e)).toList() as T;
    }
    if (t == List<_ib7ux6dk.SiteAdminMembershipCandidate>) {
      return (data as List)
              .map(
                (e) => deserialize<_ib7ux6dk.SiteAdminMembershipCandidate>(e),
              )
              .toList()
          as T;
    }
    if (t == List<_iscolcca.SiteAdminMembershipCandidate>) {
      return (data as List)
              .map(
                (e) => deserialize<_iscolcca.SiteAdminMembershipCandidate>(e),
              )
              .toList()
          as T;
    }
    if (t == List<_ieymp251.Site>) {
      return (data as List).map((e) => deserialize<_ieymp251.Site>(e)).toList()
          as T;
    }
    try {
      return _iais.Protocol().deserialize<T>(data, t);
    } on _is.DeserializationTypeNotFoundException catch (_) {}
    try {
      return _iacs.Protocol().deserialize<T>(data, t);
    } on _is.DeserializationTypeNotFoundException catch (_) {}
    try {
      return _isp.Protocol().deserialize<T>(data, t);
    } on _is.DeserializationTypeNotFoundException catch (_) {}
    return super.deserialize<T>(data, t);
  }

  static String? getClassNameForType(Type type) {
    return switch (type) {
      _ipzw5jrh.UserAdminException => 'UserAdminException',
      _ib47g35s.AdminUserPage => 'AdminUserPage',
      _idu811wg.AdminUserSummary => 'AdminUserSummary',
      _izw8z7ou.Greeting => 'Greeting',
      _is7ofcfc.ProfileDetails => 'ProfileDetails',
      _ilajh623.Site => 'Site',
      _ie4pusq6.SiteAdminException => 'SiteAdminException',
      _ib7ux6dk.SiteAdminMembershipCandidate => 'SiteAdminMembershipCandidate',
      _iuoqdo0q.SiteDeviceSession => 'SiteDeviceSession',
      _itnt8dpd.SiteEnrollmentInfo => 'SiteEnrollmentInfo',
      _iw3gj98k.SiteEvent => 'SiteEvent',
      _iioeq9li.SiteMembership => 'SiteMembership',
      _icfqqkiq.SitePing => 'SitePing',
      _iuk2ydaa.SiteRole => 'SiteRole',
      _ijgbvr7h.SiteSetupStatus => 'SiteSetupStatus',
      _i1cuvu3u.SiteTransferInfo => 'SiteTransferInfo',
      _ => null,
    };
  }

  @override
  String? getClassNameForObject(Object? data) {
    String? className = super.getClassNameForObject(data);
    if (className != null) return className;

    if (data is Map<String, dynamic> && data['__className__'] is String) {
      return (data['__className__'] as String).replaceFirst(
        'top_attempt_global.',
        '',
      );
    }

    switch (data) {
      case _ipzw5jrh.UserAdminException():
        return 'UserAdminException';
      case _ib47g35s.AdminUserPage():
        return 'AdminUserPage';
      case _idu811wg.AdminUserSummary():
        return 'AdminUserSummary';
      case _izw8z7ou.Greeting():
        return 'Greeting';
      case _is7ofcfc.ProfileDetails():
        return 'ProfileDetails';
      case _ilajh623.Site():
        return 'Site';
      case _ie4pusq6.SiteAdminException():
        return 'SiteAdminException';
      case _ib7ux6dk.SiteAdminMembershipCandidate():
        return 'SiteAdminMembershipCandidate';
      case _iuoqdo0q.SiteDeviceSession():
        return 'SiteDeviceSession';
      case _itnt8dpd.SiteEnrollmentInfo():
        return 'SiteEnrollmentInfo';
      case _iw3gj98k.SiteEvent():
        return 'SiteEvent';
      case _iioeq9li.SiteMembership():
        return 'SiteMembership';
      case _icfqqkiq.SitePing():
        return 'SitePing';
      case _iuk2ydaa.SiteRole():
        return 'SiteRole';
      case _ijgbvr7h.SiteSetupStatus():
        return 'SiteSetupStatus';
      case _i1cuvu3u.SiteTransferInfo():
        return 'SiteTransferInfo';
    }
    className = _iais.Protocol().getClassNameForObject(data);
    if (className != null) {
      return className.contains('.')
          ? className
          : 'serverpod_auth_idp.$className';
    }
    className = _iacs.Protocol().getClassNameForObject(data);
    if (className != null) {
      return className.contains('.')
          ? className
          : 'serverpod_auth_core.$className';
    }
    className = _isp.Protocol().getClassNameForObject(data);
    if (className != null) {
      return className.contains('.') ? className : 'serverpod.$className';
    }
    return null;
  }

  @override
  dynamic deserializeByClassName(Map<String, dynamic> data) {
    var dataClassName = data['className'];
    if (dataClassName is! String) {
      return super.deserializeByClassName(data);
    }
    if (dataClassName == 'UserAdminException') {
      return deserialize<_ipzw5jrh.UserAdminException>(data['data']);
    }
    if (dataClassName == 'AdminUserPage') {
      return deserialize<_ib47g35s.AdminUserPage>(data['data']);
    }
    if (dataClassName == 'AdminUserSummary') {
      return deserialize<_idu811wg.AdminUserSummary>(data['data']);
    }
    if (dataClassName == 'Greeting') {
      return deserialize<_izw8z7ou.Greeting>(data['data']);
    }
    if (dataClassName == 'ProfileDetails') {
      return deserialize<_is7ofcfc.ProfileDetails>(data['data']);
    }
    if (dataClassName == 'Site') {
      return deserialize<_ilajh623.Site>(data['data']);
    }
    if (dataClassName == 'SiteAdminException') {
      return deserialize<_ie4pusq6.SiteAdminException>(data['data']);
    }
    if (dataClassName == 'SiteAdminMembershipCandidate') {
      return deserialize<_ib7ux6dk.SiteAdminMembershipCandidate>(data['data']);
    }
    if (dataClassName == 'SiteDeviceSession') {
      return deserialize<_iuoqdo0q.SiteDeviceSession>(data['data']);
    }
    if (dataClassName == 'SiteEnrollmentInfo') {
      return deserialize<_itnt8dpd.SiteEnrollmentInfo>(data['data']);
    }
    if (dataClassName == 'SiteEvent') {
      return deserialize<_iw3gj98k.SiteEvent>(data['data']);
    }
    if (dataClassName == 'SiteMembership') {
      return deserialize<_iioeq9li.SiteMembership>(data['data']);
    }
    if (dataClassName == 'SitePing') {
      return deserialize<_icfqqkiq.SitePing>(data['data']);
    }
    if (dataClassName == 'SiteRole') {
      return deserialize<_iuk2ydaa.SiteRole>(data['data']);
    }
    if (dataClassName == 'SiteSetupStatus') {
      return deserialize<_ijgbvr7h.SiteSetupStatus>(data['data']);
    }
    if (dataClassName == 'SiteTransferInfo') {
      return deserialize<_i1cuvu3u.SiteTransferInfo>(data['data']);
    }
    if (dataClassName.startsWith('serverpod_auth_idp.')) {
      data['className'] = dataClassName.substring(19);
      return _iais.Protocol().deserializeByClassName(data);
    }
    if (dataClassName.startsWith('serverpod_auth_core.')) {
      data['className'] = dataClassName.substring(20);
      return _iacs.Protocol().deserializeByClassName(data);
    }
    if (dataClassName.startsWith('serverpod.')) {
      data['className'] = dataClassName.substring(10);
      return _isp.Protocol().deserializeByClassName(data);
    }
    return super.deserializeByClassName(data);
  }

  void _registerHostProtocols() {
    _iais.Protocol().registerHostProtocol('top_attempt_global', this);
    _iacs.Protocol().registerHostProtocol('top_attempt_global', this);
  }

  @override
  _is.Table? getTableForType(Type t) {
    {
      var table = _iais.Protocol().getTableForType(t);
      if (table != null) {
        return table;
      }
    }
    {
      var table = _iacs.Protocol().getTableForType(t);
      if (table != null) {
        return table;
      }
    }
    {
      var table = _isp.Protocol().getTableForType(t);
      if (table != null) {
        return table;
      }
    }
    switch (t) {
      case _is7ofcfc.ProfileDetails:
        return _is7ofcfc.ProfileDetails.t;
      case _ilajh623.Site:
        return _ilajh623.Site.t;
      case _iuoqdo0q.SiteDeviceSession:
        return _iuoqdo0q.SiteDeviceSession.t;
      case _iioeq9li.SiteMembership:
        return _iioeq9li.SiteMembership.t;
    }
    return null;
  }

  @override
  List<_isp.TableDefinition> getTargetTableDefinitions() =>
      targetTableDefinitions;

  @override
  String getModuleName() => 'top_attempt_global';

  /// Maps any `Record`s known to this [Protocol] to their JSON representation
  ///
  /// Throws in case the record type is not known.
  ///
  /// This method will return `null` (only) for `null` inputs.
  Map<String, dynamic>? mapRecordToJson(Record? record) {
    if (record == null) {
      return null;
    }
    try {
      return _iais.Protocol().mapRecordToJson(record);
    } catch (_) {}
    try {
      return _iacs.Protocol().mapRecordToJson(record);
    } catch (_) {}
    throw Exception('Unsupported record type ${record.runtimeType}');
  }
}
