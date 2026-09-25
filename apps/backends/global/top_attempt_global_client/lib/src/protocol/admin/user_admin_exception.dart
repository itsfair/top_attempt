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

/// Exception raised by the admin endpoints (e.g. self-lockout protection).
abstract class UserAdminException
    implements
        _isc.SerializableException,
        _isc.SerializableModel,
        _isc.ProtocolSerialization {
  UserAdminException._({required this.message});

  factory UserAdminException({required String message}) =
      _UserAdminExceptionImpl;

  factory UserAdminException.fromJson(Map<String, dynamic> jsonSerialization) {
    return UserAdminException(message: jsonSerialization['message'] as String);
  }

  /// Human-readable description of what went wrong.
  String message;

  /// Returns a shallow copy of this [UserAdminException]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  UserAdminException copyWith({String? message});
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'UserAdminException',
      'message': message,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'UserAdminException',
      'message': message,
    };
  }

  @override
  String toString() {
    return 'UserAdminException(message: $message)';
  }
}

class _UserAdminExceptionImpl extends UserAdminException {
  _UserAdminExceptionImpl({required String message})
    : super._(message: message);

  /// Returns a shallow copy of this [UserAdminException]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  UserAdminException copyWith({String? message}) {
    return UserAdminException(message: message ?? this.message);
  }
}
