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
import '../site/site_connection_state.dart' as _ilrp6tdy;

/// Snapshots the connection state for the local UI App-Bar chip.
abstract class SiteConnectionInfo
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  SiteConnectionInfo._({
    required this.state,
    this.siteName,
    this.lastError,
    this.lastConnectedAt,
  });

  factory SiteConnectionInfo({
    required _ilrp6tdy.SiteConnectionState state,
    String? siteName,
    String? lastError,
    DateTime? lastConnectedAt,
  }) = _SiteConnectionInfoImpl;

  factory SiteConnectionInfo.fromJson(Map<String, dynamic> jsonSerialization) {
    return SiteConnectionInfo(
      state: _ilrp6tdy.SiteConnectionState.fromJson(
        (jsonSerialization['state'] as String),
      ),
      siteName: jsonSerialization['siteName'] as String?,
      lastError: jsonSerialization['lastError'] as String?,
      lastConnectedAt: jsonSerialization['lastConnectedAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(
              jsonSerialization['lastConnectedAt'],
            ),
    );
  }

  /// Current state.
  _ilrp6tdy.SiteConnectionState state;

  /// Name of the enrolled site (already enrolled only).
  String? siteName;

  /// Last human-readable error (failure/needsReSetup only).
  String? lastError;

  /// Most recent successful ping round trip.
  DateTime? lastConnectedAt;

  /// Returns a shallow copy of this [SiteConnectionInfo]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  SiteConnectionInfo copyWith({
    _ilrp6tdy.SiteConnectionState? state,
    String? siteName,
    String? lastError,
    DateTime? lastConnectedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'SiteConnectionInfo',
      'state': state.toJson(),
      if (siteName != null) 'siteName': siteName,
      if (lastError != null) 'lastError': lastError,
      if (lastConnectedAt != null) 'lastConnectedAt': lastConnectedAt?.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'SiteConnectionInfo',
      'state': state.toJson(),
      if (siteName != null) 'siteName': siteName,
      if (lastError != null) 'lastError': lastError,
      if (lastConnectedAt != null) 'lastConnectedAt': lastConnectedAt?.toJson(),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _SiteConnectionInfoImpl extends SiteConnectionInfo {
  _SiteConnectionInfoImpl({
    required _ilrp6tdy.SiteConnectionState state,
    String? siteName,
    String? lastError,
    DateTime? lastConnectedAt,
  }) : super._(
         state: state,
         siteName: siteName,
         lastError: lastError,
         lastConnectedAt: lastConnectedAt,
       );

  /// Returns a shallow copy of this [SiteConnectionInfo]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  SiteConnectionInfo copyWith({
    _ilrp6tdy.SiteConnectionState? state,
    Object? siteName = _Undefined,
    Object? lastError = _Undefined,
    Object? lastConnectedAt = _Undefined,
  }) {
    return SiteConnectionInfo(
      state: state ?? this.state,
      siteName: siteName is String? ? siteName : this.siteName,
      lastError: lastError is String? ? lastError : this.lastError,
      lastConnectedAt: lastConnectedAt is DateTime?
          ? lastConnectedAt
          : this.lastConnectedAt,
    );
  }
}
