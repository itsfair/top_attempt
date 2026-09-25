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
import 'package:serverpod/serverpod.dart' as _is;
import 'package:top_attempt_global_server/src/generated/protocol.dart'
    as _in02tfqf;

/// A single user as shown/edited in the global admin UI.
abstract class AdminUserSummary
    implements _is.SerializableModel, _is.ProtocolSerialization {
  AdminUserSummary._({
    required this.authUserId,
    this.email,
    this.fullName,
    required this.scopeNames,
    required this.blocked,
    required this.createdAt,
  });

  factory AdminUserSummary({
    required _is.UuidValue authUserId,
    String? email,
    String? fullName,
    required List<String> scopeNames,
    required bool blocked,
    required DateTime createdAt,
  }) = _AdminUserSummaryImpl;

  factory AdminUserSummary.fromJson(Map<String, dynamic> jsonSerialization) {
    return AdminUserSummary(
      authUserId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['authUserId'],
      ),
      email: jsonSerialization['email'] as String?,
      fullName: jsonSerialization['fullName'] as String?,
      scopeNames: _in02tfqf.Protocol().deserialize<List<String>>(
        jsonSerialization['scopeNames'],
      ),
      blocked: _is.BoolJsonExtension.fromJson(jsonSerialization['blocked']),
      createdAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
    );
  }

  /// The auth user id (userIdentifier of the authentication system).
  _is.UuidValue authUserId;

  /// Lowercase e-mail address from the user profile.
  String? email;

  /// Mirrored full name (kept in sync by ProfileDetailsEndpoint.save).
  String? fullName;

  /// The scopes assigned to this user (e.g. 'global-admin').
  List<String> scopeNames;

  /// Whether the user is blocked from signing in.
  bool blocked;

  /// When the user account was created.
  DateTime createdAt;

  /// Returns a shallow copy of this [AdminUserSummary]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  AdminUserSummary copyWith({
    _is.UuidValue? authUserId,
    String? email,
    String? fullName,
    List<String>? scopeNames,
    bool? blocked,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'AdminUserSummary',
      'authUserId': authUserId.toJson(),
      if (email != null) 'email': email,
      if (fullName != null) 'fullName': fullName,
      'scopeNames': scopeNames.toJson(),
      'blocked': blocked,
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'AdminUserSummary',
      'authUserId': authUserId.toJson(),
      if (email != null) 'email': email,
      if (fullName != null) 'fullName': fullName,
      'scopeNames': scopeNames.toJson(),
      'blocked': blocked,
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _AdminUserSummaryImpl extends AdminUserSummary {
  _AdminUserSummaryImpl({
    required _is.UuidValue authUserId,
    String? email,
    String? fullName,
    required List<String> scopeNames,
    required bool blocked,
    required DateTime createdAt,
  }) : super._(
         authUserId: authUserId,
         email: email,
         fullName: fullName,
         scopeNames: scopeNames,
         blocked: blocked,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [AdminUserSummary]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  AdminUserSummary copyWith({
    _is.UuidValue? authUserId,
    Object? email = _Undefined,
    Object? fullName = _Undefined,
    List<String>? scopeNames,
    bool? blocked,
    DateTime? createdAt,
  }) {
    return AdminUserSummary(
      authUserId: authUserId ?? this.authUserId,
      email: email is String? ? email : this.email,
      fullName: fullName is String? ? fullName : this.fullName,
      scopeNames: scopeNames ?? this.scopeNames.map((e0) => e0).toList(),
      blocked: blocked ?? this.blocked,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
