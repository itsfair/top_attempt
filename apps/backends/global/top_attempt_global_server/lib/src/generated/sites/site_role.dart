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

/// Role of a user at a site ("Betrieb"). Determines the local representation:
/// member = local members row without login; staff/admin = linked local
/// AuthUser with login.
enum SiteRole implements _is.SerializableModel {
  /// End user without local login.
  member,

  /// Employee with local login (scope at the local instance).
  staff,

  /// Site administrator with local login and `local-admin` scope.
  siteAdmin;

  static SiteRole fromJson(String name) {
    switch (name) {
      case 'member':
        return SiteRole.member;
      case 'staff':
        return SiteRole.staff;
      case 'siteAdmin':
        return SiteRole.siteAdmin;
      default:
        return SiteRole.member;
    }
  }

  @override
  String toJson() => name;

  @override
  String toString() => name;
}
