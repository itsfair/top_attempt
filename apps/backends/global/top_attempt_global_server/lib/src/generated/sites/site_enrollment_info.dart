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
import '../sites/site_admin_membership_candidate.dart' as _irkdnhll;
import '../sites/site_transfer_info.dart' as _iwpx7u13;

/// Result of a site enrollment attempt by the local instance.
abstract class SiteEnrollmentInfo
    implements _is.SerializableModel, _is.ProtocolSerialization {
  SiteEnrollmentInfo._({
    bool? requiresSiteSelection,
    required this.candidates,
    this.transfer,
  }) : requiresSiteSelection = requiresSiteSelection ?? false;

  factory SiteEnrollmentInfo({
    bool? requiresSiteSelection,
    required List<_irkdnhll.SiteAdminMembershipCandidate> candidates,
    _iwpx7u13.SiteTransferInfo? transfer,
  }) = _SiteEnrollmentInfoImpl;

  factory SiteEnrollmentInfo.fromJson(Map<String, dynamic> jsonSerialization) {
    return SiteEnrollmentInfo(
      requiresSiteSelection: jsonSerialization['requiresSiteSelection'] == null
          ? null
          : _is.BoolJsonExtension.fromJson(
              jsonSerialization['requiresSiteSelection'],
            ),
      candidates: _in02tfqf.Protocol()
          .deserialize<List<_irkdnhll.SiteAdminMembershipCandidate>>(
            jsonSerialization['candidates'],
          ),
      transfer: jsonSerialization['transfer'] == null
          ? null
          : _in02tfqf.Protocol().deserialize<_iwpx7u13.SiteTransferInfo>(
              jsonSerialization['transfer'],
            ),
    );
  }

  /// True when the site admin holds `siteAdmin` memberships for more than
  /// one site: the local setup mask must pick a site and call enroll again
  /// with the chosen [candidates]-siteId. All other fields are empty.
  bool requiresSiteSelection;

  /// The memberships that match (filled only with
  /// [requiresSiteSelection]).
  List<_irkdnhll.SiteAdminMembershipCandidate> candidates;

  /// Present when the enrollment succeeded (fresh setup or recovery). The
  /// local instance stores this and opens the connection with it.
  _iwpx7u13.SiteTransferInfo? transfer;

  /// Returns a shallow copy of this [SiteEnrollmentInfo]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  SiteEnrollmentInfo copyWith({
    bool? requiresSiteSelection,
    List<_irkdnhll.SiteAdminMembershipCandidate>? candidates,
    _iwpx7u13.SiteTransferInfo? transfer,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'SiteEnrollmentInfo',
      'requiresSiteSelection': requiresSiteSelection,
      'candidates': candidates.toJson(valueToJson: (v) => v.toJson()),
      if (transfer != null) 'transfer': transfer?.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'SiteEnrollmentInfo',
      'requiresSiteSelection': requiresSiteSelection,
      'candidates': candidates.toJson(
        valueToJson: (v) => v.toJsonForProtocol(),
      ),
      if (transfer != null) 'transfer': transfer?.toJsonForProtocol(),
    };
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _SiteEnrollmentInfoImpl extends SiteEnrollmentInfo {
  _SiteEnrollmentInfoImpl({
    bool? requiresSiteSelection,
    required List<_irkdnhll.SiteAdminMembershipCandidate> candidates,
    _iwpx7u13.SiteTransferInfo? transfer,
  }) : super._(
         requiresSiteSelection: requiresSiteSelection,
         candidates: candidates,
         transfer: transfer,
       );

  /// Returns a shallow copy of this [SiteEnrollmentInfo]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  SiteEnrollmentInfo copyWith({
    bool? requiresSiteSelection,
    List<_irkdnhll.SiteAdminMembershipCandidate>? candidates,
    Object? transfer = _Undefined,
  }) {
    return SiteEnrollmentInfo(
      requiresSiteSelection:
          requiresSiteSelection ?? this.requiresSiteSelection,
      candidates:
          candidates ?? this.candidates.map((e0) => e0.copyWith()).toList(),
      transfer: transfer is _iwpx7u13.SiteTransferInfo?
          ? transfer
          : this.transfer?.copyWith(),
    );
  }
}
