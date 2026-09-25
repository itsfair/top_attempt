/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters
// ignore_for_file: invalid_use_of_internal_member
// ignore_for_file: dead_code, unnecessary_null_comparison

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:serverpod/serverpod.dart' as _is;
import 'package:serverpod_auth_core_server/serverpod_auth_core_server.dart'
    as _iacs;
import 'package:top_attempt_global_server/src/generated/protocol.dart'
    as _in02tfqf;
import '../sites/site.dart' as _ie3onmsc;
import '../sites/site_role.dart' as _icyjzuro;

/// Membership of a global user at a site ("Betrieb"). Global source of truth
/// for who belongs to which site in which role; the local instance derives
/// its local representation from this during sync (member -> local members
/// row without login; staff/admin -> linked local AuthUser with login).
abstract class SiteMembership
    implements _is.TableRow<int?>, _is.ProtocolSerialization {
  SiteMembership._({
    this.id,
    required this.siteId,
    this.site,
    required this.authUserId,
    this.authUser,
    _icyjzuro.SiteRole? role,
    bool? active,
    DateTime? createdAt,
  }) : role = role ?? _icyjzuro.SiteRole.member,
       active = active ?? true,
       createdAt = createdAt ?? DateTime.now();

  factory SiteMembership({
    int? id,
    required int siteId,
    _ie3onmsc.Site? site,
    required _is.UuidValue authUserId,
    _iacs.AuthUser? authUser,
    _icyjzuro.SiteRole? role,
    bool? active,
    DateTime? createdAt,
  }) = _SiteMembershipImpl;

  factory SiteMembership.fromJson(Map<String, dynamic> jsonSerialization) {
    return SiteMembership(
      id: jsonSerialization['id'] as int?,
      siteId: jsonSerialization['siteId'] as int,
      site: jsonSerialization['site'] == null
          ? null
          : _in02tfqf.Protocol().deserialize<_ie3onmsc.Site>(
              jsonSerialization['site'],
            ),
      authUserId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['authUserId'],
      ),
      authUser: jsonSerialization['authUser'] == null
          ? null
          : _in02tfqf.Protocol().deserialize<_iacs.AuthUser>(
              jsonSerialization['authUser'],
            ),
      role: jsonSerialization['role'] == null
          ? null
          : _icyjzuro.SiteRole.fromJson((jsonSerialization['role'] as String)),
      active: jsonSerialization['active'] == null
          ? null
          : _is.BoolJsonExtension.fromJson(jsonSerialization['active']),
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
    );
  }

  static final t = SiteMembershipTable();

  static const db = SiteMembershipRepository._();

  @override
  int? id;

  int siteId;

  /// The site this membership belongs to.
  _ie3onmsc.Site? site;

  _is.UuidValue authUserId;

  /// The global user this membership belongs to.
  _iacs.AuthUser? authUser;

  /// Role of the user at the site.
  _icyjzuro.SiteRole role;

  /// Lifecycle status (e.g. invite flows later).
  bool active;

  /// When the membership was created.
  DateTime createdAt;

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [SiteMembership]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  SiteMembership copyWith({
    int? id,
    int? siteId,
    _ie3onmsc.Site? site,
    _is.UuidValue? authUserId,
    _iacs.AuthUser? authUser,
    _icyjzuro.SiteRole? role,
    bool? active,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'SiteMembership',
      if (id != null) 'id': id,
      'siteId': siteId,
      if (site != null) 'site': site?.toJson(),
      'authUserId': authUserId.toJson(),
      if (authUser != null) 'authUser': authUser?.toJson(),
      'role': role.toJson(),
      'active': active,
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'SiteMembership',
      if (id != null) 'id': id,
      'siteId': siteId,
      if (site != null) 'site': site?.toJsonForProtocol(),
      'authUserId': authUserId.toJson(),
      if (authUser != null) 'authUser': authUser?.toJson(),
      'role': role.toJson(),
      'active': active,
      'createdAt': createdAt.toJson(),
    };
  }

  static SiteMembershipInclude include({
    _ie3onmsc.SiteInclude? site,
    _iacs.AuthUserInclude? authUser,
  }) {
    return SiteMembershipInclude._(
      site: site,
      authUser: authUser,
    );
  }

  static SiteMembershipIncludeList includeList({
    _is.WhereExpressionBuilder<SiteMembershipTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<SiteMembershipTable>? orderBy,
    _is.OrderByListBuilder<SiteMembershipTable>? orderByList,
    SiteMembershipInclude? include,
  }) {
    return SiteMembershipIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(SiteMembership.t),
      orderByList: orderByList?.call(SiteMembership.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _SiteMembershipImpl extends SiteMembership {
  _SiteMembershipImpl({
    int? id,
    required int siteId,
    _ie3onmsc.Site? site,
    required _is.UuidValue authUserId,
    _iacs.AuthUser? authUser,
    _icyjzuro.SiteRole? role,
    bool? active,
    DateTime? createdAt,
  }) : super._(
         id: id,
         siteId: siteId,
         site: site,
         authUserId: authUserId,
         authUser: authUser,
         role: role,
         active: active,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [SiteMembership]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  SiteMembership copyWith({
    Object? id = _Undefined,
    int? siteId,
    Object? site = _Undefined,
    _is.UuidValue? authUserId,
    Object? authUser = _Undefined,
    _icyjzuro.SiteRole? role,
    bool? active,
    DateTime? createdAt,
  }) {
    return SiteMembership(
      id: id is int? ? id : this.id,
      siteId: siteId ?? this.siteId,
      site: site is _ie3onmsc.Site? ? site : this.site?.copyWith(),
      authUserId: authUserId ?? this.authUserId,
      authUser: authUser is _iacs.AuthUser?
          ? authUser
          : this.authUser?.copyWith(),
      role: role ?? this.role,
      active: active ?? this.active,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class SiteMembershipUpdateTable extends _is.UpdateTable<SiteMembershipTable> {
  SiteMembershipUpdateTable(super.table);

  _is.ColumnValue<int, int> siteId(int value) => _is.ColumnValue(
    table.siteId,
    value,
  );

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> authUserId(
    _is.UuidValue value,
  ) => _is.ColumnValue(
    table.authUserId,
    value,
  );

  _is.ColumnValue<_icyjzuro.SiteRole, _icyjzuro.SiteRole> role(
    _icyjzuro.SiteRole value,
  ) => _is.ColumnValue(
    table.role,
    value,
  );

  _is.ColumnValue<bool, bool> active(bool value) => _is.ColumnValue(
    table.active,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> createdAt(DateTime value) =>
      _is.ColumnValue(
        table.createdAt,
        value,
      );
}

class SiteMembershipTable extends _is.Table<int?> {
  SiteMembershipTable({super.tableRelation})
    : super(tableName: 'site_memberships') {
    updateTable = SiteMembershipUpdateTable(this);
    siteId = _is.ColumnInt(
      'siteId',
      this,
    );
    authUserId = _is.ColumnUuid(
      'authUserId',
      this,
    );
    role = _is.ColumnEnum(
      'role',
      this,
      _is.EnumSerialization.byName,
      hasDefault: true,
    );
    active = _is.ColumnBool(
      'active',
      this,
    );
    createdAt = _is.ColumnDateTime(
      'createdAt',
      this,
    );
  }

  late final SiteMembershipUpdateTable updateTable;

  late final _is.ColumnInt siteId;

  /// The site this membership belongs to.
  _ie3onmsc.SiteTable? _site;

  late final _is.ColumnUuid authUserId;

  /// The global user this membership belongs to.
  _iacs.AuthUserTable? _authUser;

  /// Role of the user at the site.
  late final _is.ColumnEnum<_icyjzuro.SiteRole> role;

  /// Lifecycle status (e.g. invite flows later).
  late final _is.ColumnBool active;

  /// When the membership was created.
  late final _is.ColumnDateTime createdAt;

  _ie3onmsc.SiteTable get site {
    if (_site != null) return _site!;
    _site = _is.createRelationTable(
      relationFieldName: 'site',
      field: SiteMembership.t.siteId,
      foreignField: _ie3onmsc.Site.t.id,
      tableRelation: tableRelation,
      createTable: (foreignTableRelation) =>
          _ie3onmsc.SiteTable(tableRelation: foreignTableRelation),
    );
    return _site!;
  }

  _iacs.AuthUserTable get authUser {
    if (_authUser != null) return _authUser!;
    _authUser = _is.createRelationTable(
      relationFieldName: 'authUser',
      field: SiteMembership.t.authUserId,
      foreignField: _iacs.AuthUser.t.id,
      tableRelation: tableRelation,
      createTable: (foreignTableRelation) =>
          _iacs.AuthUserTable(tableRelation: foreignTableRelation),
    );
    return _authUser!;
  }

  @override
  List<_is.Column> get columns => [
    id,
    siteId,
    authUserId,
    role,
    active,
    createdAt,
  ];

  @override
  _is.Table? getRelationTable(String relationField) {
    if (relationField == 'site') {
      return site;
    }
    if (relationField == 'authUser') {
      return authUser;
    }
    return null;
  }
}

class SiteMembershipInclude extends _is.IncludeObject {
  SiteMembershipInclude._({
    _ie3onmsc.SiteInclude? site,
    _iacs.AuthUserInclude? authUser,
  }) {
    _site = site;
    _authUser = authUser;
  }

  _ie3onmsc.SiteInclude? _site;

  _iacs.AuthUserInclude? _authUser;

  @override
  Map<String, _is.Include?> get includes => {
    'site': _site,
    'authUser': _authUser,
  };

  @override
  _is.Table<int?> get table => SiteMembership.t;
}

class SiteMembershipIncludeList extends _is.IncludeList {
  SiteMembershipIncludeList._({
    _is.WhereExpressionBuilder<SiteMembershipTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(SiteMembership.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => SiteMembership.t;
}

class SiteMembershipRepository {
  const SiteMembershipRepository._();

  final attachRow = const SiteMembershipAttachRowRepository._();

  /// Returns a list of [SiteMembership]s matching the given query parameters.
  ///
  /// Use [where] to specify which items to include in the return value.
  /// If none is specified, all items will be returned.
  ///
  /// To specify the order of the items use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// The maximum number of items can be set by [limit]. If no limit is set,
  /// all items matching the query will be returned.
  ///
  /// [offset] defines how many items to skip, after which [limit] (or all)
  /// items are read from the database.
  ///
  /// ```dart
  /// var persons = await Persons.db.find(
  ///   session,
  ///   where: (t) => t.lastName.equals('Jones'),
  ///   orderBy: (t) => t.firstName,
  ///   limit: 100,
  /// );
  /// ```
  Future<List<SiteMembership>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<SiteMembershipTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<SiteMembershipTable>? orderBy,
    _is.OrderByListBuilder<SiteMembershipTable>? orderByList,
    _is.Transaction? transaction,
    SiteMembershipInclude? include,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<SiteMembership>(
      where: where?.call(SiteMembership.t),
      orderBy: orderBy?.call(SiteMembership.t),
      orderByList: orderByList?.call(SiteMembership.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      include: include,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [SiteMembership] matching the given query parameters.
  ///
  /// Use [where] to specify which items to include in the return value.
  /// If none is specified, all items will be returned.
  ///
  /// To specify the order use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// [offset] defines how many items to skip, after which the next one will be picked.
  ///
  /// ```dart
  /// var youngestPerson = await Persons.db.findFirstRow(
  ///   session,
  ///   where: (t) => t.lastName.equals('Jones'),
  ///   orderBy: (t) => t.age,
  /// );
  /// ```
  Future<SiteMembership?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<SiteMembershipTable>? where,
    int? offset,
    _is.OrderByBuilder<SiteMembershipTable>? orderBy,
    _is.OrderByListBuilder<SiteMembershipTable>? orderByList,
    _is.Transaction? transaction,
    SiteMembershipInclude? include,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<SiteMembership>(
      where: where?.call(SiteMembership.t),
      orderBy: orderBy?.call(SiteMembership.t),
      orderByList: orderByList?.call(SiteMembership.t),
      offset: offset,
      transaction: transaction,
      include: include,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [SiteMembership] by its [id] or null if no such row exists.
  Future<SiteMembership?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    SiteMembershipInclude? include,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<SiteMembership>(
      id,
      transaction: transaction,
      include: include,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [SiteMembership]s in the list and returns the inserted rows.
  ///
  /// The returned [SiteMembership]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  ///
  /// If [ignoreConflicts] is set to `true`, rows that conflict with existing
  /// rows are silently skipped, and only the successfully inserted rows are
  /// returned.
  ///
  /// If [noReturn] is set to `true`, the inserted rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<SiteMembership>> insert(
    _is.DatabaseSession session,
    List<SiteMembership> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<SiteMembership>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [SiteMembership] and returns the inserted row.
  ///
  /// The returned [SiteMembership] will have its `id` field set.
  Future<SiteMembership> insertRow(
    _is.DatabaseSession session,
    SiteMembership row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<SiteMembership>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [SiteMembership]s in the list and returns the resulting rows.
  ///
  /// If a row conflicts on the given [conflictColumns], the existing row is
  /// updated with the new values. Otherwise, a new row is inserted.
  ///
  /// If [updateColumns] is provided, only those columns will be updated on
  /// conflict. If null, all non-conflict, non-id columns are updated.
  ///
  /// If [updateWhere] is provided, the update only applies to rows matching the
  /// given expression. Conflicting rows that don't match are skipped and not
  /// returned, so the resulting list may be shorter than [rows].
  ///
  /// The returned [SiteMembership]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<SiteMembership>> upsert(
    _is.DatabaseSession session,
    List<SiteMembership> rows, {
    required _is.ColumnSelections<SiteMembershipTable> conflictColumns,
    _is.ColumnSelections<SiteMembershipTable>? updateColumns,
    _is.WhereExpressionBuilder<SiteMembershipTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<SiteMembership>(
      rows,
      conflictColumns: conflictColumns(SiteMembership.t),
      updateColumns: updateColumns?.call(SiteMembership.t),
      updateWhere: updateWhere?.call(SiteMembership.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [SiteMembership] and returns the resulting row.
  ///
  /// If the row conflicts on the given [conflictColumns], the existing row is
  /// updated. Otherwise, a new row is inserted.
  ///
  /// If [updateColumns] is provided, only those columns will be updated on
  /// conflict. If null, all non-conflict, non-id columns are updated.
  ///
  /// If [updateWhere] is provided, the update only applies when the existing
  /// row matches the expression. Returns `null` if no row was affected — for
  /// example when [updateWhere] does not match the conflicting row.
  ///
  /// The returned [SiteMembership] will have its `id` field set.
  Future<SiteMembership?> upsertRow(
    _is.DatabaseSession session,
    SiteMembership row, {
    required _is.ColumnSelections<SiteMembershipTable> conflictColumns,
    _is.ColumnSelections<SiteMembershipTable>? updateColumns,
    _is.WhereExpressionBuilder<SiteMembershipTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<SiteMembership>(
      row,
      conflictColumns: conflictColumns(SiteMembership.t),
      updateColumns: updateColumns?.call(SiteMembership.t),
      updateWhere: updateWhere?.call(SiteMembership.t),
      transaction: transaction,
    );
  }

  /// Updates all [SiteMembership]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<SiteMembership>> update(
    _is.DatabaseSession session,
    List<SiteMembership> rows, {
    _is.ColumnSelections<SiteMembershipTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<SiteMembership>(
      rows,
      columns: columns?.call(SiteMembership.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [SiteMembership]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<SiteMembership> updateRow(
    _is.DatabaseSession session,
    SiteMembership row, {
    _is.ColumnSelections<SiteMembershipTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<SiteMembership>(
      row,
      columns: columns?.call(SiteMembership.t),
      transaction: transaction,
    );
  }

  /// Updates a single [SiteMembership] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<SiteMembership?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<SiteMembershipUpdateTable> columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<SiteMembership>(
      id,
      columnValues: columnValues(SiteMembership.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [SiteMembership]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<SiteMembership>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<SiteMembershipUpdateTable> columnValues,
    required _is.WhereExpressionBuilder<SiteMembershipTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<SiteMembershipTable>? orderBy,
    _is.OrderByListBuilder<SiteMembershipTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<SiteMembership>(
      columnValues: columnValues(SiteMembership.t.updateTable),
      where: where(SiteMembership.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(SiteMembership.t),
      orderByList: orderByList?.call(SiteMembership.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [SiteMembership]s in the list and returns the deleted rows.
  ///
  /// To specify the order of the returned rows use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  ///
  /// If [noReturn] is set to `true`, the deleted rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<SiteMembership>> delete(
    _is.DatabaseSession session,
    List<SiteMembership> rows, {
    _is.OrderByBuilder<SiteMembershipTable>? orderBy,
    _is.OrderByListBuilder<SiteMembershipTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<SiteMembership>(
      rows,
      orderBy: orderBy?.call(SiteMembership.t),
      orderByList: orderByList?.call(SiteMembership.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [SiteMembership].
  Future<SiteMembership> deleteRow(
    _is.DatabaseSession session,
    SiteMembership row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<SiteMembership>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  ///
  /// To specify the order of the returned rows use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// If [noReturn] is set to `true`, the deleted rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<SiteMembership>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<SiteMembershipTable> where,
    _is.OrderByBuilder<SiteMembershipTable>? orderBy,
    _is.OrderByListBuilder<SiteMembershipTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<SiteMembership>(
      where: where(SiteMembership.t),
      orderBy: orderBy?.call(SiteMembership.t),
      orderByList: orderByList?.call(SiteMembership.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<SiteMembershipTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<SiteMembership>(
      where: where?.call(SiteMembership.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [SiteMembership] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<SiteMembershipTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<SiteMembership>(
      where: where(SiteMembership.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}

class SiteMembershipAttachRowRepository {
  const SiteMembershipAttachRowRepository._();

  /// Creates a relation between the given [SiteMembership] and [Site]
  /// by setting the [SiteMembership]'s foreign key `siteId` to refer to the [Site].
  Future<void> site(
    _is.DatabaseSession session,
    SiteMembership siteMembership,
    _ie3onmsc.Site site, {
    _is.Transaction? transaction,
  }) async {
    if (siteMembership.id == null) {
      throw ArgumentError.notNull('siteMembership.id');
    }
    if (site.id == null) {
      throw ArgumentError.notNull('site.id');
    }

    var $siteMembership = siteMembership.copyWith(siteId: site.id);
    await session.db.updateRow<SiteMembership>(
      $siteMembership,
      columns: [SiteMembership.t.siteId],
      transaction: transaction,
    );
  }

  /// Creates a relation between the given [SiteMembership] and [AuthUser]
  /// by setting the [SiteMembership]'s foreign key `authUserId` to refer to the [AuthUser].
  Future<void> authUser(
    _is.DatabaseSession session,
    SiteMembership siteMembership,
    _iacs.AuthUser authUser, {
    _is.Transaction? transaction,
  }) async {
    if (siteMembership.id == null) {
      throw ArgumentError.notNull('siteMembership.id');
    }
    if (authUser.id == null) {
      throw ArgumentError.notNull('authUser.id');
    }

    var $siteMembership = siteMembership.copyWith(authUserId: authUser.id);
    await session.db.updateRow<SiteMembership>(
      $siteMembership,
      columns: [SiteMembership.t.authUserId],
      transaction: transaction,
    );
  }
}
