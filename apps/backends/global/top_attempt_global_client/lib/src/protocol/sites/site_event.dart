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

/// Server to client event on the site connection stream.
abstract class SiteEvent
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  SiteEvent._({
    int? pongSentAtMs,
    int? pingSentAtMs,
    int? sentAtMs,
  }) : pongSentAtMs = pongSentAtMs ?? 0,
       pingSentAtMs = pingSentAtMs ?? 0,
       sentAtMs = sentAtMs ?? 0;

  factory SiteEvent({
    int? pongSentAtMs,
    int? pingSentAtMs,
    int? sentAtMs,
  }) = _SiteEventImpl;

  factory SiteEvent.fromJson(Map<String, dynamic> jsonSerialization) {
    return SiteEvent(
      pongSentAtMs: jsonSerialization['pongSentAtMs'] as int?,
      pingSentAtMs: jsonSerialization['pingSentAtMs'] as int?,
      sentAtMs: jsonSerialization['sentAtMs'] as int?,
    );
  }

  /// Acknowledgement for a received ping.
  int pongSentAtMs;

  /// Round trip marker: matches `SitePing.sentAtMs` when pong.
  int pingSentAtMs;

  /// Millisecond timestamp of the senders send time.
  int sentAtMs;

  /// Returns a shallow copy of this [SiteEvent]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  SiteEvent copyWith({
    int? pongSentAtMs,
    int? pingSentAtMs,
    int? sentAtMs,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'SiteEvent',
      'pongSentAtMs': pongSentAtMs,
      'pingSentAtMs': pingSentAtMs,
      'sentAtMs': sentAtMs,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'SiteEvent',
      'pongSentAtMs': pongSentAtMs,
      'pingSentAtMs': pingSentAtMs,
      'sentAtMs': sentAtMs,
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _SiteEventImpl extends SiteEvent {
  _SiteEventImpl({
    int? pongSentAtMs,
    int? pingSentAtMs,
    int? sentAtMs,
  }) : super._(
         pongSentAtMs: pongSentAtMs,
         pingSentAtMs: pingSentAtMs,
         sentAtMs: sentAtMs,
       );

  /// Returns a shallow copy of this [SiteEvent]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  SiteEvent copyWith({
    int? pongSentAtMs,
    int? pingSentAtMs,
    int? sentAtMs,
  }) {
    return SiteEvent(
      pongSentAtMs: pongSentAtMs ?? this.pongSentAtMs,
      pingSentAtMs: pingSentAtMs ?? this.pingSentAtMs,
      sentAtMs: sentAtMs ?? this.sentAtMs,
    );
  }
}
