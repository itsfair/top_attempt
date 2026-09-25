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

/// One pickable site in the local setup mask.
abstract class SiteCandidateLocal
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  SiteCandidateLocal._({
    required this.siteId,
    required this.siteName,
  });

  factory SiteCandidateLocal({
    required int siteId,
    required String siteName,
  }) = _SiteCandidateLocalImpl;

  factory SiteCandidateLocal.fromJson(Map<String, dynamic> jsonSerialization) {
    return SiteCandidateLocal(
      siteId: jsonSerialization['siteId'] as int,
      siteName: jsonSerialization['siteName'] as String,
    );
  }

  /// The site id to pass back to `enterSetup`.
  int siteId;

  /// Human readable site name.
  String siteName;

  /// Returns a shallow copy of this [SiteCandidateLocal]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  SiteCandidateLocal copyWith({
    int? siteId,
    String? siteName,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'SiteCandidateLocal',
      'siteId': siteId,
      'siteName': siteName,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'SiteCandidateLocal',
      'siteId': siteId,
      'siteName': siteName,
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _SiteCandidateLocalImpl extends SiteCandidateLocal {
  _SiteCandidateLocalImpl({
    required int siteId,
    required String siteName,
  }) : super._(
         siteId: siteId,
         siteName: siteName,
       );

  /// Returns a shallow copy of this [SiteCandidateLocal]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  SiteCandidateLocal copyWith({
    int? siteId,
    String? siteName,
  }) {
    return SiteCandidateLocal(
      siteId: siteId ?? this.siteId,
      siteName: siteName ?? this.siteName,
    );
  }
}
