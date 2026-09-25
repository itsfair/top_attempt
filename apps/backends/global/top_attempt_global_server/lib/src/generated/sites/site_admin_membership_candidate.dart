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

/// One candidate site for a site-admin who is admin of several sites
/// (needed for the site picker in the local setup mask).
abstract class SiteAdminMembershipCandidate
    implements _is.SerializableModel, _is.ProtocolSerialization {
  SiteAdminMembershipCandidate._({
    required this.siteId,
    required this.siteName,
  });

  factory SiteAdminMembershipCandidate({
    required int siteId,
    required String siteName,
  }) = _SiteAdminMembershipCandidateImpl;

  factory SiteAdminMembershipCandidate.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return SiteAdminMembershipCandidate(
      siteId: jsonSerialization['siteId'] as int,
      siteName: jsonSerialization['siteName'] as String,
    );
  }

  /// The site id to pass back to `sitesAdmin.enroll`.
  int siteId;

  /// Human readable name of the site.
  String siteName;

  /// Returns a shallow copy of this [SiteAdminMembershipCandidate]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  SiteAdminMembershipCandidate copyWith({
    int? siteId,
    String? siteName,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'SiteAdminMembershipCandidate',
      'siteId': siteId,
      'siteName': siteName,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'SiteAdminMembershipCandidate',
      'siteId': siteId,
      'siteName': siteName,
    };
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _SiteAdminMembershipCandidateImpl extends SiteAdminMembershipCandidate {
  _SiteAdminMembershipCandidateImpl({
    required int siteId,
    required String siteName,
  }) : super._(
         siteId: siteId,
         siteName: siteName,
       );

  /// Returns a shallow copy of this [SiteAdminMembershipCandidate]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  SiteAdminMembershipCandidate copyWith({
    int? siteId,
    String? siteName,
  }) {
    return SiteAdminMembershipCandidate(
      siteId: siteId ?? this.siteId,
      siteName: siteName ?? this.siteName,
    );
  }
}
