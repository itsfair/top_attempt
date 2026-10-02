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
import 'package:top_attempt_global_client/src/protocol/protocol.dart'
    as _i00og34q;

/// Person directory of the global instance — includes a duplicate of the
/// registration email plus the manually maintained profile data. The
/// built-in Serverpod UserProfile feature is deliberately bypassed; our
/// own `memberProfile` endpoints maintain this table. Profile images go
/// into RustFS at `member_images/<authUserId>.<ext>` (one object per
/// person, overwritten on change; uploads are JPEG-only for now).
/// Structural note: locally the same model exists with an OPTIONAL auth
/// link (plain members have no local login) plus a required
/// `globalAuthUserId` — this id is the same person id, so both systems
/// share image names and identity semantics.
abstract class MemberProfile
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  MemberProfile._({
    this.id,
    required this.authUserId,
    this.authUser,
    required this.email,
    this.firstName,
    this.lastName,
    this.birthday,
    this.imageUrl,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory MemberProfile({
    int? id,
    required _isc.UuidValue authUserId,
    _iacc.AuthUser? authUser,
    required String email,
    String? firstName,
    String? lastName,
    DateTime? birthday,
    String? imageUrl,
    DateTime? createdAt,
  }) = _MemberProfileImpl;

  factory MemberProfile.fromJson(Map<String, dynamic> jsonSerialization) {
    return MemberProfile(
      id: jsonSerialization['id'] as int?,
      authUserId: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['authUserId'],
      ),
      authUser: jsonSerialization['authUser'] == null
          ? null
          : _i00og34q.Protocol().deserialize<_iacc.AuthUser>(
              jsonSerialization['authUser'],
            ),
      email: jsonSerialization['email'] as String,
      firstName: jsonSerialization['firstName'] as String?,
      lastName: jsonSerialization['lastName'] as String?,
      birthday: jsonSerialization['birthday'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(jsonSerialization['birthday']),
      imageUrl: jsonSerialization['imageUrl'] as String?,
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  _isc.UuidValue authUserId;

  /// The auth user this profile belongs to (required via unique index
  /// and code-level checks; model relations must be nullable).
  _iacc.AuthUser? authUser;

  /// Duplicate of the registration email (accepted; the only intended
  /// duplication versus the auth tables).
  String email;

  /// Profile data (completion after registration; names 1-60 chars,
  /// birthday as UTC-midnight date sentinel).
  String? firstName;

  String? lastName;

  DateTime? birthday;

  /// Public URL of the profile image (RustFS; null until set).
  String? imageUrl;

  /// When the profile row was created (sparse at registration via hook).
  DateTime createdAt;

  /// Returns a shallow copy of this [MemberProfile]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  MemberProfile copyWith({
    int? id,
    _isc.UuidValue? authUserId,
    _iacc.AuthUser? authUser,
    String? email,
    String? firstName,
    String? lastName,
    DateTime? birthday,
    String? imageUrl,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'MemberProfile',
      if (id != null) 'id': id,
      'authUserId': authUserId.toJson(),
      if (authUser != null) 'authUser': authUser?.toJson(),
      'email': email,
      if (firstName != null) 'firstName': firstName,
      if (lastName != null) 'lastName': lastName,
      if (birthday != null) 'birthday': birthday?.toJson(),
      if (imageUrl != null) 'imageUrl': imageUrl,
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'MemberProfile',
      if (id != null) 'id': id,
      'authUserId': authUserId.toJson(),
      if (authUser != null) 'authUser': authUser?.toJson(),
      'email': email,
      if (firstName != null) 'firstName': firstName,
      if (lastName != null) 'lastName': lastName,
      if (birthday != null) 'birthday': birthday?.toJson(),
      if (imageUrl != null) 'imageUrl': imageUrl,
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _MemberProfileImpl extends MemberProfile {
  _MemberProfileImpl({
    int? id,
    required _isc.UuidValue authUserId,
    _iacc.AuthUser? authUser,
    required String email,
    String? firstName,
    String? lastName,
    DateTime? birthday,
    String? imageUrl,
    DateTime? createdAt,
  }) : super._(
         id: id,
         authUserId: authUserId,
         authUser: authUser,
         email: email,
         firstName: firstName,
         lastName: lastName,
         birthday: birthday,
         imageUrl: imageUrl,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [MemberProfile]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  MemberProfile copyWith({
    Object? id = _Undefined,
    _isc.UuidValue? authUserId,
    Object? authUser = _Undefined,
    String? email,
    Object? firstName = _Undefined,
    Object? lastName = _Undefined,
    Object? birthday = _Undefined,
    Object? imageUrl = _Undefined,
    DateTime? createdAt,
  }) {
    return MemberProfile(
      id: id is int? ? id : this.id,
      authUserId: authUserId ?? this.authUserId,
      authUser: authUser is _iacc.AuthUser?
          ? authUser
          : this.authUser?.copyWith(),
      email: email ?? this.email,
      firstName: firstName is String? ? firstName : this.firstName,
      lastName: lastName is String? ? lastName : this.lastName,
      birthday: birthday is DateTime? ? birthday : this.birthday,
      imageUrl: imageUrl is String? ? imageUrl : this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
