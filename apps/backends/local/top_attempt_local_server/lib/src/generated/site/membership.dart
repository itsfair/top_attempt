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
import 'package:top_attempt_local_server/src/generated/protocol.dart'
    as _ianhe7y2;

/// Local person directory of this site. Every person of the site appears
/// here — either as plain membership (no local login) or with a linked
/// local AuthUser (site admin / staff with login). One row per global
/// person.
///
/// Person data (email, name, birthday, image) lives ONLY in the linked
/// profile_details row (single-directory principle, analogous to the
/// global instance); the local AuthUser is a pure login credential holder
/// (cascades away) linked only for staff/siteAdmin.
abstract class Membership
    implements _is.TableRow<int?>, _is.ProtocolSerialization {
  Membership._({
    this.id,
    required this.globalAuthUserId,
    this.localAuthUserId,
    this.localAuthUser,
    String? role,
    bool? active,
    DateTime? createdAt,
  }) : role = role ?? 'member',
       active = active ?? true,
       createdAt = createdAt ?? DateTime.now();

  factory Membership({
    int? id,
    required _is.UuidValue globalAuthUserId,
    _is.UuidValue? localAuthUserId,
    _iacs.AuthUser? localAuthUser,
    String? role,
    bool? active,
    DateTime? createdAt,
  }) = _MembershipImpl;

  factory Membership.fromJson(Map<String, dynamic> jsonSerialization) {
    return Membership(
      id: jsonSerialization['id'] as int?,
      globalAuthUserId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['globalAuthUserId'],
      ),
      localAuthUserId: jsonSerialization['localAuthUserId'] == null
          ? null
          : _is.UuidValueJsonExtension.fromJson(
              jsonSerialization['localAuthUserId'],
            ),
      localAuthUser: jsonSerialization['localAuthUser'] == null
          ? null
          : _ianhe7y2.Protocol().deserialize<_iacs.AuthUser>(
              jsonSerialization['localAuthUser'],
            ),
      role: jsonSerialization['role'] as String?,
      active: jsonSerialization['active'] == null
          ? null
          : _is.BoolJsonExtension.fromJson(jsonSerialization['active']),
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
    );
  }

  static final t = MembershipTable();

  static const db = MembershipRepository._();

  @override
  int? id;

  /// The GLOBAL authUserId of the person — the exchange key with the
  /// global instance (and later used by the door-opening flow: ESP32 ->
  /// local backend -> membership lookup). This is NOT the local AuthUser id.
  _is.UuidValue globalAuthUserId;

  _is.UuidValue? localAuthUserId;

  /// Link to the local login account (site admin / staff); null for plain
  /// memberships without login. The local AuthUser uuid is local-only and
  /// must never be used for cross-instance matching. SetNull keeps the
  /// membership (and its person data) when the login account is removed.
  _iacs.AuthUser? localAuthUser;

  /// Role as string, mirrored from the global `SiteRole` (member/staff/
  /// siteAdmin) — synced; the local backend derives privileges from it.
  String role;

  /// Mirrored active state of the global membership.
  bool active;

  /// When the membership was created (at enrollment for the site admin or
  /// when a membership sync event arrived).
  DateTime createdAt;

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [Membership]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  Membership copyWith({
    int? id,
    _is.UuidValue? globalAuthUserId,
    _is.UuidValue? localAuthUserId,
    _iacs.AuthUser? localAuthUser,
    String? role,
    bool? active,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'Membership',
      if (id != null) 'id': id,
      'globalAuthUserId': globalAuthUserId.toJson(),
      if (localAuthUserId != null) 'localAuthUserId': localAuthUserId?.toJson(),
      if (localAuthUser != null) 'localAuthUser': localAuthUser?.toJson(),
      'role': role,
      'active': active,
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'Membership',
      if (id != null) 'id': id,
      'globalAuthUserId': globalAuthUserId.toJson(),
      if (localAuthUserId != null) 'localAuthUserId': localAuthUserId?.toJson(),
      if (localAuthUser != null) 'localAuthUser': localAuthUser?.toJson(),
      'role': role,
      'active': active,
      'createdAt': createdAt.toJson(),
    };
  }

  static MembershipInclude include({_iacs.AuthUserInclude? localAuthUser}) {
    return MembershipInclude._(localAuthUser: localAuthUser);
  }

  static MembershipIncludeList includeList({
    _is.WhereExpressionBuilder<MembershipTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<MembershipTable>? orderBy,
    _is.OrderByListBuilder<MembershipTable>? orderByList,
    MembershipInclude? include,
  }) {
    return MembershipIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(Membership.t),
      orderByList: orderByList?.call(Membership.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _MembershipImpl extends Membership {
  _MembershipImpl({
    int? id,
    required _is.UuidValue globalAuthUserId,
    _is.UuidValue? localAuthUserId,
    _iacs.AuthUser? localAuthUser,
    String? role,
    bool? active,
    DateTime? createdAt,
  }) : super._(
         id: id,
         globalAuthUserId: globalAuthUserId,
         localAuthUserId: localAuthUserId,
         localAuthUser: localAuthUser,
         role: role,
         active: active,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [Membership]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  Membership copyWith({
    Object? id = _Undefined,
    _is.UuidValue? globalAuthUserId,
    Object? localAuthUserId = _Undefined,
    Object? localAuthUser = _Undefined,
    String? role,
    bool? active,
    DateTime? createdAt,
  }) {
    return Membership(
      id: id is int? ? id : this.id,
      globalAuthUserId: globalAuthUserId ?? this.globalAuthUserId,
      localAuthUserId: localAuthUserId is _is.UuidValue?
          ? localAuthUserId
          : this.localAuthUserId,
      localAuthUser: localAuthUser is _iacs.AuthUser?
          ? localAuthUser
          : this.localAuthUser?.copyWith(),
      role: role ?? this.role,
      active: active ?? this.active,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class MembershipUpdateTable extends _is.UpdateTable<MembershipTable> {
  MembershipUpdateTable(super.table);

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> globalAuthUserId(
    _is.UuidValue value,
  ) => _is.ColumnValue(
    table.globalAuthUserId,
    value,
  );

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> localAuthUserId(
    _is.UuidValue? value,
  ) => _is.ColumnValue(
    table.localAuthUserId,
    value,
  );

  _is.ColumnValue<String, String> role(String value) => _is.ColumnValue(
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

class MembershipTable extends _is.Table<int?> {
  MembershipTable({super.tableRelation}) : super(tableName: 'memberships') {
    updateTable = MembershipUpdateTable(this);
    globalAuthUserId = _is.ColumnUuid(
      'globalAuthUserId',
      this,
    );
    localAuthUserId = _is.ColumnUuid(
      'localAuthUserId',
      this,
    );
    role = _is.ColumnString(
      'role',
      this,
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

  late final MembershipUpdateTable updateTable;

  /// The GLOBAL authUserId of the person — the exchange key with the
  /// global instance (and later used by the door-opening flow: ESP32 ->
  /// local backend -> membership lookup). This is NOT the local AuthUser id.
  late final _is.ColumnUuid globalAuthUserId;

  late final _is.ColumnUuid localAuthUserId;

  /// Link to the local login account (site admin / staff); null for plain
  /// memberships without login. The local AuthUser uuid is local-only and
  /// must never be used for cross-instance matching. SetNull keeps the
  /// membership (and its person data) when the login account is removed.
  _iacs.AuthUserTable? _localAuthUser;

  /// Role as string, mirrored from the global `SiteRole` (member/staff/
  /// siteAdmin) — synced; the local backend derives privileges from it.
  late final _is.ColumnString role;

  /// Mirrored active state of the global membership.
  late final _is.ColumnBool active;

  /// When the membership was created (at enrollment for the site admin or
  /// when a membership sync event arrived).
  late final _is.ColumnDateTime createdAt;

  _iacs.AuthUserTable get localAuthUser {
    if (_localAuthUser != null) return _localAuthUser!;
    _localAuthUser = _is.createRelationTable(
      relationFieldName: 'localAuthUser',
      field: Membership.t.localAuthUserId,
      foreignField: _iacs.AuthUser.t.id,
      tableRelation: tableRelation,
      createTable: (foreignTableRelation) =>
          _iacs.AuthUserTable(tableRelation: foreignTableRelation),
    );
    return _localAuthUser!;
  }

  @override
  List<_is.Column> get columns => [
    id,
    globalAuthUserId,
    localAuthUserId,
    role,
    active,
    createdAt,
  ];

  @override
  _is.Table? getRelationTable(String relationField) {
    if (relationField == 'localAuthUser') {
      return localAuthUser;
    }
    return null;
  }
}

class MembershipInclude extends _is.IncludeObject {
  MembershipInclude._({_iacs.AuthUserInclude? localAuthUser}) {
    _localAuthUser = localAuthUser;
  }

  _iacs.AuthUserInclude? _localAuthUser;

  @override
  Map<String, _is.Include?> get includes => {'localAuthUser': _localAuthUser};

  @override
  _is.Table<int?> get table => Membership.t;
}

class MembershipIncludeList extends _is.IncludeList {
  MembershipIncludeList._({
    _is.WhereExpressionBuilder<MembershipTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(Membership.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => Membership.t;
}

class MembershipRepository {
  const MembershipRepository._();

  final attachRow = const MembershipAttachRowRepository._();

  final detachRow = const MembershipDetachRowRepository._();

  /// Returns a list of [Membership]s matching the given query parameters.
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
  Future<List<Membership>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<MembershipTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<MembershipTable>? orderBy,
    _is.OrderByListBuilder<MembershipTable>? orderByList,
    _is.Transaction? transaction,
    MembershipInclude? include,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<Membership>(
      where: where?.call(Membership.t),
      orderBy: orderBy?.call(Membership.t),
      orderByList: orderByList?.call(Membership.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      include: include,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [Membership] matching the given query parameters.
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
  Future<Membership?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<MembershipTable>? where,
    int? offset,
    _is.OrderByBuilder<MembershipTable>? orderBy,
    _is.OrderByListBuilder<MembershipTable>? orderByList,
    _is.Transaction? transaction,
    MembershipInclude? include,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<Membership>(
      where: where?.call(Membership.t),
      orderBy: orderBy?.call(Membership.t),
      orderByList: orderByList?.call(Membership.t),
      offset: offset,
      transaction: transaction,
      include: include,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [Membership] by its [id] or null if no such row exists.
  Future<Membership?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    MembershipInclude? include,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<Membership>(
      id,
      transaction: transaction,
      include: include,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [Membership]s in the list and returns the inserted rows.
  ///
  /// The returned [Membership]s will have their `id` fields set.
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
  Future<List<Membership>> insert(
    _is.DatabaseSession session,
    List<Membership> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<Membership>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [Membership] and returns the inserted row.
  ///
  /// The returned [Membership] will have its `id` field set.
  Future<Membership> insertRow(
    _is.DatabaseSession session,
    Membership row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<Membership>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [Membership]s in the list and returns the resulting rows.
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
  /// The returned [Membership]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<Membership>> upsert(
    _is.DatabaseSession session,
    List<Membership> rows, {
    required _is.ColumnSelections<MembershipTable> conflictColumns,
    _is.ColumnSelections<MembershipTable>? updateColumns,
    _is.WhereExpressionBuilder<MembershipTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<Membership>(
      rows,
      conflictColumns: conflictColumns(Membership.t),
      updateColumns: updateColumns?.call(Membership.t),
      updateWhere: updateWhere?.call(Membership.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [Membership] and returns the resulting row.
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
  /// The returned [Membership] will have its `id` field set.
  Future<Membership?> upsertRow(
    _is.DatabaseSession session,
    Membership row, {
    required _is.ColumnSelections<MembershipTable> conflictColumns,
    _is.ColumnSelections<MembershipTable>? updateColumns,
    _is.WhereExpressionBuilder<MembershipTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<Membership>(
      row,
      conflictColumns: conflictColumns(Membership.t),
      updateColumns: updateColumns?.call(Membership.t),
      updateWhere: updateWhere?.call(Membership.t),
      transaction: transaction,
    );
  }

  /// Updates all [Membership]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<Membership>> update(
    _is.DatabaseSession session,
    List<Membership> rows, {
    _is.ColumnSelections<MembershipTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<Membership>(
      rows,
      columns: columns?.call(Membership.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [Membership]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<Membership> updateRow(
    _is.DatabaseSession session,
    Membership row, {
    _is.ColumnSelections<MembershipTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<Membership>(
      row,
      columns: columns?.call(Membership.t),
      transaction: transaction,
    );
  }

  /// Updates a single [Membership] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<Membership?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<MembershipUpdateTable> columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<Membership>(
      id,
      columnValues: columnValues(Membership.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [Membership]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<Membership>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<MembershipUpdateTable> columnValues,
    required _is.WhereExpressionBuilder<MembershipTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<MembershipTable>? orderBy,
    _is.OrderByListBuilder<MembershipTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<Membership>(
      columnValues: columnValues(Membership.t.updateTable),
      where: where(Membership.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(Membership.t),
      orderByList: orderByList?.call(Membership.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [Membership]s in the list and returns the deleted rows.
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
  Future<List<Membership>> delete(
    _is.DatabaseSession session,
    List<Membership> rows, {
    _is.OrderByBuilder<MembershipTable>? orderBy,
    _is.OrderByListBuilder<MembershipTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<Membership>(
      rows,
      orderBy: orderBy?.call(Membership.t),
      orderByList: orderByList?.call(Membership.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [Membership].
  Future<Membership> deleteRow(
    _is.DatabaseSession session,
    Membership row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<Membership>(
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
  Future<List<Membership>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<MembershipTable> where,
    _is.OrderByBuilder<MembershipTable>? orderBy,
    _is.OrderByListBuilder<MembershipTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<Membership>(
      where: where(Membership.t),
      orderBy: orderBy?.call(Membership.t),
      orderByList: orderByList?.call(Membership.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<MembershipTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<Membership>(
      where: where?.call(Membership.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [Membership] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<MembershipTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<Membership>(
      where: where(Membership.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}

class MembershipAttachRowRepository {
  const MembershipAttachRowRepository._();

  /// Creates a relation between the given [Membership] and [AuthUser]
  /// by setting the [Membership]'s foreign key `localAuthUserId` to refer to the [AuthUser].
  Future<void> localAuthUser(
    _is.DatabaseSession session,
    Membership membership,
    _iacs.AuthUser localAuthUser, {
    _is.Transaction? transaction,
  }) async {
    if (membership.id == null) {
      throw ArgumentError.notNull('membership.id');
    }
    if (localAuthUser.id == null) {
      throw ArgumentError.notNull('localAuthUser.id');
    }

    var $membership = membership.copyWith(localAuthUserId: localAuthUser.id);
    await session.db.updateRow<Membership>(
      $membership,
      columns: [Membership.t.localAuthUserId],
      transaction: transaction,
    );
  }
}

class MembershipDetachRowRepository {
  const MembershipDetachRowRepository._();

  /// Detaches the relation between this [Membership] and the [AuthUser] set in `localAuthUser`
  /// by setting the [Membership]'s foreign key `localAuthUserId` to `null`.
  ///
  /// This removes the association between the two models without deleting
  /// the related record.
  Future<void> localAuthUser(
    _is.DatabaseSession session,
    Membership membership, {
    _is.Transaction? transaction,
  }) async {
    if (membership.id == null) {
      throw ArgumentError.notNull('membership.id');
    }

    var $membership = membership.copyWith(localAuthUserId: null);
    await session.db.updateRow<Membership>(
      $membership,
      columns: [Membership.t.localAuthUserId],
      transaction: transaction,
    );
  }
}
