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

/// Local copy of the global person directory — same model shape as the
/// global `member_profile`, with these differences:
/// - `authUserId` is OPTIONAL: it exists only for local users
///   (site admin / staff) — plain members have no local login.
/// - a required, unique `globalAuthUserId`: the exchange/door key that
///   links this row to its global copy (and names the image object).
///
/// The built-in Serverpod UserProfile feature is bypassed on purpose;
/// the local instance stores mirrored profile data and calls the global
/// instance for edits.
abstract class MemberProfile
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  MemberProfile._({
    this.id,
    this.authUserId,
    this.authUser,
    required this.globalAuthUserId,
    required this.email,
    this.firstName,
    this.lastName,
    this.birthday,
    this.imageUrl,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory MemberProfile({
    int? id,
    _isc.UuidValue? authUserId,
    _iacc.AuthUser? authUser,
    required _isc.UuidValue globalAuthUserId,
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
      authUserId: jsonSerialization['authUserId'] == null
          ? null
          : _isc.UuidValueJsonExtension.fromJson(
              jsonSerialization['authUserId'],
            ),
      authUser: jsonSerialization['authUser'] == null
          ? null
          : _i3m9u5jf.Protocol().deserialize<_iacc.AuthUser>(
              jsonSerialization['authUser'],
            ),
      globalAuthUserId: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['globalAuthUserId'],
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

  _isc.UuidValue? authUserId;

  /// Link to the local login account — null for plain members without
  /// login. SetNull keeps the person data when a login account is
  /// removed.
  _iacc.AuthUser? authUser;

  /// The GLOBAL authUserId of the person — exchange key with the global
  /// instance, door-opening key (ESP32 -> local backend -> lookup) and
  /// the image-object key. Identical to the global row's authUserId.
  _isc.UuidValue globalAuthUserId;

  /// Mirrored profile data (see global model).
  String email;

  String? firstName;

  String? lastName;

  DateTime? birthday;

  /// Public URL of the profile image (local RustFS; null until it has
  /// been transferred/copied).
  String? imageUrl;

  /// When the row was created.
  DateTime createdAt;

  /// Returns a shallow copy of this [MemberProfile]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  MemberProfile copyWith({
    int? id,
    _isc.UuidValue? authUserId,
    _iacc.AuthUser? authUser,
    _isc.UuidValue? globalAuthUserId,
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
      if (authUserId != null) 'authUserId': authUserId?.toJson(),
      if (authUser != null) 'authUser': authUser?.toJson(),
      'globalAuthUserId': globalAuthUserId.toJson(),
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
      if (authUserId != null) 'authUserId': authUserId?.toJson(),
      if (authUser != null) 'authUser': authUser?.toJson(),
      'globalAuthUserId': globalAuthUserId.toJson(),
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
    _isc.UuidValue? authUserId,
    _iacc.AuthUser? authUser,
    required _isc.UuidValue globalAuthUserId,
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
         globalAuthUserId: globalAuthUserId,
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
    Object? authUserId = _Undefined,
    Object? authUser = _Undefined,
    _isc.UuidValue? globalAuthUserId,
    String? email,
    Object? firstName = _Undefined,
    Object? lastName = _Undefined,
    Object? birthday = _Undefined,
    Object? imageUrl = _Undefined,
    DateTime? createdAt,
  }) {
    return MemberProfile(
      id: id is int? ? id : this.id,
      authUserId: authUserId is _isc.UuidValue? ? authUserId : this.authUserId,
      authUser: authUser is _iacc.AuthUser?
          ? authUser
          : this.authUser?.copyWith(),
      globalAuthUserId: globalAuthUserId ?? this.globalAuthUserId,
      email: email ?? this.email,
      firstName: firstName is String? ? firstName : this.firstName,
      lastName: lastName is String? ? lastName : this.lastName,
      birthday: birthday is DateTime? ? birthday : this.birthday,
      imageUrl: imageUrl is String? ? imageUrl : this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
