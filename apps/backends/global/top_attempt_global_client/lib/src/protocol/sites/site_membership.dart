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
import 'package:top_attempt_global_client/src/protocol/protocol.dart'
    as _i00og34q;
import '../profile/member_profile.dart' as _ieelrt66;
import '../sites/site.dart' as _ie3onmsc;
import '../sites/site_role.dart' as _icyjzuro;

/// Membership of a global user at a site ("Betrieb"). Global source of truth
/// for who belongs to which site in which role; the local instance derives
/// its local representation from this during sync (member -> local
/// member_profile copy without login; staff/admin -> linked local AuthUser
/// with login). Membership links the PERSON via member_profile (not the
/// auth user).
abstract class SiteMembership
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  SiteMembership._({
    this.id,
    required this.siteId,
    this.site,
    required this.profileId,
    this.profile,
    _icyjzuro.SiteRole? role,
    bool? active,
    DateTime? createdAt,
  }) : role = role ?? _icyjzuro.SiteRole.member,
       active = active ?? true,
       createdAt = createdAt ?? DateTime.now();

  factory SiteMembership({
    int? id,
    required int siteId,
    _ie3onmsc.Site? site,
    required int profileId,
    _ieelrt66.MemberProfile? profile,
    _icyjzuro.SiteRole? role,
    bool? active,
    DateTime? createdAt,
  }) = _SiteMembershipImpl;

  factory SiteMembership.fromJson(Map<String, dynamic> jsonSerialization) {
    return SiteMembership(
      id: jsonSerialization['id'] as int?,
      siteId: jsonSerialization['siteId'] as int,
      site: jsonSerialization['site'] == null
          ? null
          : _i00og34q.Protocol().deserialize<_ie3onmsc.Site>(
              jsonSerialization['site'],
            ),
      profileId: jsonSerialization['profileId'] as int,
      profile: jsonSerialization['profile'] == null
          ? null
          : _i00og34q.Protocol().deserialize<_ieelrt66.MemberProfile>(
              jsonSerialization['profile'],
            ),
      role: jsonSerialization['role'] == null
          ? null
          : _icyjzuro.SiteRole.fromJson((jsonSerialization['role'] as String)),
      active: jsonSerialization['active'] == null
          ? null
          : _isc.BoolJsonExtension.fromJson(jsonSerialization['active']),
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  int siteId;

  /// The site this membership belongs to.
  _ie3onmsc.Site? site;

  int profileId;

  /// The person's profile this membership belongs to.
  _ieelrt66.MemberProfile? profile;

  /// Role of the user at the site.
  _icyjzuro.SiteRole role;

  /// Lifecycle status (e.g. invite flows later).
  bool active;

  /// When the membership was created.
  DateTime createdAt;

  /// Returns a shallow copy of this [SiteMembership]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  SiteMembership copyWith({
    int? id,
    int? siteId,
    _ie3onmsc.Site? site,
    int? profileId,
    _ieelrt66.MemberProfile? profile,
    _icyjzuro.SiteRole? role,
    bool? active,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'SiteMembership',
      if (id != null) 'id': id,
      'siteId': siteId,
      if (site != null) 'site': site?.toJson(),
      'profileId': profileId,
      if (profile != null) 'profile': profile?.toJson(),
      'role': role.toJson(),
      'active': active,
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'SiteMembership',
      if (id != null) 'id': id,
      'siteId': siteId,
      if (site != null) 'site': site?.toJsonForProtocol(),
      'profileId': profileId,
      if (profile != null) 'profile': profile?.toJsonForProtocol(),
      'role': role.toJson(),
      'active': active,
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _SiteMembershipImpl extends SiteMembership {
  _SiteMembershipImpl({
    int? id,
    required int siteId,
    _ie3onmsc.Site? site,
    required int profileId,
    _ieelrt66.MemberProfile? profile,
    _icyjzuro.SiteRole? role,
    bool? active,
    DateTime? createdAt,
  }) : super._(
         id: id,
         siteId: siteId,
         site: site,
         profileId: profileId,
         profile: profile,
         role: role,
         active: active,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [SiteMembership]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  SiteMembership copyWith({
    Object? id = _Undefined,
    int? siteId,
    Object? site = _Undefined,
    int? profileId,
    Object? profile = _Undefined,
    _icyjzuro.SiteRole? role,
    bool? active,
    DateTime? createdAt,
  }) {
    return SiteMembership(
      id: id is int? ? id : this.id,
      siteId: siteId ?? this.siteId,
      site: site is _ie3onmsc.Site? ? site : this.site?.copyWith(),
      profileId: profileId ?? this.profileId,
      profile: profile is _ieelrt66.MemberProfile?
          ? profile
          : this.profile?.copyWith(),
      role: role ?? this.role,
      active: active ?? this.active,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
