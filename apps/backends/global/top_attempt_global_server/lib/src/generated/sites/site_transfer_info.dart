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

/// Transfer data the local instance receives at successful enrollment
/// (fresh setup). Contains no credentials: the device session key is an
/// SAS session key (`AuthStrategy.session`) for the site admin that was
/// issued server-side and has to be stored locally, write-once.
abstract class SiteTransferInfo
    implements _is.SerializableModel, _is.ProtocolSerialization {
  SiteTransferInfo._({
    required this.siteId,
    required this.siteName,
    this.siteStreet,
    this.siteZipCode,
    this.siteCity,
    this.siteCountry,
    this.siteCompanyEmail,
    this.siteStatusName,
    this.siteRegisteredAt,
    this.adminEmail,
    required this.adminAuthUserId,
    this.adminFirstName,
    this.adminLastName,
    this.adminBirthday,
    this.adminImageUrl,
    required this.deviceSessionKey,
  });

  factory SiteTransferInfo({
    required int siteId,
    required String siteName,
    String? siteStreet,
    String? siteZipCode,
    String? siteCity,
    String? siteCountry,
    String? siteCompanyEmail,
    String? siteStatusName,
    DateTime? siteRegisteredAt,
    String? adminEmail,
    required _is.UuidValue adminAuthUserId,
    String? adminFirstName,
    String? adminLastName,
    DateTime? adminBirthday,
    String? adminImageUrl,
    required String deviceSessionKey,
  }) = _SiteTransferInfoImpl;

  factory SiteTransferInfo.fromJson(Map<String, dynamic> jsonSerialization) {
    return SiteTransferInfo(
      siteId: jsonSerialization['siteId'] as int,
      siteName: jsonSerialization['siteName'] as String,
      siteStreet: jsonSerialization['siteStreet'] as String?,
      siteZipCode: jsonSerialization['siteZipCode'] as String?,
      siteCity: jsonSerialization['siteCity'] as String?,
      siteCountry: jsonSerialization['siteCountry'] as String?,
      siteCompanyEmail: jsonSerialization['siteCompanyEmail'] as String?,
      siteStatusName: jsonSerialization['siteStatusName'] as String?,
      siteRegisteredAt: jsonSerialization['siteRegisteredAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(
              jsonSerialization['siteRegisteredAt'],
            ),
      adminEmail: jsonSerialization['adminEmail'] as String?,
      adminAuthUserId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['adminAuthUserId'],
      ),
      adminFirstName: jsonSerialization['adminFirstName'] as String?,
      adminLastName: jsonSerialization['adminLastName'] as String?,
      adminBirthday: jsonSerialization['adminBirthday'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(
              jsonSerialization['adminBirthday'],
            ),
      adminImageUrl: jsonSerialization['adminImageUrl'] as String?,
      deviceSessionKey: jsonSerialization['deviceSessionKey'] as String,
    );
  }

  /// Snapshot of the enrolled site with ALL its properties (the local
  /// instance caches it for the "Standort" page).
  int siteId;

  /// Name of the site.
  String siteName;

  /// Site address data.
  String? siteStreet;

  String? siteZipCode;

  String? siteCity;

  String? siteCountry;

  /// Contact mail of the operating company.
  String? siteCompanyEmail;

  /// Setup status at enroll time (pendingSetup|registered).
  String? siteStatusName;

  /// When the site registered at the global instance.
  DateTime? siteRegisteredAt;

  /// Email of the site admin (global) — also used as the local admin's
  /// login email.
  String? adminEmail;

  /// Global authUserId of the site admin — the exchange key for the local
  /// members table (`members.globalAuthUserId`), used later for door
  /// authorization. Local member rows must carry exactly this id.
  _is.UuidValue adminAuthUserId;

  /// Global profile names of the site admin (may be null until the admin
  /// completed their profile).
  String? adminFirstName;

  String? adminLastName;

  /// Global birthday of the site admin (UTC-midnight date sentinel).
  DateTime? adminBirthday;

  /// Public image URL of the site admin's profile image (global RustFS).
  /// TODO (security): hand over a short-lived presigned URL instead of
  /// the raw/eternal object URL (capability URL, see backend AGENTS.md).
  String? adminImageUrl;

  /// The SAS session key for the device connection. Store securely; there
  /// is no rotation (write once) and the key cannot be recovered.
  String deviceSessionKey;

  /// Returns a shallow copy of this [SiteTransferInfo]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  SiteTransferInfo copyWith({
    int? siteId,
    String? siteName,
    String? siteStreet,
    String? siteZipCode,
    String? siteCity,
    String? siteCountry,
    String? siteCompanyEmail,
    String? siteStatusName,
    DateTime? siteRegisteredAt,
    String? adminEmail,
    _is.UuidValue? adminAuthUserId,
    String? adminFirstName,
    String? adminLastName,
    DateTime? adminBirthday,
    String? adminImageUrl,
    String? deviceSessionKey,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'SiteTransferInfo',
      'siteId': siteId,
      'siteName': siteName,
      if (siteStreet != null) 'siteStreet': siteStreet,
      if (siteZipCode != null) 'siteZipCode': siteZipCode,
      if (siteCity != null) 'siteCity': siteCity,
      if (siteCountry != null) 'siteCountry': siteCountry,
      if (siteCompanyEmail != null) 'siteCompanyEmail': siteCompanyEmail,
      if (siteStatusName != null) 'siteStatusName': siteStatusName,
      if (siteRegisteredAt != null)
        'siteRegisteredAt': siteRegisteredAt?.toJson(),
      if (adminEmail != null) 'adminEmail': adminEmail,
      'adminAuthUserId': adminAuthUserId.toJson(),
      if (adminFirstName != null) 'adminFirstName': adminFirstName,
      if (adminLastName != null) 'adminLastName': adminLastName,
      if (adminBirthday != null) 'adminBirthday': adminBirthday?.toJson(),
      if (adminImageUrl != null) 'adminImageUrl': adminImageUrl,
      'deviceSessionKey': deviceSessionKey,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'SiteTransferInfo',
      'siteId': siteId,
      'siteName': siteName,
      if (siteStreet != null) 'siteStreet': siteStreet,
      if (siteZipCode != null) 'siteZipCode': siteZipCode,
      if (siteCity != null) 'siteCity': siteCity,
      if (siteCountry != null) 'siteCountry': siteCountry,
      if (siteCompanyEmail != null) 'siteCompanyEmail': siteCompanyEmail,
      if (siteStatusName != null) 'siteStatusName': siteStatusName,
      if (siteRegisteredAt != null)
        'siteRegisteredAt': siteRegisteredAt?.toJson(),
      if (adminEmail != null) 'adminEmail': adminEmail,
      'adminAuthUserId': adminAuthUserId.toJson(),
      if (adminFirstName != null) 'adminFirstName': adminFirstName,
      if (adminLastName != null) 'adminLastName': adminLastName,
      if (adminBirthday != null) 'adminBirthday': adminBirthday?.toJson(),
      if (adminImageUrl != null) 'adminImageUrl': adminImageUrl,
      'deviceSessionKey': deviceSessionKey,
    };
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _SiteTransferInfoImpl extends SiteTransferInfo {
  _SiteTransferInfoImpl({
    required int siteId,
    required String siteName,
    String? siteStreet,
    String? siteZipCode,
    String? siteCity,
    String? siteCountry,
    String? siteCompanyEmail,
    String? siteStatusName,
    DateTime? siteRegisteredAt,
    String? adminEmail,
    required _is.UuidValue adminAuthUserId,
    String? adminFirstName,
    String? adminLastName,
    DateTime? adminBirthday,
    String? adminImageUrl,
    required String deviceSessionKey,
  }) : super._(
         siteId: siteId,
         siteName: siteName,
         siteStreet: siteStreet,
         siteZipCode: siteZipCode,
         siteCity: siteCity,
         siteCountry: siteCountry,
         siteCompanyEmail: siteCompanyEmail,
         siteStatusName: siteStatusName,
         siteRegisteredAt: siteRegisteredAt,
         adminEmail: adminEmail,
         adminAuthUserId: adminAuthUserId,
         adminFirstName: adminFirstName,
         adminLastName: adminLastName,
         adminBirthday: adminBirthday,
         adminImageUrl: adminImageUrl,
         deviceSessionKey: deviceSessionKey,
       );

  /// Returns a shallow copy of this [SiteTransferInfo]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  SiteTransferInfo copyWith({
    int? siteId,
    String? siteName,
    Object? siteStreet = _Undefined,
    Object? siteZipCode = _Undefined,
    Object? siteCity = _Undefined,
    Object? siteCountry = _Undefined,
    Object? siteCompanyEmail = _Undefined,
    Object? siteStatusName = _Undefined,
    Object? siteRegisteredAt = _Undefined,
    Object? adminEmail = _Undefined,
    _is.UuidValue? adminAuthUserId,
    Object? adminFirstName = _Undefined,
    Object? adminLastName = _Undefined,
    Object? adminBirthday = _Undefined,
    Object? adminImageUrl = _Undefined,
    String? deviceSessionKey,
  }) {
    return SiteTransferInfo(
      siteId: siteId ?? this.siteId,
      siteName: siteName ?? this.siteName,
      siteStreet: siteStreet is String? ? siteStreet : this.siteStreet,
      siteZipCode: siteZipCode is String? ? siteZipCode : this.siteZipCode,
      siteCity: siteCity is String? ? siteCity : this.siteCity,
      siteCountry: siteCountry is String? ? siteCountry : this.siteCountry,
      siteCompanyEmail: siteCompanyEmail is String?
          ? siteCompanyEmail
          : this.siteCompanyEmail,
      siteStatusName: siteStatusName is String?
          ? siteStatusName
          : this.siteStatusName,
      siteRegisteredAt: siteRegisteredAt is DateTime?
          ? siteRegisteredAt
          : this.siteRegisteredAt,
      adminEmail: adminEmail is String? ? adminEmail : this.adminEmail,
      adminAuthUserId: adminAuthUserId ?? this.adminAuthUserId,
      adminFirstName: adminFirstName is String?
          ? adminFirstName
          : this.adminFirstName,
      adminLastName: adminLastName is String?
          ? adminLastName
          : this.adminLastName,
      adminBirthday: adminBirthday is DateTime?
          ? adminBirthday
          : this.adminBirthday,
      adminImageUrl: adminImageUrl is String?
          ? adminImageUrl
          : this.adminImageUrl,
      deviceSessionKey: deviceSessionKey ?? this.deviceSessionKey,
    );
  }
}
