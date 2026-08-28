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
import 'package:serverpod_client/serverpod_client.dart' as _i1;
import 'package:serverpod_auth_core_client/serverpod_auth_core_client.dart'
    as _i2;
import 'package:top_attempt_global_client/src/protocol/protocol.dart' as _i3;

abstract class ProfileDetails implements _i1.SerializableModel {
  ProfileDetails._({
    this.id,
    required this.authUserId,
    this.authUser,
    this.firstName,
    this.lastName,
    this.birthday,
  });

  factory ProfileDetails({
    int? id,
    required _i1.UuidValue authUserId,
    _i2.AuthUser? authUser,
    String? firstName,
    String? lastName,
    DateTime? birthday,
  }) = _ProfileDetailsImpl;

  factory ProfileDetails.fromJson(Map<String, dynamic> jsonSerialization) {
    return ProfileDetails(
      id: jsonSerialization['id'] as int?,
      authUserId: _i1.UuidValueJsonExtension.fromJson(
        jsonSerialization['authUserId'],
      ),
      authUser: jsonSerialization['authUser'] == null
          ? null
          : _i3.Protocol().deserialize<_i2.AuthUser>(
              jsonSerialization['authUser'],
            ),
      firstName: jsonSerialization['firstName'] as String?,
      lastName: jsonSerialization['lastName'] as String?,
      birthday: jsonSerialization['birthday'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['birthday']),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  _i1.UuidValue authUserId;

  /// The AuthUser this data belongs to.
  _i2.AuthUser? authUser;

  String? firstName;

  String? lastName;

  DateTime? birthday;

  /// Returns a shallow copy of this [ProfileDetails]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  ProfileDetails copyWith({
    int? id,
    _i1.UuidValue? authUserId,
    _i2.AuthUser? authUser,
    String? firstName,
    String? lastName,
    DateTime? birthday,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'ProfileDetails',
      if (id != null) 'id': id,
      'authUserId': authUserId.toJson(),
      if (authUser != null) 'authUser': authUser?.toJson(),
      if (firstName != null) 'firstName': firstName,
      if (lastName != null) 'lastName': lastName,
      if (birthday != null) 'birthday': birthday?.toJson(),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _ProfileDetailsImpl extends ProfileDetails {
  _ProfileDetailsImpl({
    int? id,
    required _i1.UuidValue authUserId,
    _i2.AuthUser? authUser,
    String? firstName,
    String? lastName,
    DateTime? birthday,
  }) : super._(
         id: id,
         authUserId: authUserId,
         authUser: authUser,
         firstName: firstName,
         lastName: lastName,
         birthday: birthday,
       );

  /// Returns a shallow copy of this [ProfileDetails]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  ProfileDetails copyWith({
    Object? id = _Undefined,
    _i1.UuidValue? authUserId,
    Object? authUser = _Undefined,
    Object? firstName = _Undefined,
    Object? lastName = _Undefined,
    Object? birthday = _Undefined,
  }) {
    return ProfileDetails(
      id: id is int? ? id : this.id,
      authUserId: authUserId ?? this.authUserId,
      authUser: authUser is _i2.AuthUser?
          ? authUser
          : this.authUser?.copyWith(),
      firstName: firstName is String? ? firstName : this.firstName,
      lastName: lastName is String? ? lastName : this.lastName,
      birthday: birthday is DateTime? ? birthday : this.birthday,
    );
  }
}
