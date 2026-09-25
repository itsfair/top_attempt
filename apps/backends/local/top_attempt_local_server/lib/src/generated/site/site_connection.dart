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

/// Enrollment state of this local instance at its site's global instance.
/// Single-row configuration table (the worker reads it on every startup).
abstract class SiteConnection
    implements _is.TableRow<int?>, _is.ProtocolSerialization {
  SiteConnection._({
    this.id,
    required this.globalApiUrl,
    required this.siteId,
    required this.siteName,
    this.adminEmail,
    this.adminFullName,
    this.adminAuthUserId,
    this.deviceSessionKey,
    DateTime? enrolledAt,
  }) : enrolledAt = enrolledAt ?? DateTime.now();

  factory SiteConnection({
    int? id,
    required String globalApiUrl,
    required int siteId,
    required String siteName,
    String? adminEmail,
    String? adminFullName,
    _is.UuidValue? adminAuthUserId,
    String? deviceSessionKey,
    DateTime? enrolledAt,
  }) = _SiteConnectionImpl;

  factory SiteConnection.fromJson(Map<String, dynamic> jsonSerialization) {
    return SiteConnection(
      id: jsonSerialization['id'] as int?,
      globalApiUrl: jsonSerialization['globalApiUrl'] as String,
      siteId: jsonSerialization['siteId'] as int,
      siteName: jsonSerialization['siteName'] as String,
      adminEmail: jsonSerialization['adminEmail'] as String?,
      adminFullName: jsonSerialization['adminFullName'] as String?,
      adminAuthUserId: jsonSerialization['adminAuthUserId'] == null
          ? null
          : _is.UuidValueJsonExtension.fromJson(
              jsonSerialization['adminAuthUserId'],
            ),
      deviceSessionKey: jsonSerialization['deviceSessionKey'] as String?,
      enrolledAt: jsonSerialization['enrolledAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['enrolledAt']),
    );
  }

  static final t = SiteConnectionTable();

  static const db = SiteConnectionRepository._();

  @override
  int? id;

  /// The API URL of the global backend this instance is bound to
  /// (e.g. `http://192.168.x.x:8080` in dev, real URL in production).
  String globalApiUrl;

  /// The site we are enrolled at.
  int siteId;

  String siteName;

  /// Admin identity handed over at enrollment (the site admin acts as the
  /// connection owner; `member.globalAuthUserId` for this admin uses the
  /// same id).
  String? adminEmail;

  String? adminFullName;

  _is.UuidValue? adminAuthUserId;

  /// The device credential: non-rotating SAS session key issued by the
  /// global backend at enrollment (`AuthStrategy.session`). Write-once;
  /// storage needs no rotation handling. Encrypt at rest is a To-do.
  String? deviceSessionKey;

  /// When the enrollment happened (may be a recovery).
  DateTime enrolledAt;

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [SiteConnection]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  SiteConnection copyWith({
    int? id,
    String? globalApiUrl,
    int? siteId,
    String? siteName,
    String? adminEmail,
    String? adminFullName,
    _is.UuidValue? adminAuthUserId,
    String? deviceSessionKey,
    DateTime? enrolledAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'SiteConnection',
      if (id != null) 'id': id,
      'globalApiUrl': globalApiUrl,
      'siteId': siteId,
      'siteName': siteName,
      if (adminEmail != null) 'adminEmail': adminEmail,
      if (adminFullName != null) 'adminFullName': adminFullName,
      if (adminAuthUserId != null) 'adminAuthUserId': adminAuthUserId?.toJson(),
      if (deviceSessionKey != null) 'deviceSessionKey': deviceSessionKey,
      'enrolledAt': enrolledAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'SiteConnection',
      if (id != null) 'id': id,
      'globalApiUrl': globalApiUrl,
      'siteId': siteId,
      'siteName': siteName,
      if (adminEmail != null) 'adminEmail': adminEmail,
      if (adminFullName != null) 'adminFullName': adminFullName,
      'enrolledAt': enrolledAt.toJson(),
    };
  }

  static SiteConnectionInclude include() {
    return SiteConnectionInclude._();
  }

  static SiteConnectionIncludeList includeList({
    _is.WhereExpressionBuilder<SiteConnectionTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<SiteConnectionTable>? orderBy,
    _is.OrderByListBuilder<SiteConnectionTable>? orderByList,
    SiteConnectionInclude? include,
  }) {
    return SiteConnectionIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(SiteConnection.t),
      orderByList: orderByList?.call(SiteConnection.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _SiteConnectionImpl extends SiteConnection {
  _SiteConnectionImpl({
    int? id,
    required String globalApiUrl,
    required int siteId,
    required String siteName,
    String? adminEmail,
    String? adminFullName,
    _is.UuidValue? adminAuthUserId,
    String? deviceSessionKey,
    DateTime? enrolledAt,
  }) : super._(
         id: id,
         globalApiUrl: globalApiUrl,
         siteId: siteId,
         siteName: siteName,
         adminEmail: adminEmail,
         adminFullName: adminFullName,
         adminAuthUserId: adminAuthUserId,
         deviceSessionKey: deviceSessionKey,
         enrolledAt: enrolledAt,
       );

  /// Returns a shallow copy of this [SiteConnection]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  SiteConnection copyWith({
    Object? id = _Undefined,
    String? globalApiUrl,
    int? siteId,
    String? siteName,
    Object? adminEmail = _Undefined,
    Object? adminFullName = _Undefined,
    Object? adminAuthUserId = _Undefined,
    Object? deviceSessionKey = _Undefined,
    DateTime? enrolledAt,
  }) {
    return SiteConnection(
      id: id is int? ? id : this.id,
      globalApiUrl: globalApiUrl ?? this.globalApiUrl,
      siteId: siteId ?? this.siteId,
      siteName: siteName ?? this.siteName,
      adminEmail: adminEmail is String? ? adminEmail : this.adminEmail,
      adminFullName: adminFullName is String?
          ? adminFullName
          : this.adminFullName,
      adminAuthUserId: adminAuthUserId is _is.UuidValue?
          ? adminAuthUserId
          : this.adminAuthUserId,
      deviceSessionKey: deviceSessionKey is String?
          ? deviceSessionKey
          : this.deviceSessionKey,
      enrolledAt: enrolledAt ?? this.enrolledAt,
    );
  }
}

class SiteConnectionUpdateTable extends _is.UpdateTable<SiteConnectionTable> {
  SiteConnectionUpdateTable(super.table);

  _is.ColumnValue<String, String> globalApiUrl(String value) => _is.ColumnValue(
    table.globalApiUrl,
    value,
  );

  _is.ColumnValue<int, int> siteId(int value) => _is.ColumnValue(
    table.siteId,
    value,
  );

  _is.ColumnValue<String, String> siteName(String value) => _is.ColumnValue(
    table.siteName,
    value,
  );

  _is.ColumnValue<String, String> adminEmail(String? value) => _is.ColumnValue(
    table.adminEmail,
    value,
  );

  _is.ColumnValue<String, String> adminFullName(String? value) =>
      _is.ColumnValue(
        table.adminFullName,
        value,
      );

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> adminAuthUserId(
    _is.UuidValue? value,
  ) => _is.ColumnValue(
    table.adminAuthUserId,
    value,
  );

  _is.ColumnValue<String, String> deviceSessionKey(String? value) =>
      _is.ColumnValue(
        table.deviceSessionKey,
        value,
      );

  _is.ColumnValue<DateTime, DateTime> enrolledAt(DateTime value) =>
      _is.ColumnValue(
        table.enrolledAt,
        value,
      );
}

class SiteConnectionTable extends _is.Table<int?> {
  SiteConnectionTable({super.tableRelation})
    : super(tableName: 'site_connections') {
    updateTable = SiteConnectionUpdateTable(this);
    globalApiUrl = _is.ColumnString(
      'globalApiUrl',
      this,
    );
    siteId = _is.ColumnInt(
      'siteId',
      this,
    );
    siteName = _is.ColumnString(
      'siteName',
      this,
    );
    adminEmail = _is.ColumnString(
      'adminEmail',
      this,
    );
    adminFullName = _is.ColumnString(
      'adminFullName',
      this,
    );
    adminAuthUserId = _is.ColumnUuid(
      'adminAuthUserId',
      this,
    );
    deviceSessionKey = _is.ColumnString(
      'deviceSessionKey',
      this,
    );
    enrolledAt = _is.ColumnDateTime(
      'enrolledAt',
      this,
    );
  }

  late final SiteConnectionUpdateTable updateTable;

  /// The API URL of the global backend this instance is bound to
  /// (e.g. `http://192.168.x.x:8080` in dev, real URL in production).
  late final _is.ColumnString globalApiUrl;

  /// The site we are enrolled at.
  late final _is.ColumnInt siteId;

  late final _is.ColumnString siteName;

  /// Admin identity handed over at enrollment (the site admin acts as the
  /// connection owner; `member.globalAuthUserId` for this admin uses the
  /// same id).
  late final _is.ColumnString adminEmail;

  late final _is.ColumnString adminFullName;

  late final _is.ColumnUuid adminAuthUserId;

  /// The device credential: non-rotating SAS session key issued by the
  /// global backend at enrollment (`AuthStrategy.session`). Write-once;
  /// storage needs no rotation handling. Encrypt at rest is a To-do.
  late final _is.ColumnString deviceSessionKey;

  /// When the enrollment happened (may be a recovery).
  late final _is.ColumnDateTime enrolledAt;

  @override
  List<_is.Column> get columns => [
    id,
    globalApiUrl,
    siteId,
    siteName,
    adminEmail,
    adminFullName,
    adminAuthUserId,
    deviceSessionKey,
    enrolledAt,
  ];
}

class SiteConnectionInclude extends _is.IncludeObject {
  SiteConnectionInclude._();

  @override
  Map<String, _is.Include?> get includes => {};

  @override
  _is.Table<int?> get table => SiteConnection.t;
}

class SiteConnectionIncludeList extends _is.IncludeList {
  SiteConnectionIncludeList._({
    _is.WhereExpressionBuilder<SiteConnectionTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(SiteConnection.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => SiteConnection.t;
}

class SiteConnectionRepository {
  const SiteConnectionRepository._();

  /// Returns a list of [SiteConnection]s matching the given query parameters.
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
  Future<List<SiteConnection>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<SiteConnectionTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<SiteConnectionTable>? orderBy,
    _is.OrderByListBuilder<SiteConnectionTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<SiteConnection>(
      where: where?.call(SiteConnection.t),
      orderBy: orderBy?.call(SiteConnection.t),
      orderByList: orderByList?.call(SiteConnection.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [SiteConnection] matching the given query parameters.
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
  Future<SiteConnection?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<SiteConnectionTable>? where,
    int? offset,
    _is.OrderByBuilder<SiteConnectionTable>? orderBy,
    _is.OrderByListBuilder<SiteConnectionTable>? orderByList,
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<SiteConnection>(
      where: where?.call(SiteConnection.t),
      orderBy: orderBy?.call(SiteConnection.t),
      orderByList: orderByList?.call(SiteConnection.t),
      offset: offset,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [SiteConnection] by its [id] or null if no such row exists.
  Future<SiteConnection?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<SiteConnection>(
      id,
      transaction: transaction,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [SiteConnection]s in the list and returns the inserted rows.
  ///
  /// The returned [SiteConnection]s will have their `id` fields set.
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
  Future<List<SiteConnection>> insert(
    _is.DatabaseSession session,
    List<SiteConnection> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<SiteConnection>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [SiteConnection] and returns the inserted row.
  ///
  /// The returned [SiteConnection] will have its `id` field set.
  Future<SiteConnection> insertRow(
    _is.DatabaseSession session,
    SiteConnection row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<SiteConnection>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [SiteConnection]s in the list and returns the resulting rows.
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
  /// The returned [SiteConnection]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<SiteConnection>> upsert(
    _is.DatabaseSession session,
    List<SiteConnection> rows, {
    required _is.ColumnSelections<SiteConnectionTable> conflictColumns,
    _is.ColumnSelections<SiteConnectionTable>? updateColumns,
    _is.WhereExpressionBuilder<SiteConnectionTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<SiteConnection>(
      rows,
      conflictColumns: conflictColumns(SiteConnection.t),
      updateColumns: updateColumns?.call(SiteConnection.t),
      updateWhere: updateWhere?.call(SiteConnection.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [SiteConnection] and returns the resulting row.
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
  /// The returned [SiteConnection] will have its `id` field set.
  Future<SiteConnection?> upsertRow(
    _is.DatabaseSession session,
    SiteConnection row, {
    required _is.ColumnSelections<SiteConnectionTable> conflictColumns,
    _is.ColumnSelections<SiteConnectionTable>? updateColumns,
    _is.WhereExpressionBuilder<SiteConnectionTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<SiteConnection>(
      row,
      conflictColumns: conflictColumns(SiteConnection.t),
      updateColumns: updateColumns?.call(SiteConnection.t),
      updateWhere: updateWhere?.call(SiteConnection.t),
      transaction: transaction,
    );
  }

  /// Updates all [SiteConnection]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<SiteConnection>> update(
    _is.DatabaseSession session,
    List<SiteConnection> rows, {
    _is.ColumnSelections<SiteConnectionTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<SiteConnection>(
      rows,
      columns: columns?.call(SiteConnection.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [SiteConnection]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<SiteConnection> updateRow(
    _is.DatabaseSession session,
    SiteConnection row, {
    _is.ColumnSelections<SiteConnectionTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<SiteConnection>(
      row,
      columns: columns?.call(SiteConnection.t),
      transaction: transaction,
    );
  }

  /// Updates a single [SiteConnection] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<SiteConnection?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<SiteConnectionUpdateTable> columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<SiteConnection>(
      id,
      columnValues: columnValues(SiteConnection.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [SiteConnection]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<SiteConnection>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<SiteConnectionUpdateTable> columnValues,
    required _is.WhereExpressionBuilder<SiteConnectionTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<SiteConnectionTable>? orderBy,
    _is.OrderByListBuilder<SiteConnectionTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<SiteConnection>(
      columnValues: columnValues(SiteConnection.t.updateTable),
      where: where(SiteConnection.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(SiteConnection.t),
      orderByList: orderByList?.call(SiteConnection.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [SiteConnection]s in the list and returns the deleted rows.
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
  Future<List<SiteConnection>> delete(
    _is.DatabaseSession session,
    List<SiteConnection> rows, {
    _is.OrderByBuilder<SiteConnectionTable>? orderBy,
    _is.OrderByListBuilder<SiteConnectionTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<SiteConnection>(
      rows,
      orderBy: orderBy?.call(SiteConnection.t),
      orderByList: orderByList?.call(SiteConnection.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [SiteConnection].
  Future<SiteConnection> deleteRow(
    _is.DatabaseSession session,
    SiteConnection row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<SiteConnection>(
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
  Future<List<SiteConnection>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<SiteConnectionTable> where,
    _is.OrderByBuilder<SiteConnectionTable>? orderBy,
    _is.OrderByListBuilder<SiteConnectionTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<SiteConnection>(
      where: where(SiteConnection.t),
      orderBy: orderBy?.call(SiteConnection.t),
      orderByList: orderByList?.call(SiteConnection.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<SiteConnectionTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<SiteConnection>(
      where: where?.call(SiteConnection.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [SiteConnection] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<SiteConnectionTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<SiteConnection>(
      where: where(SiteConnection.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}
