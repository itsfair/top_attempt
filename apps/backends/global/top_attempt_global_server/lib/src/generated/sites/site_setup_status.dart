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

/// Connect status of a site (one operating local instance each).
enum SiteSetupStatus implements _is.SerializableModel {
  /// The site has been created but no local instance has registered yet.
  pendingSetup,

  /// The local instance has registered at least once (see [Site.lastSeenAt]
  /// for connectivity, derived per site in the UI).
  registered;

  static SiteSetupStatus fromJson(String name) {
    switch (name) {
      case 'pendingSetup':
        return SiteSetupStatus.pendingSetup;
      case 'registered':
        return SiteSetupStatus.registered;
      default:
        return SiteSetupStatus.pendingSetup;
    }
  }

  @override
  String toJson() => name;

  @override
  String toString() => name;
}
