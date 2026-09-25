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
import 'package:top_attempt_global_server/src/generated/protocol.dart'
    as _in02tfqf;
import '../sites/site.dart' as _ie3onmsc;

/// Device session binding for a site connection. One active session per
/// site (the row is replaced on recovery, the old server-side session is
/// revoked together with this row).
abstract class SiteDeviceSession
    implements _is.TableRow<int?>, _is.ProtocolSerialization {
  SiteDeviceSession._({
    this.id,
    required this.siteId,
    this.site,
    required this.serverSideSessionId,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory SiteDeviceSession({
    int? id,
    required int siteId,
    _ie3onmsc.Site? site,
    required _is.UuidValue serverSideSessionId,
    DateTime? createdAt,
  }) = _SiteDeviceSessionImpl;

  factory SiteDeviceSession.fromJson(Map<String, dynamic> jsonSerialization) {
    return SiteDeviceSession(
      id: jsonSerialization['id'] as int?,
      siteId: jsonSerialization['siteId'] as int,
      site: jsonSerialization['site'] == null
          ? null
          : _in02tfqf.Protocol().deserialize<_ie3onmsc.Site>(
              jsonSerialization['site'],
            ),
      serverSideSessionId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['serverSideSessionId'],
      ),
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
    );
  }

  static final t = SiteDeviceSessionTable();

  static const db = SiteDeviceSessionRepository._();

  @override
  int? id;

  int siteId;

  /// The site this device connection belongs to.
  _ie3onmsc.Site? site;

  /// The id of the server-side (SAS) session that carries the device
  /// credential. Resolvable via `session.authenticated!.authId`.
  _is.UuidValue serverSideSessionId;

  /// When the enrollment happened (fresh setup or recovery).
  DateTime createdAt;

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [SiteDeviceSession]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  SiteDeviceSession copyWith({
    int? id,
    int? siteId,
    _ie3onmsc.Site? site,
    _is.UuidValue? serverSideSessionId,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'SiteDeviceSession',
      if (id != null) 'id': id,
      'siteId': siteId,
      if (site != null) 'site': site?.toJson(),
      'serverSideSessionId': serverSideSessionId.toJson(),
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'SiteDeviceSession',
      if (id != null) 'id': id,
      'siteId': siteId,
      if (site != null) 'site': site?.toJsonForProtocol(),
      'serverSideSessionId': serverSideSessionId.toJson(),
      'createdAt': createdAt.toJson(),
    };
  }

  static SiteDeviceSessionInclude include({_ie3onmsc.SiteInclude? site}) {
    return SiteDeviceSessionInclude._(site: site);
  }

  static SiteDeviceSessionIncludeList includeList({
    _is.WhereExpressionBuilder<SiteDeviceSessionTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<SiteDeviceSessionTable>? orderBy,
    _is.OrderByListBuilder<SiteDeviceSessionTable>? orderByList,
    SiteDeviceSessionInclude? include,
  }) {
    return SiteDeviceSessionIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(SiteDeviceSession.t),
      orderByList: orderByList?.call(SiteDeviceSession.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _SiteDeviceSessionImpl extends SiteDeviceSession {
  _SiteDeviceSessionImpl({
    int? id,
    required int siteId,
    _ie3onmsc.Site? site,
    required _is.UuidValue serverSideSessionId,
    DateTime? createdAt,
  }) : super._(
         id: id,
         siteId: siteId,
         site: site,
         serverSideSessionId: serverSideSessionId,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [SiteDeviceSession]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  SiteDeviceSession copyWith({
    Object? id = _Undefined,
    int? siteId,
    Object? site = _Undefined,
    _is.UuidValue? serverSideSessionId,
    DateTime? createdAt,
  }) {
    return SiteDeviceSession(
      id: id is int? ? id : this.id,
      siteId: siteId ?? this.siteId,
      site: site is _ie3onmsc.Site? ? site : this.site?.copyWith(),
      serverSideSessionId: serverSideSessionId ?? this.serverSideSessionId,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class SiteDeviceSessionUpdateTable
    extends _is.UpdateTable<SiteDeviceSessionTable> {
  SiteDeviceSessionUpdateTable(super.table);

  _is.ColumnValue<int, int> siteId(int value) => _is.ColumnValue(
    table.siteId,
    value,
  );

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> serverSideSessionId(
    _is.UuidValue value,
  ) => _is.ColumnValue(
    table.serverSideSessionId,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> createdAt(DateTime value) =>
      _is.ColumnValue(
        table.createdAt,
        value,
      );
}

class SiteDeviceSessionTable extends _is.Table<int?> {
  SiteDeviceSessionTable({super.tableRelation})
    : super(tableName: 'site_device_sessions') {
    updateTable = SiteDeviceSessionUpdateTable(this);
    siteId = _is.ColumnInt(
      'siteId',
      this,
    );
    serverSideSessionId = _is.ColumnUuid(
      'serverSideSessionId',
      this,
    );
    createdAt = _is.ColumnDateTime(
      'createdAt',
      this,
    );
  }

  late final SiteDeviceSessionUpdateTable updateTable;

  late final _is.ColumnInt siteId;

  /// The site this device connection belongs to.
  _ie3onmsc.SiteTable? _site;

  /// The id of the server-side (SAS) session that carries the device
  /// credential. Resolvable via `session.authenticated!.authId`.
  late final _is.ColumnUuid serverSideSessionId;

  /// When the enrollment happened (fresh setup or recovery).
  late final _is.ColumnDateTime createdAt;

  _ie3onmsc.SiteTable get site {
    if (_site != null) return _site!;
    _site = _is.createRelationTable(
      relationFieldName: 'site',
      field: SiteDeviceSession.t.siteId,
      foreignField: _ie3onmsc.Site.t.id,
      tableRelation: tableRelation,
      createTable: (foreignTableRelation) =>
          _ie3onmsc.SiteTable(tableRelation: foreignTableRelation),
    );
    return _site!;
  }

  @override
  List<_is.Column> get columns => [
    id,
    siteId,
    serverSideSessionId,
    createdAt,
  ];

  @override
  _is.Table? getRelationTable(String relationField) {
    if (relationField == 'site') {
      return site;
    }
    return null;
  }
}

class SiteDeviceSessionInclude extends _is.IncludeObject {
  SiteDeviceSessionInclude._({_ie3onmsc.SiteInclude? site}) {
    _site = site;
  }

  _ie3onmsc.SiteInclude? _site;

  @override
  Map<String, _is.Include?> get includes => {'site': _site};

  @override
  _is.Table<int?> get table => SiteDeviceSession.t;
}

class SiteDeviceSessionIncludeList extends _is.IncludeList {
  SiteDeviceSessionIncludeList._({
    _is.WhereExpressionBuilder<SiteDeviceSessionTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(SiteDeviceSession.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => SiteDeviceSession.t;
}

class SiteDeviceSessionRepository {
  const SiteDeviceSessionRepository._();

  final attachRow = const SiteDeviceSessionAttachRowRepository._();

  /// Returns a list of [SiteDeviceSession]s matching the given query parameters.
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
  Future<List<SiteDeviceSession>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<SiteDeviceSessionTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<SiteDeviceSessionTable>? orderBy,
    _is.OrderByListBuilder<SiteDeviceSessionTable>? orderByList,
    _is.Transaction? transaction,
    SiteDeviceSessionInclude? include,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<SiteDeviceSession>(
      where: where?.call(SiteDeviceSession.t),
      orderBy: orderBy?.call(SiteDeviceSession.t),
      orderByList: orderByList?.call(SiteDeviceSession.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      include: include,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [SiteDeviceSession] matching the given query parameters.
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
  Future<SiteDeviceSession?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<SiteDeviceSessionTable>? where,
    int? offset,
    _is.OrderByBuilder<SiteDeviceSessionTable>? orderBy,
    _is.OrderByListBuilder<SiteDeviceSessionTable>? orderByList,
    _is.Transaction? transaction,
    SiteDeviceSessionInclude? include,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<SiteDeviceSession>(
      where: where?.call(SiteDeviceSession.t),
      orderBy: orderBy?.call(SiteDeviceSession.t),
      orderByList: orderByList?.call(SiteDeviceSession.t),
      offset: offset,
      transaction: transaction,
      include: include,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [SiteDeviceSession] by its [id] or null if no such row exists.
  Future<SiteDeviceSession?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    SiteDeviceSessionInclude? include,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<SiteDeviceSession>(
      id,
      transaction: transaction,
      include: include,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [SiteDeviceSession]s in the list and returns the inserted rows.
  ///
  /// The returned [SiteDeviceSession]s will have their `id` fields set.
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
  Future<List<SiteDeviceSession>> insert(
    _is.DatabaseSession session,
    List<SiteDeviceSession> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<SiteDeviceSession>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [SiteDeviceSession] and returns the inserted row.
  ///
  /// The returned [SiteDeviceSession] will have its `id` field set.
  Future<SiteDeviceSession> insertRow(
    _is.DatabaseSession session,
    SiteDeviceSession row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<SiteDeviceSession>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [SiteDeviceSession]s in the list and returns the resulting rows.
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
  /// The returned [SiteDeviceSession]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<SiteDeviceSession>> upsert(
    _is.DatabaseSession session,
    List<SiteDeviceSession> rows, {
    required _is.ColumnSelections<SiteDeviceSessionTable> conflictColumns,
    _is.ColumnSelections<SiteDeviceSessionTable>? updateColumns,
    _is.WhereExpressionBuilder<SiteDeviceSessionTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<SiteDeviceSession>(
      rows,
      conflictColumns: conflictColumns(SiteDeviceSession.t),
      updateColumns: updateColumns?.call(SiteDeviceSession.t),
      updateWhere: updateWhere?.call(SiteDeviceSession.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [SiteDeviceSession] and returns the resulting row.
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
  /// The returned [SiteDeviceSession] will have its `id` field set.
  Future<SiteDeviceSession?> upsertRow(
    _is.DatabaseSession session,
    SiteDeviceSession row, {
    required _is.ColumnSelections<SiteDeviceSessionTable> conflictColumns,
    _is.ColumnSelections<SiteDeviceSessionTable>? updateColumns,
    _is.WhereExpressionBuilder<SiteDeviceSessionTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<SiteDeviceSession>(
      row,
      conflictColumns: conflictColumns(SiteDeviceSession.t),
      updateColumns: updateColumns?.call(SiteDeviceSession.t),
      updateWhere: updateWhere?.call(SiteDeviceSession.t),
      transaction: transaction,
    );
  }

  /// Updates all [SiteDeviceSession]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<SiteDeviceSession>> update(
    _is.DatabaseSession session,
    List<SiteDeviceSession> rows, {
    _is.ColumnSelections<SiteDeviceSessionTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<SiteDeviceSession>(
      rows,
      columns: columns?.call(SiteDeviceSession.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [SiteDeviceSession]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<SiteDeviceSession> updateRow(
    _is.DatabaseSession session,
    SiteDeviceSession row, {
    _is.ColumnSelections<SiteDeviceSessionTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<SiteDeviceSession>(
      row,
      columns: columns?.call(SiteDeviceSession.t),
      transaction: transaction,
    );
  }

  /// Updates a single [SiteDeviceSession] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<SiteDeviceSession?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<SiteDeviceSessionUpdateTable>
    columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<SiteDeviceSession>(
      id,
      columnValues: columnValues(SiteDeviceSession.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [SiteDeviceSession]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<SiteDeviceSession>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<SiteDeviceSessionUpdateTable>
    columnValues,
    required _is.WhereExpressionBuilder<SiteDeviceSessionTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<SiteDeviceSessionTable>? orderBy,
    _is.OrderByListBuilder<SiteDeviceSessionTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<SiteDeviceSession>(
      columnValues: columnValues(SiteDeviceSession.t.updateTable),
      where: where(SiteDeviceSession.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(SiteDeviceSession.t),
      orderByList: orderByList?.call(SiteDeviceSession.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [SiteDeviceSession]s in the list and returns the deleted rows.
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
  Future<List<SiteDeviceSession>> delete(
    _is.DatabaseSession session,
    List<SiteDeviceSession> rows, {
    _is.OrderByBuilder<SiteDeviceSessionTable>? orderBy,
    _is.OrderByListBuilder<SiteDeviceSessionTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<SiteDeviceSession>(
      rows,
      orderBy: orderBy?.call(SiteDeviceSession.t),
      orderByList: orderByList?.call(SiteDeviceSession.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [SiteDeviceSession].
  Future<SiteDeviceSession> deleteRow(
    _is.DatabaseSession session,
    SiteDeviceSession row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<SiteDeviceSession>(
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
  Future<List<SiteDeviceSession>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<SiteDeviceSessionTable> where,
    _is.OrderByBuilder<SiteDeviceSessionTable>? orderBy,
    _is.OrderByListBuilder<SiteDeviceSessionTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<SiteDeviceSession>(
      where: where(SiteDeviceSession.t),
      orderBy: orderBy?.call(SiteDeviceSession.t),
      orderByList: orderByList?.call(SiteDeviceSession.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<SiteDeviceSessionTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<SiteDeviceSession>(
      where: where?.call(SiteDeviceSession.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [SiteDeviceSession] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<SiteDeviceSessionTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<SiteDeviceSession>(
      where: where(SiteDeviceSession.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}

class SiteDeviceSessionAttachRowRepository {
  const SiteDeviceSessionAttachRowRepository._();

  /// Creates a relation between the given [SiteDeviceSession] and [Site]
  /// by setting the [SiteDeviceSession]'s foreign key `siteId` to refer to the [Site].
  Future<void> site(
    _is.DatabaseSession session,
    SiteDeviceSession siteDeviceSession,
    _ie3onmsc.Site site, {
    _is.Transaction? transaction,
  }) async {
    if (siteDeviceSession.id == null) {
      throw ArgumentError.notNull('siteDeviceSession.id');
    }
    if (site.id == null) {
      throw ArgumentError.notNull('site.id');
    }

    var $siteDeviceSession = siteDeviceSession.copyWith(siteId: site.id);
    await session.db.updateRow<SiteDeviceSession>(
      $siteDeviceSession,
      columns: [SiteDeviceSession.t.siteId],
      transaction: transaction,
    );
  }
}
