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
import 'package:top_attempt_global_client/src/protocol/protocol.dart'
    as _i00og34q;
import '../admin/user_admin_summary.dart' as _i7fkwu3n;

/// Result of the admin user listing: one page of users plus pagination info.
abstract class AdminUserPage
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  AdminUserPage._({
    required this.items,
    required this.offset,
    required this.total,
  });

  factory AdminUserPage({
    required List<_i7fkwu3n.AdminUserSummary> items,
    required int offset,
    required int total,
  }) = _AdminUserPageImpl;

  factory AdminUserPage.fromJson(Map<String, dynamic> jsonSerialization) {
    return AdminUserPage(
      items: _i00og34q.Protocol().deserialize<List<_i7fkwu3n.AdminUserSummary>>(
        jsonSerialization['items'],
      ),
      offset: jsonSerialization['offset'] as int,
      total: jsonSerialization['total'] as int,
    );
  }

  /// The users of this page.
  List<_i7fkwu3n.AdminUserSummary> items;

  /// The offset this page starts at (equals the passed offset).
  int offset;

  /// Total number of users matching the filter (across all pages).
  int total;

  /// Returns a shallow copy of this [AdminUserPage]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  AdminUserPage copyWith({
    List<_i7fkwu3n.AdminUserSummary>? items,
    int? offset,
    int? total,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'AdminUserPage',
      'items': items.toJson(valueToJson: (v) => v.toJson()),
      'offset': offset,
      'total': total,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'AdminUserPage',
      'items': items.toJson(valueToJson: (v) => v.toJsonForProtocol()),
      'offset': offset,
      'total': total,
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _AdminUserPageImpl extends AdminUserPage {
  _AdminUserPageImpl({
    required List<_i7fkwu3n.AdminUserSummary> items,
    required int offset,
    required int total,
  }) : super._(
         items: items,
         offset: offset,
         total: total,
       );

  /// Returns a shallow copy of this [AdminUserPage]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  AdminUserPage copyWith({
    List<_i7fkwu3n.AdminUserSummary>? items,
    int? offset,
    int? total,
  }) {
    return AdminUserPage(
      items: items ?? this.items.map((e0) => e0.copyWith()).toList(),
      offset: offset ?? this.offset,
      total: total ?? this.total,
    );
  }
}
