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

/// Enrollment state of this local instance at its site's global instance.
/// Single-row configuration table (the worker reads it on every startup).
abstract class SiteConnection
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  SiteConnection._({
    this.id,
    required this.globalApiUrl,
    required this.siteId,
    required this.siteName,
    this.adminEmail,
    this.adminFullName,
    DateTime? enrolledAt,
  }) : enrolledAt = enrolledAt ?? DateTime.now();

  factory SiteConnection({
    int? id,
    required String globalApiUrl,
    required int siteId,
    required String siteName,
    String? adminEmail,
    String? adminFullName,
    DateTime? enrolledAt,
  }) = _SiteConnectionImpl;

  factory SiteConnection.fromJson(Map<String, dynamic> jsonSerialization) {
    return SiteConnection(
      id: jsonSerialization['id'] as int?,
      globalApiUrl: jsonSerialization['globalApiUrl'] as String,
      siteId: jsonSerialization['siteId'] as int,
      siteName: jsonSerialization['siteName'] as String,
      adminEmail: jsonSerialization['adminEmail'] as String?,
      adminFullName: jsonSerialization['adminFullName'] as String?,
      enrolledAt: jsonSerialization['enrolledAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(
              jsonSerialization['enrolledAt'],
            ),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  /// The API URL of the global backend this instance is bound to
  /// (e.g. `http://192.168.x.x:8080` in dev, real URL in production).
  String globalApiUrl;

  /// The site we are enrolled at.
  int siteId;

  String siteName;

  /// Admin identity handed over at enrollment (the site admin acts as the
  /// connection owner; `member.globalAuthUserId` for this admin uses the
  /// same id).
  String? adminEmail;

  String? adminFullName;

  /// When the enrollment happened (may be a recovery).
  DateTime enrolledAt;

  /// Returns a shallow copy of this [SiteConnection]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  SiteConnection copyWith({
    int? id,
    String? globalApiUrl,
    int? siteId,
    String? siteName,
    String? adminEmail,
    String? adminFullName,
    DateTime? enrolledAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'SiteConnection',
      if (id != null) 'id': id,
      'globalApiUrl': globalApiUrl,
      'siteId': siteId,
      'siteName': siteName,
      if (adminEmail != null) 'adminEmail': adminEmail,
      if (adminFullName != null) 'adminFullName': adminFullName,
      'enrolledAt': enrolledAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'SiteConnection',
      if (id != null) 'id': id,
      'globalApiUrl': globalApiUrl,
      'siteId': siteId,
      'siteName': siteName,
      if (adminEmail != null) 'adminEmail': adminEmail,
      if (adminFullName != null) 'adminFullName': adminFullName,
      'enrolledAt': enrolledAt.toJson(),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _SiteConnectionImpl extends SiteConnection {
  _SiteConnectionImpl({
    int? id,
    required String globalApiUrl,
    required int siteId,
    required String siteName,
    String? adminEmail,
    String? adminFullName,
    DateTime? enrolledAt,
  }) : super._(
         id: id,
         globalApiUrl: globalApiUrl,
         siteId: siteId,
         siteName: siteName,
         adminEmail: adminEmail,
         adminFullName: adminFullName,
         enrolledAt: enrolledAt,
       );

  /// Returns a shallow copy of this [SiteConnection]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  SiteConnection copyWith({
    Object? id = _Undefined,
    String? globalApiUrl,
    int? siteId,
    String? siteName,
    Object? adminEmail = _Undefined,
    Object? adminFullName = _Undefined,
    DateTime? enrolledAt,
  }) {
    return SiteConnection(
      id: id is int? ? id : this.id,
      globalApiUrl: globalApiUrl ?? this.globalApiUrl,
      siteId: siteId ?? this.siteId,
      siteName: siteName ?? this.siteName,
      adminEmail: adminEmail is String? ? adminEmail : this.adminEmail,
      adminFullName: adminFullName is String?
          ? adminFullName
          : this.adminFullName,
      enrolledAt: enrolledAt ?? this.enrolledAt,
    );
  }
}
