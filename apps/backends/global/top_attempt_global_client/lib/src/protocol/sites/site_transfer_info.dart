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

/// Transfer data the local instance receives at successful enrollment
/// (fresh setup). Contains no credentials: the device session key is an
/// SAS session key (`AuthStrategy.session`) for the site admin that was
/// issued server-side and has to be stored locally, write-once.
abstract class SiteTransferInfo
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  SiteTransferInfo._({
    required this.siteId,
    required this.siteName,
    this.adminEmail,
    required this.adminAuthUserId,
    this.adminFullName,
    required this.deviceSessionKey,
  });

  factory SiteTransferInfo({
    required int siteId,
    required String siteName,
    String? adminEmail,
    required _isc.UuidValue adminAuthUserId,
    String? adminFullName,
    required String deviceSessionKey,
  }) = _SiteTransferInfoImpl;

  factory SiteTransferInfo.fromJson(Map<String, dynamic> jsonSerialization) {
    return SiteTransferInfo(
      siteId: jsonSerialization['siteId'] as int,
      siteName: jsonSerialization['siteName'] as String,
      adminEmail: jsonSerialization['adminEmail'] as String?,
      adminAuthUserId: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['adminAuthUserId'],
      ),
      adminFullName: jsonSerialization['adminFullName'] as String?,
      deviceSessionKey: jsonSerialization['deviceSessionKey'] as String,
    );
  }

  /// The enrolled site (id and name are enough to boot the connection;
  /// deeper data comes with the sites details).
  int siteId;

  /// Name of the site.
  String siteName;

  /// Email of the site admin (global) — also used as the local admin's
  /// login email.
  String? adminEmail;

  /// Global authUserId of the site admin — the exchange key for the local
  /// members table (`members.globalAuthUserId`), used later for door
  /// authorization. Local member rows must carry exactly this id.
  _isc.UuidValue adminAuthUserId;

  /// Global full name of the site admin (kept in sync via ProfileDetails).
  String? adminFullName;

  /// The SAS session key for the device connection. Store securely; there
  /// is no rotation (write once) and the key cannot be recovered.
  String deviceSessionKey;

  /// Returns a shallow copy of this [SiteTransferInfo]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  SiteTransferInfo copyWith({
    int? siteId,
    String? siteName,
    String? adminEmail,
    _isc.UuidValue? adminAuthUserId,
    String? adminFullName,
    String? deviceSessionKey,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'SiteTransferInfo',
      'siteId': siteId,
      'siteName': siteName,
      if (adminEmail != null) 'adminEmail': adminEmail,
      'adminAuthUserId': adminAuthUserId.toJson(),
      if (adminFullName != null) 'adminFullName': adminFullName,
      'deviceSessionKey': deviceSessionKey,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'SiteTransferInfo',
      'siteId': siteId,
      'siteName': siteName,
      if (adminEmail != null) 'adminEmail': adminEmail,
      'adminAuthUserId': adminAuthUserId.toJson(),
      if (adminFullName != null) 'adminFullName': adminFullName,
      'deviceSessionKey': deviceSessionKey,
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _SiteTransferInfoImpl extends SiteTransferInfo {
  _SiteTransferInfoImpl({
    required int siteId,
    required String siteName,
    String? adminEmail,
    required _isc.UuidValue adminAuthUserId,
    String? adminFullName,
    required String deviceSessionKey,
  }) : super._(
         siteId: siteId,
         siteName: siteName,
         adminEmail: adminEmail,
         adminAuthUserId: adminAuthUserId,
         adminFullName: adminFullName,
         deviceSessionKey: deviceSessionKey,
       );

  /// Returns a shallow copy of this [SiteTransferInfo]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  SiteTransferInfo copyWith({
    int? siteId,
    String? siteName,
    Object? adminEmail = _Undefined,
    _isc.UuidValue? adminAuthUserId,
    Object? adminFullName = _Undefined,
    String? deviceSessionKey,
  }) {
    return SiteTransferInfo(
      siteId: siteId ?? this.siteId,
      siteName: siteName ?? this.siteName,
      adminEmail: adminEmail is String? ? adminEmail : this.adminEmail,
      adminAuthUserId: adminAuthUserId ?? this.adminAuthUserId,
      adminFullName: adminFullName is String?
          ? adminFullName
          : this.adminFullName,
      deviceSessionKey: deviceSessionKey ?? this.deviceSessionKey,
    );
  }
}
