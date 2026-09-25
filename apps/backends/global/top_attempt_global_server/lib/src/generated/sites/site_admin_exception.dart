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

/// Exception raised by the sites admin endpoints (validation and state
/// errors, shown to the platform admin).
abstract class SiteAdminException
    implements
        _is.SerializableException,
        _is.SerializableModel,
        _is.ProtocolSerialization {
  SiteAdminException._({required this.message});

  factory SiteAdminException({required String message}) =
      _SiteAdminExceptionImpl;

  factory SiteAdminException.fromJson(Map<String, dynamic> jsonSerialization) {
    return SiteAdminException(message: jsonSerialization['message'] as String);
  }

  /// Human-readable description of what went wrong.
  String message;

  /// Returns a shallow copy of this [SiteAdminException]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  SiteAdminException copyWith({String? message});
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'SiteAdminException',
      'message': message,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'SiteAdminException',
      'message': message,
    };
  }

  @override
  String toString() {
    return 'SiteAdminException(message: $message)';
  }
}

class _SiteAdminExceptionImpl extends SiteAdminException {
  _SiteAdminExceptionImpl({required String message})
    : super._(message: message);

  /// Returns a shallow copy of this [SiteAdminException]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  SiteAdminException copyWith({String? message}) {
    return SiteAdminException(message: message ?? this.message);
  }
}
