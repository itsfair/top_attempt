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

/// Connection state of the device link between this local instance and the
/// site's global instance. Used by the App-Bar chip in the local admin UI.
enum SiteConnectionState implements _isc.SerializableModel {
  /// No enrollment configuration exists yet.
  noneSetup,

  /// Worker is currently opening the stream.
  connecting,

  /// Stream dropped, retrying with backoff.
  reconnecting,

  /// Stream is open and pings are answered.
  connected,

  /// Credential no longer accepted (revoked/expired) — the site admin must
  /// re-run setup with their global credentials.
  needsReSetup,

  /// Persistent failure (e.g. global backend unreachable for a long time).
  failure;

  static SiteConnectionState fromJson(String name) {
    switch (name) {
      case 'noneSetup':
        return SiteConnectionState.noneSetup;
      case 'connecting':
        return SiteConnectionState.connecting;
      case 'reconnecting':
        return SiteConnectionState.reconnecting;
      case 'connected':
        return SiteConnectionState.connected;
      case 'needsReSetup':
        return SiteConnectionState.needsReSetup;
      case 'failure':
        return SiteConnectionState.failure;
      default:
        return SiteConnectionState.noneSetup;
    }
  }

  @override
  String toJson() => name;

  @override
  String toString() => name;
}
