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
import 'package:top_attempt_local_server/src/generated/protocol.dart'
    as _ianhe7y2;
import '../site/site_candidate_local.dart' as _ipydjd4c;

/// Result of `siteSetup.enterSetup` in the local admin UI.
abstract class SiteSetupResult
    implements _is.SerializableModel, _is.ProtocolSerialization {
  SiteSetupResult._({
    bool? requiresSiteSelection,
    required this.candidates,
    this.siteId,
    this.siteName,
  }) : requiresSiteSelection = requiresSiteSelection ?? false;

  factory SiteSetupResult({
    bool? requiresSiteSelection,
    required List<_ipydjd4c.SiteCandidateLocal> candidates,
    int? siteId,
    String? siteName,
  }) = _SiteSetupResultImpl;

  factory SiteSetupResult.fromJson(Map<String, dynamic> jsonSerialization) {
    return SiteSetupResult(
      requiresSiteSelection: jsonSerialization['requiresSiteSelection'] == null
          ? null
          : _is.BoolJsonExtension.fromJson(
              jsonSerialization['requiresSiteSelection'],
            ),
      candidates: _ianhe7y2.Protocol()
          .deserialize<List<_ipydjd4c.SiteCandidateLocal>>(
            jsonSerialization['candidates'],
          ),
      siteId: jsonSerialization['siteId'] as int?,
      siteName: jsonSerialization['siteName'] as String?,
    );
  }

  /// True when the chosen global user is site admin of several sites — the
  /// setup mask must show [candidates] and call again with one chosen.
  bool requiresSiteSelection;

  /// The sites to pick from ([requiresSiteSelection] only).
  List<_ipydjd4c.SiteCandidateLocal> candidates;

  /// The enrolled site (fresh setup or recovery).
  int? siteId;

  /// Name of the enrolled site.
  String? siteName;

  /// Returns a shallow copy of this [SiteSetupResult]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  SiteSetupResult copyWith({
    bool? requiresSiteSelection,
    List<_ipydjd4c.SiteCandidateLocal>? candidates,
    int? siteId,
    String? siteName,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'SiteSetupResult',
      'requiresSiteSelection': requiresSiteSelection,
      'candidates': candidates.toJson(valueToJson: (v) => v.toJson()),
      if (siteId != null) 'siteId': siteId,
      if (siteName != null) 'siteName': siteName,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'SiteSetupResult',
      'requiresSiteSelection': requiresSiteSelection,
      'candidates': candidates.toJson(
        valueToJson: (v) => v.toJsonForProtocol(),
      ),
      if (siteId != null) 'siteId': siteId,
      if (siteName != null) 'siteName': siteName,
    };
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _SiteSetupResultImpl extends SiteSetupResult {
  _SiteSetupResultImpl({
    bool? requiresSiteSelection,
    required List<_ipydjd4c.SiteCandidateLocal> candidates,
    int? siteId,
    String? siteName,
  }) : super._(
         requiresSiteSelection: requiresSiteSelection,
         candidates: candidates,
         siteId: siteId,
         siteName: siteName,
       );

  /// Returns a shallow copy of this [SiteSetupResult]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  SiteSetupResult copyWith({
    bool? requiresSiteSelection,
    List<_ipydjd4c.SiteCandidateLocal>? candidates,
    Object? siteId = _Undefined,
    Object? siteName = _Undefined,
  }) {
    return SiteSetupResult(
      requiresSiteSelection:
          requiresSiteSelection ?? this.requiresSiteSelection,
      candidates:
          candidates ?? this.candidates.map((e0) => e0.copyWith()).toList(),
      siteId: siteId is int? ? siteId : this.siteId,
      siteName: siteName is String? ? siteName : this.siteName,
    );
  }
}
