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

/// DTO used once at site creation: the site id plus both generated secrets
/// in plain text (instance one-time password and the local admin's initial
/// password). Shown once in the UI; the global instance never returns them
/// again (the initial password stays stored encrypted until first connect,
/// then cleared).
abstract class CreatedSiteInfo
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  CreatedSiteInfo._({
    required this.siteId,
    this.oneTimePassword,
    this.initialAdminPassword,
  });

  factory CreatedSiteInfo({
    required int siteId,
    String? oneTimePassword,
    String? initialAdminPassword,
  }) = _CreatedSiteInfoImpl;

  factory CreatedSiteInfo.fromJson(Map<String, dynamic> jsonSerialization) {
    return CreatedSiteInfo(
      siteId: jsonSerialization['siteId'] as int,
      oneTimePassword: jsonSerialization['oneTimePassword'] as String?,
      initialAdminPassword:
          jsonSerialization['initialAdminPassword'] as String?,
    );
  }

  /// The created site (navigable via the sites detail route).
  int siteId;

  /// One-time password (plain text, single-use) for the local instance's
  /// enrollment at the global instance.
  String? oneTimePassword;

  /// Initial password for the local admin (created at the local instance on
  /// first connect). Delivered to the local instance via the first
  /// connection and stored encrypted until then.
  String? initialAdminPassword;

  /// Returns a shallow copy of this [CreatedSiteInfo]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  CreatedSiteInfo copyWith({
    int? siteId,
    String? oneTimePassword,
    String? initialAdminPassword,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'CreatedSiteInfo',
      'siteId': siteId,
      if (oneTimePassword != null) 'oneTimePassword': oneTimePassword,
      if (initialAdminPassword != null)
        'initialAdminPassword': initialAdminPassword,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'CreatedSiteInfo',
      'siteId': siteId,
      if (oneTimePassword != null) 'oneTimePassword': oneTimePassword,
      if (initialAdminPassword != null)
        'initialAdminPassword': initialAdminPassword,
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _CreatedSiteInfoImpl extends CreatedSiteInfo {
  _CreatedSiteInfoImpl({
    required int siteId,
    String? oneTimePassword,
    String? initialAdminPassword,
  }) : super._(
         siteId: siteId,
         oneTimePassword: oneTimePassword,
         initialAdminPassword: initialAdminPassword,
       );

  /// Returns a shallow copy of this [CreatedSiteInfo]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  CreatedSiteInfo copyWith({
    int? siteId,
    Object? oneTimePassword = _Undefined,
    Object? initialAdminPassword = _Undefined,
  }) {
    return CreatedSiteInfo(
      siteId: siteId ?? this.siteId,
      oneTimePassword: oneTimePassword is String?
          ? oneTimePassword
          : this.oneTimePassword,
      initialAdminPassword: initialAdminPassword is String?
          ? initialAdminPassword
          : this.initialAdminPassword,
    );
  }
}
