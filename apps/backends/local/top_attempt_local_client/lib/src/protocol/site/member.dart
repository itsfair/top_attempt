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
import 'package:serverpod_auth_core_client/serverpod_auth_core_client.dart'
    as _iacc;
import 'package:serverpod_client/serverpod_client.dart' as _isc;
import 'package:top_attempt_local_client/src/protocol/protocol.dart'
    as _i3m9u5jf;

/// Local person directory of this site. Every person of the site appears
/// here — either as plain member (no local login) or with a linked local
/// AuthUser (site admin / staff with login). One row per global person.
abstract class Member
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  Member._({
    this.id,
    required this.globalAuthUserId,
    required this.localAuthUserId,
    this.localAuthUser,
    this.email,
    this.fullName,
    String? role,
    bool? active,
    DateTime? createdAt,
  }) : role = role ?? 'member',
       active = active ?? true,
       createdAt = createdAt ?? DateTime.now();

  factory Member({
    int? id,
    required _isc.UuidValue globalAuthUserId,
    required _isc.UuidValue localAuthUserId,
    _iacc.AuthUser? localAuthUser,
    String? email,
    String? fullName,
    String? role,
    bool? active,
    DateTime? createdAt,
  }) = _MemberImpl;

  factory Member.fromJson(Map<String, dynamic> jsonSerialization) {
    return Member(
      id: jsonSerialization['id'] as int?,
      globalAuthUserId: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['globalAuthUserId'],
      ),
      localAuthUserId: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['localAuthUserId'],
      ),
      localAuthUser: jsonSerialization['localAuthUser'] == null
          ? null
          : _i3m9u5jf.Protocol().deserialize<_iacc.AuthUser>(
              jsonSerialization['localAuthUser'],
            ),
      email: jsonSerialization['email'] as String?,
      fullName: jsonSerialization['fullName'] as String?,
      role: jsonSerialization['role'] as String?,
      active: jsonSerialization['active'] == null
          ? null
          : _isc.BoolJsonExtension.fromJson(jsonSerialization['active']),
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  /// The GLOBAL authUserId of the person — the exchange key with the
  /// global instance (and later used by the door-opening flow: ESP32 ->
  /// local backend -> member lookup). This is NOT the local AuthUser id.
  _isc.UuidValue globalAuthUserId;

  _isc.UuidValue localAuthUserId;

  /// Link to the local login account (site admin / staff); null for plain
  /// members without login. The local AuthUser uuid is local-only and must
  /// never be used for cross-instance matching.
  _iacc.AuthUser? localAuthUser;

  /// Mirrored profile data from the global instance.
  String? email;

  String? fullName;

  /// Role as string, mirrored from the global `SiteRole` (member/staff/
  /// siteAdmin) — synced; the local backend derives privileges from it.
  String role;

  /// Mirrored active state of the global membership.
  bool active;

  /// When the local row was created (at enrollment for the site admin or
  /// when a membership sync event arrived).
  DateTime createdAt;

  /// Returns a shallow copy of this [Member]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  Member copyWith({
    int? id,
    _isc.UuidValue? globalAuthUserId,
    _isc.UuidValue? localAuthUserId,
    _iacc.AuthUser? localAuthUser,
    String? email,
    String? fullName,
    String? role,
    bool? active,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'Member',
      if (id != null) 'id': id,
      'globalAuthUserId': globalAuthUserId.toJson(),
      'localAuthUserId': localAuthUserId.toJson(),
      if (localAuthUser != null) 'localAuthUser': localAuthUser?.toJson(),
      if (email != null) 'email': email,
      if (fullName != null) 'fullName': fullName,
      'role': role,
      'active': active,
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'Member',
      if (id != null) 'id': id,
      'globalAuthUserId': globalAuthUserId.toJson(),
      'localAuthUserId': localAuthUserId.toJson(),
      if (localAuthUser != null) 'localAuthUser': localAuthUser?.toJson(),
      if (email != null) 'email': email,
      if (fullName != null) 'fullName': fullName,
      'role': role,
      'active': active,
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _MemberImpl extends Member {
  _MemberImpl({
    int? id,
    required _isc.UuidValue globalAuthUserId,
    required _isc.UuidValue localAuthUserId,
    _iacc.AuthUser? localAuthUser,
    String? email,
    String? fullName,
    String? role,
    bool? active,
    DateTime? createdAt,
  }) : super._(
         id: id,
         globalAuthUserId: globalAuthUserId,
         localAuthUserId: localAuthUserId,
         localAuthUser: localAuthUser,
         email: email,
         fullName: fullName,
         role: role,
         active: active,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [Member]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  Member copyWith({
    Object? id = _Undefined,
    _isc.UuidValue? globalAuthUserId,
    _isc.UuidValue? localAuthUserId,
    Object? localAuthUser = _Undefined,
    Object? email = _Undefined,
    Object? fullName = _Undefined,
    String? role,
    bool? active,
    DateTime? createdAt,
  }) {
    return Member(
      id: id is int? ? id : this.id,
      globalAuthUserId: globalAuthUserId ?? this.globalAuthUserId,
      localAuthUserId: localAuthUserId ?? this.localAuthUserId,
      localAuthUser: localAuthUser is _iacc.AuthUser?
          ? localAuthUser
          : this.localAuthUser?.copyWith(),
      email: email is String? ? email : this.email,
      fullName: fullName is String? ? fullName : this.fullName,
      role: role ?? this.role,
      active: active ?? this.active,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
