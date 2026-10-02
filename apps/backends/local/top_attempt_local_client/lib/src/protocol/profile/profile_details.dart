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
import 'package:serverpod_client/serverpod_client.dart' as _isc;
import 'package:top_attempt_local_client/src/protocol/protocol.dart'
    as _i3m9u5jf;
import '../site/membership.dart' as _iijnlsdj;

/// Extended person data of a site person (local mirror of the global
/// profile_details): the identity is the membership row — one profile row
/// per membership, cascade-deleted with it. Email and image URL are
/// mirrored from the global instance (enrollment/sync) and not locally
/// editable; name fields are written by the signed-in person via
/// profileDetails.save.
abstract class ProfileDetails
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  ProfileDetails._({
    this.id,
    required this.membershipId,
    this.membership,
    this.email,
    this.firstName,
    this.lastName,
    this.birthday,
    this.imageUrl,
  });

  factory ProfileDetails({
    int? id,
    required int membershipId,
    _iijnlsdj.Membership? membership,
    String? email,
    String? firstName,
    String? lastName,
    DateTime? birthday,
    String? imageUrl,
  }) = _ProfileDetailsImpl;

  factory ProfileDetails.fromJson(Map<String, dynamic> jsonSerialization) {
    return ProfileDetails(
      id: jsonSerialization['id'] as int?,
      membershipId: jsonSerialization['membershipId'] as int,
      membership: jsonSerialization['membership'] == null
          ? null
          : _i3m9u5jf.Protocol().deserialize<_iijnlsdj.Membership>(
              jsonSerialization['membership'],
            ),
      email: jsonSerialization['email'] as String?,
      firstName: jsonSerialization['firstName'] as String?,
      lastName: jsonSerialization['lastName'] as String?,
      birthday: jsonSerialization['birthday'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(jsonSerialization['birthday']),
      imageUrl: jsonSerialization['imageUrl'] as String?,
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  int membershipId;

  /// The membership (person) this data belongs to.
  _iijnlsdj.Membership? membership;

  /// Mirrored from the global account; not locally editable.
  String? email;

  String? firstName;

  String? lastName;

  DateTime? birthday;

  /// Local public URL of the person's profile image (local RustFS, stored
  /// at enrollment transfer for the site admin).
  String? imageUrl;

  /// Returns a shallow copy of this [ProfileDetails]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  ProfileDetails copyWith({
    int? id,
    int? membershipId,
    _iijnlsdj.Membership? membership,
    String? email,
    String? firstName,
    String? lastName,
    DateTime? birthday,
    String? imageUrl,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'ProfileDetails',
      if (id != null) 'id': id,
      'membershipId': membershipId,
      if (membership != null) 'membership': membership?.toJson(),
      if (email != null) 'email': email,
      if (firstName != null) 'firstName': firstName,
      if (lastName != null) 'lastName': lastName,
      if (birthday != null) 'birthday': birthday?.toJson(),
      if (imageUrl != null) 'imageUrl': imageUrl,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'ProfileDetails',
      if (id != null) 'id': id,
      'membershipId': membershipId,
      if (membership != null) 'membership': membership?.toJsonForProtocol(),
      if (email != null) 'email': email,
      if (firstName != null) 'firstName': firstName,
      if (lastName != null) 'lastName': lastName,
      if (birthday != null) 'birthday': birthday?.toJson(),
      if (imageUrl != null) 'imageUrl': imageUrl,
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _ProfileDetailsImpl extends ProfileDetails {
  _ProfileDetailsImpl({
    int? id,
    required int membershipId,
    _iijnlsdj.Membership? membership,
    String? email,
    String? firstName,
    String? lastName,
    DateTime? birthday,
    String? imageUrl,
  }) : super._(
         id: id,
         membershipId: membershipId,
         membership: membership,
         email: email,
         firstName: firstName,
         lastName: lastName,
         birthday: birthday,
         imageUrl: imageUrl,
       );

  /// Returns a shallow copy of this [ProfileDetails]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  ProfileDetails copyWith({
    Object? id = _Undefined,
    int? membershipId,
    Object? membership = _Undefined,
    Object? email = _Undefined,
    Object? firstName = _Undefined,
    Object? lastName = _Undefined,
    Object? birthday = _Undefined,
    Object? imageUrl = _Undefined,
  }) {
    return ProfileDetails(
      id: id is int? ? id : this.id,
      membershipId: membershipId ?? this.membershipId,
      membership: membership is _iijnlsdj.Membership?
          ? membership
          : this.membership?.copyWith(),
      email: email is String? ? email : this.email,
      firstName: firstName is String? ? firstName : this.firstName,
      lastName: lastName is String? ? lastName : this.lastName,
      birthday: birthday is DateTime? ? birthday : this.birthday,
      imageUrl: imageUrl is String? ? imageUrl : this.imageUrl,
    );
  }
}
