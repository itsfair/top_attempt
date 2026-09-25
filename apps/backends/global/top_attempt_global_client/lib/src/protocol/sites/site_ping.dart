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

/// Either a ping from the local instance (client to server) or an
/// acknowledgement (server to client) on the site connection stream.
abstract class SitePing
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  SitePing._({required this.sentAtMs});

  factory SitePing({required int sentAtMs}) = _SitePingImpl;

  factory SitePing.fromJson(Map<String, dynamic> jsonSerialization) {
    return SitePing(sentAtMs: jsonSerialization['sentAtMs'] as int);
  }

  /// Millisecond timestamp of the senders send time (round trip debugging).
  int sentAtMs;

  /// Returns a shallow copy of this [SitePing]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  SitePing copyWith({int? sentAtMs});
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'SitePing',
      'sentAtMs': sentAtMs,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'SitePing',
      'sentAtMs': sentAtMs,
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _SitePingImpl extends SitePing {
  _SitePingImpl({required int sentAtMs}) : super._(sentAtMs: sentAtMs);

  /// Returns a shallow copy of this [SitePing]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  SitePing copyWith({int? sentAtMs}) {
    return SitePing(sentAtMs: sentAtMs ?? this.sentAtMs);
  }
}
