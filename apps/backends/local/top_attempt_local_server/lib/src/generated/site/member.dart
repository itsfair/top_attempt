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
/// here — either as plain member (no local login) or with a linked local
/// AuthUser (site admin / staff with login). One row per global person.
abstract class Member implements _is.TableRow<int?>, _is.ProtocolSerialization {
  Member._({
    this.id,
    required this.globalAuthUserId,
    required this.localAuthUserId,
    this.localAuthUser,
    this.email,
    this.fullName,
    String? role,
    bool? active,
    DateTime? createdAt,
  }) : role = role ?? 'member',
       active = active ?? true,
       createdAt = createdAt ?? DateTime.now();

  factory Member({
    int? id,
    required _is.UuidValue globalAuthUserId,
    required _is.UuidValue localAuthUserId,
    _iacs.AuthUser? localAuthUser,
    String? email,
    String? fullName,
    String? role,
    bool? active,
    DateTime? createdAt,
  }) = _MemberImpl;

  factory Member.fromJson(Map<String, dynamic> jsonSerialization) {
    return Member(
      id: jsonSerialization['id'] as int?,
      globalAuthUserId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['globalAuthUserId'],
      ),
      localAuthUserId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['localAuthUserId'],
      ),
      localAuthUser: jsonSerialization['localAuthUser'] == null
          ? null
          : _ianhe7y2.Protocol().deserialize<_iacs.AuthUser>(
              jsonSerialization['localAuthUser'],
            ),
      email: jsonSerialization['email'] as String?,
      fullName: jsonSerialization['fullName'] as String?,
      role: jsonSerialization['role'] as String?,
      active: jsonSerialization['active'] == null
          ? null
          : _is.BoolJsonExtension.fromJson(jsonSerialization['active']),
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
    );
  }

  static final t = MemberTable();

  static const db = MemberRepository._();

  @override
  int? id;

  /// The GLOBAL authUserId of the person — the exchange key with the
  /// global instance (and later used by the door-opening flow: ESP32 ->
  /// local backend -> member lookup). This is NOT the local AuthUser id.
  _is.UuidValue globalAuthUserId;

  _is.UuidValue localAuthUserId;

  /// Link to the local login account (site admin / staff); null for plain
  /// members without login. The local AuthUser uuid is local-only and must
  /// never be used for cross-instance matching.
  _iacs.AuthUser? localAuthUser;

  /// Mirrored profile data from the global instance.
  String? email;

  String? fullName;

  /// Role as string, mirrored from the global `SiteRole` (member/staff/
  /// siteAdmin) — synced; the local backend derives privileges from it.
  String role;

  /// Mirrored active state of the global membership.
  bool active;

  /// When the local row was created (at enrollment for the site admin or
  /// when a membership sync event arrived).
  DateTime createdAt;

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [Member]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  Member copyWith({
    int? id,
    _is.UuidValue? globalAuthUserId,
    _is.UuidValue? localAuthUserId,
    _iacs.AuthUser? localAuthUser,
    String? email,
    String? fullName,
    String? role,
    bool? active,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'Member',
      if (id != null) 'id': id,
      'globalAuthUserId': globalAuthUserId.toJson(),
      'localAuthUserId': localAuthUserId.toJson(),
      if (localAuthUser != null) 'localAuthUser': localAuthUser?.toJson(),
      if (email != null) 'email': email,
      if (fullName != null) 'fullName': fullName,
      'role': role,
      'active': active,
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'Member',
      if (id != null) 'id': id,
      'globalAuthUserId': globalAuthUserId.toJson(),
      'localAuthUserId': localAuthUserId.toJson(),
      if (localAuthUser != null) 'localAuthUser': localAuthUser?.toJson(),
      if (email != null) 'email': email,
      if (fullName != null) 'fullName': fullName,
      'role': role,
      'active': active,
      'createdAt': createdAt.toJson(),
    };
  }

  static MemberInclude include({_iacs.AuthUserInclude? localAuthUser}) {
    return MemberInclude._(localAuthUser: localAuthUser);
  }

  static MemberIncludeList includeList({
    _is.WhereExpressionBuilder<MemberTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<MemberTable>? orderBy,
    _is.OrderByListBuilder<MemberTable>? orderByList,
    MemberInclude? include,
  }) {
    return MemberIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(Member.t),
      orderByList: orderByList?.call(Member.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _MemberImpl extends Member {
  _MemberImpl({
    int? id,
    required _is.UuidValue globalAuthUserId,
    required _is.UuidValue localAuthUserId,
    _iacs.AuthUser? localAuthUser,
    String? email,
    String? fullName,
    String? role,
    bool? active,
    DateTime? createdAt,
  }) : super._(
         id: id,
         globalAuthUserId: globalAuthUserId,
         localAuthUserId: localAuthUserId,
         localAuthUser: localAuthUser,
         email: email,
         fullName: fullName,
         role: role,
         active: active,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [Member]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  Member copyWith({
    Object? id = _Undefined,
    _is.UuidValue? globalAuthUserId,
    _is.UuidValue? localAuthUserId,
    Object? localAuthUser = _Undefined,
    Object? email = _Undefined,
    Object? fullName = _Undefined,
    String? role,
    bool? active,
    DateTime? createdAt,
  }) {
    return Member(
      id: id is int? ? id : this.id,
      globalAuthUserId: globalAuthUserId ?? this.globalAuthUserId,
      localAuthUserId: localAuthUserId ?? this.localAuthUserId,
      localAuthUser: localAuthUser is _iacs.AuthUser?
          ? localAuthUser
          : this.localAuthUser?.copyWith(),
      email: email is String? ? email : this.email,
      fullName: fullName is String? ? fullName : this.fullName,
      role: role ?? this.role,
      active: active ?? this.active,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class MemberUpdateTable extends _is.UpdateTable<MemberTable> {
  MemberUpdateTable(super.table);

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> globalAuthUserId(
    _is.UuidValue value,
  ) => _is.ColumnValue(
    table.globalAuthUserId,
    value,
  );

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> localAuthUserId(
    _is.UuidValue value,
  ) => _is.ColumnValue(
    table.localAuthUserId,
    value,
  );

  _is.ColumnValue<String, String> email(String? value) => _is.ColumnValue(
    table.email,
    value,
  );

  _is.ColumnValue<String, String> fullName(String? value) => _is.ColumnValue(
    table.fullName,
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

class MemberTable extends _is.Table<int?> {
  MemberTable({super.tableRelation}) : super(tableName: 'members') {
    updateTable = MemberUpdateTable(this);
    globalAuthUserId = _is.ColumnUuid(
      'globalAuthUserId',
      this,
    );
    localAuthUserId = _is.ColumnUuid(
      'localAuthUserId',
      this,
    );
    email = _is.ColumnString(
      'email',
      this,
    );
    fullName = _is.ColumnString(
      'fullName',
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

  late final MemberUpdateTable updateTable;

  /// The GLOBAL authUserId of the person — the exchange key with the
  /// global instance (and later used by the door-opening flow: ESP32 ->
  /// local backend -> member lookup). This is NOT the local AuthUser id.
  late final _is.ColumnUuid globalAuthUserId;

  late final _is.ColumnUuid localAuthUserId;

  /// Link to the local login account (site admin / staff); null for plain
  /// members without login. The local AuthUser uuid is local-only and must
  /// never be used for cross-instance matching.
  _iacs.AuthUserTable? _localAuthUser;

  /// Mirrored profile data from the global instance.
  late final _is.ColumnString email;

  late final _is.ColumnString fullName;

  /// Role as string, mirrored from the global `SiteRole` (member/staff/
  /// siteAdmin) — synced; the local backend derives privileges from it.
  late final _is.ColumnString role;

  /// Mirrored active state of the global membership.
  late final _is.ColumnBool active;

  /// When the local row was created (at enrollment for the site admin or
  /// when a membership sync event arrived).
  late final _is.ColumnDateTime createdAt;

  _iacs.AuthUserTable get localAuthUser {
    if (_localAuthUser != null) return _localAuthUser!;
    _localAuthUser = _is.createRelationTable(
      relationFieldName: 'localAuthUser',
      field: Member.t.localAuthUserId,
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
    email,
    fullName,
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

class MemberInclude extends _is.IncludeObject {
  MemberInclude._({_iacs.AuthUserInclude? localAuthUser}) {
    _localAuthUser = localAuthUser;
  }

  _iacs.AuthUserInclude? _localAuthUser;

  @override
  Map<String, _is.Include?> get includes => {'localAuthUser': _localAuthUser};

  @override
  _is.Table<int?> get table => Member.t;
}

class MemberIncludeList extends _is.IncludeList {
  MemberIncludeList._({
    _is.WhereExpressionBuilder<MemberTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(Member.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => Member.t;
}

class MemberRepository {
  const MemberRepository._();

  final attachRow = const MemberAttachRowRepository._();

  /// Returns a list of [Member]s matching the given query parameters.
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
  Future<List<Member>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<MemberTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<MemberTable>? orderBy,
    _is.OrderByListBuilder<MemberTable>? orderByList,
    _is.Transaction? transaction,
    MemberInclude? include,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<Member>(
      where: where?.call(Member.t),
      orderBy: orderBy?.call(Member.t),
      orderByList: orderByList?.call(Member.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      include: include,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [Member] matching the given query parameters.
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
  Future<Member?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<MemberTable>? where,
    int? offset,
    _is.OrderByBuilder<MemberTable>? orderBy,
    _is.OrderByListBuilder<MemberTable>? orderByList,
    _is.Transaction? transaction,
    MemberInclude? include,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<Member>(
      where: where?.call(Member.t),
      orderBy: orderBy?.call(Member.t),
      orderByList: orderByList?.call(Member.t),
      offset: offset,
      transaction: transaction,
      include: include,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [Member] by its [id] or null if no such row exists.
  Future<Member?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    MemberInclude? include,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<Member>(
      id,
      transaction: transaction,
      include: include,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [Member]s in the list and returns the inserted rows.
  ///
  /// The returned [Member]s will have their `id` fields set.
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
  Future<List<Member>> insert(
    _is.DatabaseSession session,
    List<Member> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<Member>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [Member] and returns the inserted row.
  ///
  /// The returned [Member] will have its `id` field set.
  Future<Member> insertRow(
    _is.DatabaseSession session,
    Member row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<Member>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [Member]s in the list and returns the resulting rows.
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
  /// The returned [Member]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<Member>> upsert(
    _is.DatabaseSession session,
    List<Member> rows, {
    required _is.ColumnSelections<MemberTable> conflictColumns,
    _is.ColumnSelections<MemberTable>? updateColumns,
    _is.WhereExpressionBuilder<MemberTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<Member>(
      rows,
      conflictColumns: conflictColumns(Member.t),
      updateColumns: updateColumns?.call(Member.t),
      updateWhere: updateWhere?.call(Member.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [Member] and returns the resulting row.
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
  /// The returned [Member] will have its `id` field set.
  Future<Member?> upsertRow(
    _is.DatabaseSession session,
    Member row, {
    required _is.ColumnSelections<MemberTable> conflictColumns,
    _is.ColumnSelections<MemberTable>? updateColumns,
    _is.WhereExpressionBuilder<MemberTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<Member>(
      row,
      conflictColumns: conflictColumns(Member.t),
      updateColumns: updateColumns?.call(Member.t),
      updateWhere: updateWhere?.call(Member.t),
      transaction: transaction,
    );
  }

  /// Updates all [Member]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<Member>> update(
    _is.DatabaseSession session,
    List<Member> rows, {
    _is.ColumnSelections<MemberTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<Member>(
      rows,
      columns: columns?.call(Member.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [Member]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<Member> updateRow(
    _is.DatabaseSession session,
    Member row, {
    _is.ColumnSelections<MemberTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<Member>(
      row,
      columns: columns?.call(Member.t),
      transaction: transaction,
    );
  }

  /// Updates a single [Member] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<Member?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<MemberUpdateTable> columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<Member>(
      id,
      columnValues: columnValues(Member.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [Member]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<Member>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<MemberUpdateTable> columnValues,
    required _is.WhereExpressionBuilder<MemberTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<MemberTable>? orderBy,
    _is.OrderByListBuilder<MemberTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<Member>(
      columnValues: columnValues(Member.t.updateTable),
      where: where(Member.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(Member.t),
      orderByList: orderByList?.call(Member.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [Member]s in the list and returns the deleted rows.
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
  Future<List<Member>> delete(
    _is.DatabaseSession session,
    List<Member> rows, {
    _is.OrderByBuilder<MemberTable>? orderBy,
    _is.OrderByListBuilder<MemberTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<Member>(
      rows,
      orderBy: orderBy?.call(Member.t),
      orderByList: orderByList?.call(Member.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [Member].
  Future<Member> deleteRow(
    _is.DatabaseSession session,
    Member row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<Member>(
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
  Future<List<Member>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<MemberTable> where,
    _is.OrderByBuilder<MemberTable>? orderBy,
    _is.OrderByListBuilder<MemberTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<Member>(
      where: where(Member.t),
      orderBy: orderBy?.call(Member.t),
      orderByList: orderByList?.call(Member.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<MemberTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<Member>(
      where: where?.call(Member.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [Member] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<MemberTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<Member>(
      where: where(Member.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}

class MemberAttachRowRepository {
  const MemberAttachRowRepository._();

  /// Creates a relation between the given [Member] and [AuthUser]
  /// by setting the [Member]'s foreign key `localAuthUserId` to refer to the [AuthUser].
  Future<void> localAuthUser(
    _is.DatabaseSession session,
    Member member,
    _iacs.AuthUser localAuthUser, {
    _is.Transaction? transaction,
  }) async {
    if (member.id == null) {
      throw ArgumentError.notNull('member.id');
    }
    if (localAuthUser.id == null) {
      throw ArgumentError.notNull('localAuthUser.id');
    }

    var $member = member.copyWith(localAuthUserId: localAuthUser.id);
    await session.db.updateRow<Member>(
      $member,
      columns: [Member.t.localAuthUserId],
      transaction: transaction,
    );
  }
}
