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
import '../site/site_connection_state.dart' as _ilrp6tdy;

/// Everything the local admin UI displays about this instance: connection
/// state, the site snapshot and the admin's mirrored person data.
abstract class LocalAdminInfo
    implements _is.SerializableModel, _is.ProtocolSerialization {
  LocalAdminInfo._({
    required this.connectionState,
    this.connectionError,
    this.lastConnectedAt,
    this.siteId,
    this.siteName,
    this.siteStreet,
    this.siteZipCode,
    this.siteCity,
    this.siteCountry,
    this.siteCompanyEmail,
    this.adminEmail,
    this.adminFirstName,
    this.adminLastName,
    this.adminBirthday,
    this.adminImageUrl,
  });

  factory LocalAdminInfo({
    required _ilrp6tdy.SiteConnectionState connectionState,
    String? connectionError,
    DateTime? lastConnectedAt,
    int? siteId,
    String? siteName,
    String? siteStreet,
    String? siteZipCode,
    String? siteCity,
    String? siteCountry,
    String? siteCompanyEmail,
    String? adminEmail,
    String? adminFirstName,
    String? adminLastName,
    DateTime? adminBirthday,
    String? adminImageUrl,
  }) = _LocalAdminInfoImpl;

  factory LocalAdminInfo.fromJson(Map<String, dynamic> jsonSerialization) {
    return LocalAdminInfo(
      connectionState: _ilrp6tdy.SiteConnectionState.fromJson(
        (jsonSerialization['connectionState'] as String),
      ),
      connectionError: jsonSerialization['connectionError'] as String?,
      lastConnectedAt: jsonSerialization['lastConnectedAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(
              jsonSerialization['lastConnectedAt'],
            ),
      siteId: jsonSerialization['siteId'] as int?,
      siteName: jsonSerialization['siteName'] as String?,
      siteStreet: jsonSerialization['siteStreet'] as String?,
      siteZipCode: jsonSerialization['siteZipCode'] as String?,
      siteCity: jsonSerialization['siteCity'] as String?,
      siteCountry: jsonSerialization['siteCountry'] as String?,
      siteCompanyEmail: jsonSerialization['siteCompanyEmail'] as String?,
      adminEmail: jsonSerialization['adminEmail'] as String?,
      adminFirstName: jsonSerialization['adminFirstName'] as String?,
      adminLastName: jsonSerialization['adminLastName'] as String?,
      adminBirthday: jsonSerialization['adminBirthday'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(
              jsonSerialization['adminBirthday'],
            ),
      adminImageUrl: jsonSerialization['adminImageUrl'] as String?,
    );
  }

  /// Live connection state (from the device-connection worker).
  _ilrp6tdy.SiteConnectionState connectionState;

  String? connectionError;

  DateTime? lastConnectedAt;

  /// Site snapshot (fetched at enrollment; diverges if the site is
  /// changed globally later — sync TODO).
  int? siteId;

  String? siteName;

  String? siteStreet;

  String? siteZipCode;

  String? siteCity;

  String? siteCountry;

  String? siteCompanyEmail;

  /// The admin's mirrored person data (join into the members table via
  /// `site_connections.adminAuthUserId`).
  String? adminEmail;

  String? adminFirstName;

  String? adminLastName;

  DateTime? adminBirthday;

  String? adminImageUrl;

  /// Returns a shallow copy of this [LocalAdminInfo]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  LocalAdminInfo copyWith({
    _ilrp6tdy.SiteConnectionState? connectionState,
    String? connectionError,
    DateTime? lastConnectedAt,
    int? siteId,
    String? siteName,
    String? siteStreet,
    String? siteZipCode,
    String? siteCity,
    String? siteCountry,
    String? siteCompanyEmail,
    String? adminEmail,
    String? adminFirstName,
    String? adminLastName,
    DateTime? adminBirthday,
    String? adminImageUrl,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'LocalAdminInfo',
      'connectionState': connectionState.toJson(),
      if (connectionError != null) 'connectionError': connectionError,
      if (lastConnectedAt != null) 'lastConnectedAt': lastConnectedAt?.toJson(),
      if (siteId != null) 'siteId': siteId,
      if (siteName != null) 'siteName': siteName,
      if (siteStreet != null) 'siteStreet': siteStreet,
      if (siteZipCode != null) 'siteZipCode': siteZipCode,
      if (siteCity != null) 'siteCity': siteCity,
      if (siteCountry != null) 'siteCountry': siteCountry,
      if (siteCompanyEmail != null) 'siteCompanyEmail': siteCompanyEmail,
      if (adminEmail != null) 'adminEmail': adminEmail,
      if (adminFirstName != null) 'adminFirstName': adminFirstName,
      if (adminLastName != null) 'adminLastName': adminLastName,
      if (adminBirthday != null) 'adminBirthday': adminBirthday?.toJson(),
      if (adminImageUrl != null) 'adminImageUrl': adminImageUrl,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'LocalAdminInfo',
      'connectionState': connectionState.toJson(),
      if (connectionError != null) 'connectionError': connectionError,
      if (lastConnectedAt != null) 'lastConnectedAt': lastConnectedAt?.toJson(),
      if (siteId != null) 'siteId': siteId,
      if (siteName != null) 'siteName': siteName,
      if (siteStreet != null) 'siteStreet': siteStreet,
      if (siteZipCode != null) 'siteZipCode': siteZipCode,
      if (siteCity != null) 'siteCity': siteCity,
      if (siteCountry != null) 'siteCountry': siteCountry,
      if (siteCompanyEmail != null) 'siteCompanyEmail': siteCompanyEmail,
      if (adminEmail != null) 'adminEmail': adminEmail,
      if (adminFirstName != null) 'adminFirstName': adminFirstName,
      if (adminLastName != null) 'adminLastName': adminLastName,
      if (adminBirthday != null) 'adminBirthday': adminBirthday?.toJson(),
      if (adminImageUrl != null) 'adminImageUrl': adminImageUrl,
    };
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _LocalAdminInfoImpl extends LocalAdminInfo {
  _LocalAdminInfoImpl({
    required _ilrp6tdy.SiteConnectionState connectionState,
    String? connectionError,
    DateTime? lastConnectedAt,
    int? siteId,
    String? siteName,
    String? siteStreet,
    String? siteZipCode,
    String? siteCity,
    String? siteCountry,
    String? siteCompanyEmail,
    String? adminEmail,
    String? adminFirstName,
    String? adminLastName,
    DateTime? adminBirthday,
    String? adminImageUrl,
  }) : super._(
         connectionState: connectionState,
         connectionError: connectionError,
         lastConnectedAt: lastConnectedAt,
         siteId: siteId,
         siteName: siteName,
         siteStreet: siteStreet,
         siteZipCode: siteZipCode,
         siteCity: siteCity,
         siteCountry: siteCountry,
         siteCompanyEmail: siteCompanyEmail,
         adminEmail: adminEmail,
         adminFirstName: adminFirstName,
         adminLastName: adminLastName,
         adminBirthday: adminBirthday,
         adminImageUrl: adminImageUrl,
       );

  /// Returns a shallow copy of this [LocalAdminInfo]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  LocalAdminInfo copyWith({
    _ilrp6tdy.SiteConnectionState? connectionState,
    Object? connectionError = _Undefined,
    Object? lastConnectedAt = _Undefined,
    Object? siteId = _Undefined,
    Object? siteName = _Undefined,
    Object? siteStreet = _Undefined,
    Object? siteZipCode = _Undefined,
    Object? siteCity = _Undefined,
    Object? siteCountry = _Undefined,
    Object? siteCompanyEmail = _Undefined,
    Object? adminEmail = _Undefined,
    Object? adminFirstName = _Undefined,
    Object? adminLastName = _Undefined,
    Object? adminBirthday = _Undefined,
    Object? adminImageUrl = _Undefined,
  }) {
    return LocalAdminInfo(
      connectionState: connectionState ?? this.connectionState,
      connectionError: connectionError is String?
          ? connectionError
          : this.connectionError,
      lastConnectedAt: lastConnectedAt is DateTime?
          ? lastConnectedAt
          : this.lastConnectedAt,
      siteId: siteId is int? ? siteId : this.siteId,
      siteName: siteName is String? ? siteName : this.siteName,
      siteStreet: siteStreet is String? ? siteStreet : this.siteStreet,
      siteZipCode: siteZipCode is String? ? siteZipCode : this.siteZipCode,
      siteCity: siteCity is String? ? siteCity : this.siteCity,
      siteCountry: siteCountry is String? ? siteCountry : this.siteCountry,
      siteCompanyEmail: siteCompanyEmail is String?
          ? siteCompanyEmail
          : this.siteCompanyEmail,
      adminEmail: adminEmail is String? ? adminEmail : this.adminEmail,
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
    );
  }
}
