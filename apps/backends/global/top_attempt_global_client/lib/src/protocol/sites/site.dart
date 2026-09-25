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
import 'package:serverpod_auth_core_client/serverpod_auth_core_client.dart'
    as _iacc;
import 'package:serverpod_client/serverpod_client.dart' as _isc;
import 'package:top_attempt_global_client/src/protocol/protocol.dart'
    as _i00og34q;
import '../sites/site_setup_status.dart' as _i3pb1w5u;

/// A site ("Betrieb") at the global instance. One operating local instance
/// per site; the local BackendMeldung enrolls itself with the generated one
/// time password and establishes the connection to this record.
abstract class Site
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  Site._({
    this.id,
    required this.name,
    required this.street,
    required this.zipCode,
    required this.city,
    required this.country,
    required this.companyEmail,
    _i3pb1w5u.SiteSetupStatus? status,
    required this.firstAdminId,
    this.firstAdmin,
    this.registeredAt,
    this.lastSeenAt,
    DateTime? createdAt,
  }) : status = status ?? _i3pb1w5u.SiteSetupStatus.pendingSetup,
       createdAt = createdAt ?? DateTime.now();

  factory Site({
    int? id,
    required String name,
    required String street,
    required String zipCode,
    required String city,
    required String country,
    required String companyEmail,
    _i3pb1w5u.SiteSetupStatus? status,
    required _isc.UuidValue firstAdminId,
    _iacc.AuthUser? firstAdmin,
    DateTime? registeredAt,
    DateTime? lastSeenAt,
    DateTime? createdAt,
  }) = _SiteImpl;

  factory Site.fromJson(Map<String, dynamic> jsonSerialization) {
    return Site(
      id: jsonSerialization['id'] as int?,
      name: jsonSerialization['name'] as String,
      street: jsonSerialization['street'] as String,
      zipCode: jsonSerialization['zipCode'] as String,
      city: jsonSerialization['city'] as String,
      country: jsonSerialization['country'] as String,
      companyEmail: jsonSerialization['companyEmail'] as String,
      status: jsonSerialization['status'] == null
          ? null
          : _i3pb1w5u.SiteSetupStatus.fromJson(
              (jsonSerialization['status'] as String),
            ),
      firstAdminId: _isc.UuidValueJsonExtension.fromJson(
        jsonSerialization['firstAdminId'],
      ),
      firstAdmin: jsonSerialization['firstAdmin'] == null
          ? null
          : _i00og34q.Protocol().deserialize<_iacc.AuthUser>(
              jsonSerialization['firstAdmin'],
            ),
      registeredAt: jsonSerialization['registeredAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(
              jsonSerialization['registeredAt'],
            ),
      lastSeenAt: jsonSerialization['lastSeenAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(
              jsonSerialization['lastSeenAt'],
            ),
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  /// Name of the site/company.
  String name;

  /// Address data (single fields; the UI renders them as one block).
  String street;

  String zipCode;

  String city;

  String country;

  /// Company email (contact mail of the operating company, for later
  /// mail-based delivery of setup material).
  String companyEmail;

  /// Connect status of the site (setup pending / registered).
  _i3pb1w5u.SiteSetupStatus status;

  _isc.UuidValue firstAdminId;

  /// Creation-time convenience link to the first site administrator
  /// (authoritative linkage is the `SiteMembership` with role siteAdmin).
  _iacc.AuthUser? firstAdmin;

  /// When the local instance registered at the global instance.
  DateTime? registeredAt;

  /// Last heartbeat of the local instance (connectivity display).
  DateTime? lastSeenAt;

  /// When the site record was created.
  DateTime createdAt;

  /// Returns a shallow copy of this [Site]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  Site copyWith({
    int? id,
    String? name,
    String? street,
    String? zipCode,
    String? city,
    String? country,
    String? companyEmail,
    _i3pb1w5u.SiteSetupStatus? status,
    _isc.UuidValue? firstAdminId,
    _iacc.AuthUser? firstAdmin,
    DateTime? registeredAt,
    DateTime? lastSeenAt,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'Site',
      if (id != null) 'id': id,
      'name': name,
      'street': street,
      'zipCode': zipCode,
      'city': city,
      'country': country,
      'companyEmail': companyEmail,
      'status': status.toJson(),
      'firstAdminId': firstAdminId.toJson(),
      if (firstAdmin != null) 'firstAdmin': firstAdmin?.toJson(),
      if (registeredAt != null) 'registeredAt': registeredAt?.toJson(),
      if (lastSeenAt != null) 'lastSeenAt': lastSeenAt?.toJson(),
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'Site',
      if (id != null) 'id': id,
      'name': name,
      'street': street,
      'zipCode': zipCode,
      'city': city,
      'country': country,
      'companyEmail': companyEmail,
      'status': status.toJson(),
      'firstAdminId': firstAdminId.toJson(),
      if (firstAdmin != null) 'firstAdmin': firstAdmin?.toJson(),
      if (registeredAt != null) 'registeredAt': registeredAt?.toJson(),
      if (lastSeenAt != null) 'lastSeenAt': lastSeenAt?.toJson(),
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _SiteImpl extends Site {
  _SiteImpl({
    int? id,
    required String name,
    required String street,
    required String zipCode,
    required String city,
    required String country,
    required String companyEmail,
    _i3pb1w5u.SiteSetupStatus? status,
    required _isc.UuidValue firstAdminId,
    _iacc.AuthUser? firstAdmin,
    DateTime? registeredAt,
    DateTime? lastSeenAt,
    DateTime? createdAt,
  }) : super._(
         id: id,
         name: name,
         street: street,
         zipCode: zipCode,
         city: city,
         country: country,
         companyEmail: companyEmail,
         status: status,
         firstAdminId: firstAdminId,
         firstAdmin: firstAdmin,
         registeredAt: registeredAt,
         lastSeenAt: lastSeenAt,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [Site]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  Site copyWith({
    Object? id = _Undefined,
    String? name,
    String? street,
    String? zipCode,
    String? city,
    String? country,
    String? companyEmail,
    _i3pb1w5u.SiteSetupStatus? status,
    _isc.UuidValue? firstAdminId,
    Object? firstAdmin = _Undefined,
    Object? registeredAt = _Undefined,
    Object? lastSeenAt = _Undefined,
    DateTime? createdAt,
  }) {
    return Site(
      id: id is int? ? id : this.id,
      name: name ?? this.name,
      street: street ?? this.street,
      zipCode: zipCode ?? this.zipCode,
      city: city ?? this.city,
      country: country ?? this.country,
      companyEmail: companyEmail ?? this.companyEmail,
      status: status ?? this.status,
      firstAdminId: firstAdminId ?? this.firstAdminId,
      firstAdmin: firstAdmin is _iacc.AuthUser?
          ? firstAdmin
          : this.firstAdmin?.copyWith(),
      registeredAt: registeredAt is DateTime?
          ? registeredAt
          : this.registeredAt,
      lastSeenAt: lastSeenAt is DateTime? ? lastSeenAt : this.lastSeenAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
