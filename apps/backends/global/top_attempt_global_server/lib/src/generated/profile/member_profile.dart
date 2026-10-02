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

/// Person directory of the global instance — includes a duplicate of the
/// registration email plus the manually maintained profile data. The
/// built-in Serverpod UserProfile feature is deliberately bypassed; our
/// own `memberProfile` endpoints maintain this table. Profile images go
/// into RustFS at `member_images/<authUserId>.<ext>` (one object per
/// person, overwritten on change; uploads are JPEG-only for now).
/// Structural note: locally the same model exists with an OPTIONAL auth
/// link (plain members have no local login) plus a required
/// `globalAuthUserId` — this id is the same person id, so both systems
/// share image names and identity semantics.
abstract class MemberProfile
    implements _is.TableRow<int?>, _is.ProtocolSerialization {
  MemberProfile._({
    this.id,
    required this.authUserId,
    this.authUser,
    required this.email,
    this.firstName,
    this.lastName,
    this.birthday,
    this.imageUrl,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory MemberProfile({
    int? id,
    required _is.UuidValue authUserId,
    _iacs.AuthUser? authUser,
    required String email,
    String? firstName,
    String? lastName,
    DateTime? birthday,
    String? imageUrl,
    DateTime? createdAt,
  }) = _MemberProfileImpl;

  factory MemberProfile.fromJson(Map<String, dynamic> jsonSerialization) {
    return MemberProfile(
      id: jsonSerialization['id'] as int?,
      authUserId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['authUserId'],
      ),
      authUser: jsonSerialization['authUser'] == null
          ? null
          : _in02tfqf.Protocol().deserialize<_iacs.AuthUser>(
              jsonSerialization['authUser'],
            ),
      email: jsonSerialization['email'] as String,
      firstName: jsonSerialization['firstName'] as String?,
      lastName: jsonSerialization['lastName'] as String?,
      birthday: jsonSerialization['birthday'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['birthday']),
      imageUrl: jsonSerialization['imageUrl'] as String?,
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
    );
  }

  static final t = MemberProfileTable();

  static const db = MemberProfileRepository._();

  @override
  int? id;

  _is.UuidValue authUserId;

  /// The auth user this profile belongs to (required via unique index
  /// and code-level checks; model relations must be nullable).
  _iacs.AuthUser? authUser;

  /// Duplicate of the registration email (accepted; the only intended
  /// duplication versus the auth tables).
  String email;

  /// Profile data (completion after registration; names 1-60 chars,
  /// birthday as UTC-midnight date sentinel).
  String? firstName;

  String? lastName;

  DateTime? birthday;

  /// Public URL of the profile image (RustFS; null until set).
  String? imageUrl;

  /// When the profile row was created (sparse at registration via hook).
  DateTime createdAt;

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [MemberProfile]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  MemberProfile copyWith({
    int? id,
    _is.UuidValue? authUserId,
    _iacs.AuthUser? authUser,
    String? email,
    String? firstName,
    String? lastName,
    DateTime? birthday,
    String? imageUrl,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'MemberProfile',
      if (id != null) 'id': id,
      'authUserId': authUserId.toJson(),
      if (authUser != null) 'authUser': authUser?.toJson(),
      'email': email,
      if (firstName != null) 'firstName': firstName,
      if (lastName != null) 'lastName': lastName,
      if (birthday != null) 'birthday': birthday?.toJson(),
      if (imageUrl != null) 'imageUrl': imageUrl,
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'MemberProfile',
      if (id != null) 'id': id,
      'authUserId': authUserId.toJson(),
      if (authUser != null) 'authUser': authUser?.toJson(),
      'email': email,
      if (firstName != null) 'firstName': firstName,
      if (lastName != null) 'lastName': lastName,
      if (birthday != null) 'birthday': birthday?.toJson(),
      if (imageUrl != null) 'imageUrl': imageUrl,
      'createdAt': createdAt.toJson(),
    };
  }

  static MemberProfileInclude include({_iacs.AuthUserInclude? authUser}) {
    return MemberProfileInclude._(authUser: authUser);
  }

  static MemberProfileIncludeList includeList({
    _is.WhereExpressionBuilder<MemberProfileTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<MemberProfileTable>? orderBy,
    _is.OrderByListBuilder<MemberProfileTable>? orderByList,
    MemberProfileInclude? include,
  }) {
    return MemberProfileIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(MemberProfile.t),
      orderByList: orderByList?.call(MemberProfile.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _MemberProfileImpl extends MemberProfile {
  _MemberProfileImpl({
    int? id,
    required _is.UuidValue authUserId,
    _iacs.AuthUser? authUser,
    required String email,
    String? firstName,
    String? lastName,
    DateTime? birthday,
    String? imageUrl,
    DateTime? createdAt,
  }) : super._(
         id: id,
         authUserId: authUserId,
         authUser: authUser,
         email: email,
         firstName: firstName,
         lastName: lastName,
         birthday: birthday,
         imageUrl: imageUrl,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [MemberProfile]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  MemberProfile copyWith({
    Object? id = _Undefined,
    _is.UuidValue? authUserId,
    Object? authUser = _Undefined,
    String? email,
    Object? firstName = _Undefined,
    Object? lastName = _Undefined,
    Object? birthday = _Undefined,
    Object? imageUrl = _Undefined,
    DateTime? createdAt,
  }) {
    return MemberProfile(
      id: id is int? ? id : this.id,
      authUserId: authUserId ?? this.authUserId,
      authUser: authUser is _iacs.AuthUser?
          ? authUser
          : this.authUser?.copyWith(),
      email: email ?? this.email,
      firstName: firstName is String? ? firstName : this.firstName,
      lastName: lastName is String? ? lastName : this.lastName,
      birthday: birthday is DateTime? ? birthday : this.birthday,
      imageUrl: imageUrl is String? ? imageUrl : this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class MemberProfileUpdateTable extends _is.UpdateTable<MemberProfileTable> {
  MemberProfileUpdateTable(super.table);

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> authUserId(
    _is.UuidValue value,
  ) => _is.ColumnValue(
    table.authUserId,
    value,
  );

  _is.ColumnValue<String, String> email(String value) => _is.ColumnValue(
    table.email,
    value,
  );

  _is.ColumnValue<String, String> firstName(String? value) => _is.ColumnValue(
    table.firstName,
    value,
  );

  _is.ColumnValue<String, String> lastName(String? value) => _is.ColumnValue(
    table.lastName,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> birthday(DateTime? value) =>
      _is.ColumnValue(
        table.birthday,
        value,
      );

  _is.ColumnValue<String, String> imageUrl(String? value) => _is.ColumnValue(
    table.imageUrl,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> createdAt(DateTime value) =>
      _is.ColumnValue(
        table.createdAt,
        value,
      );
}

class MemberProfileTable extends _is.Table<int?> {
  MemberProfileTable({super.tableRelation})
    : super(tableName: 'member_profile') {
    updateTable = MemberProfileUpdateTable(this);
    authUserId = _is.ColumnUuid(
      'authUserId',
      this,
    );
    email = _is.ColumnString(
      'email',
      this,
    );
    firstName = _is.ColumnString(
      'firstName',
      this,
    );
    lastName = _is.ColumnString(
      'lastName',
      this,
    );
    birthday = _is.ColumnDateTime(
      'birthday',
      this,
    );
    imageUrl = _is.ColumnString(
      'imageUrl',
      this,
    );
    createdAt = _is.ColumnDateTime(
      'createdAt',
      this,
    );
  }

  late final MemberProfileUpdateTable updateTable;

  late final _is.ColumnUuid authUserId;

  /// The auth user this profile belongs to (required via unique index
  /// and code-level checks; model relations must be nullable).
  _iacs.AuthUserTable? _authUser;

  /// Duplicate of the registration email (accepted; the only intended
  /// duplication versus the auth tables).
  late final _is.ColumnString email;

  /// Profile data (completion after registration; names 1-60 chars,
  /// birthday as UTC-midnight date sentinel).
  late final _is.ColumnString firstName;

  late final _is.ColumnString lastName;

  late final _is.ColumnDateTime birthday;

  /// Public URL of the profile image (RustFS; null until set).
  late final _is.ColumnString imageUrl;

  /// When the profile row was created (sparse at registration via hook).
  late final _is.ColumnDateTime createdAt;

  _iacs.AuthUserTable get authUser {
    if (_authUser != null) return _authUser!;
    _authUser = _is.createRelationTable(
      relationFieldName: 'authUser',
      field: MemberProfile.t.authUserId,
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
    authUserId,
    email,
    firstName,
    lastName,
    birthday,
    imageUrl,
    createdAt,
  ];

  @override
  _is.Table? getRelationTable(String relationField) {
    if (relationField == 'authUser') {
      return authUser;
    }
    return null;
  }
}

class MemberProfileInclude extends _is.IncludeObject {
  MemberProfileInclude._({_iacs.AuthUserInclude? authUser}) {
    _authUser = authUser;
  }

  _iacs.AuthUserInclude? _authUser;

  @override
  Map<String, _is.Include?> get includes => {'authUser': _authUser};

  @override
  _is.Table<int?> get table => MemberProfile.t;
}

class MemberProfileIncludeList extends _is.IncludeList {
  MemberProfileIncludeList._({
    _is.WhereExpressionBuilder<MemberProfileTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(MemberProfile.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => MemberProfile.t;
}

class MemberProfileRepository {
  const MemberProfileRepository._();

  final attachRow = const MemberProfileAttachRowRepository._();

  /// Returns a list of [MemberProfile]s matching the given query parameters.
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
  Future<List<MemberProfile>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<MemberProfileTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<MemberProfileTable>? orderBy,
    _is.OrderByListBuilder<MemberProfileTable>? orderByList,
    _is.Transaction? transaction,
    MemberProfileInclude? include,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<MemberProfile>(
      where: where?.call(MemberProfile.t),
      orderBy: orderBy?.call(MemberProfile.t),
      orderByList: orderByList?.call(MemberProfile.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      include: include,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [MemberProfile] matching the given query parameters.
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
  Future<MemberProfile?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<MemberProfileTable>? where,
    int? offset,
    _is.OrderByBuilder<MemberProfileTable>? orderBy,
    _is.OrderByListBuilder<MemberProfileTable>? orderByList,
    _is.Transaction? transaction,
    MemberProfileInclude? include,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<MemberProfile>(
      where: where?.call(MemberProfile.t),
      orderBy: orderBy?.call(MemberProfile.t),
      orderByList: orderByList?.call(MemberProfile.t),
      offset: offset,
      transaction: transaction,
      include: include,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [MemberProfile] by its [id] or null if no such row exists.
  Future<MemberProfile?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    MemberProfileInclude? include,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<MemberProfile>(
      id,
      transaction: transaction,
      include: include,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [MemberProfile]s in the list and returns the inserted rows.
  ///
  /// The returned [MemberProfile]s will have their `id` fields set.
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
  Future<List<MemberProfile>> insert(
    _is.DatabaseSession session,
    List<MemberProfile> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<MemberProfile>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [MemberProfile] and returns the inserted row.
  ///
  /// The returned [MemberProfile] will have its `id` field set.
  Future<MemberProfile> insertRow(
    _is.DatabaseSession session,
    MemberProfile row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<MemberProfile>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [MemberProfile]s in the list and returns the resulting rows.
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
  /// The returned [MemberProfile]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<MemberProfile>> upsert(
    _is.DatabaseSession session,
    List<MemberProfile> rows, {
    required _is.ColumnSelections<MemberProfileTable> conflictColumns,
    _is.ColumnSelections<MemberProfileTable>? updateColumns,
    _is.WhereExpressionBuilder<MemberProfileTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<MemberProfile>(
      rows,
      conflictColumns: conflictColumns(MemberProfile.t),
      updateColumns: updateColumns?.call(MemberProfile.t),
      updateWhere: updateWhere?.call(MemberProfile.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [MemberProfile] and returns the resulting row.
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
  /// The returned [MemberProfile] will have its `id` field set.
  Future<MemberProfile?> upsertRow(
    _is.DatabaseSession session,
    MemberProfile row, {
    required _is.ColumnSelections<MemberProfileTable> conflictColumns,
    _is.ColumnSelections<MemberProfileTable>? updateColumns,
    _is.WhereExpressionBuilder<MemberProfileTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<MemberProfile>(
      row,
      conflictColumns: conflictColumns(MemberProfile.t),
      updateColumns: updateColumns?.call(MemberProfile.t),
      updateWhere: updateWhere?.call(MemberProfile.t),
      transaction: transaction,
    );
  }

  /// Updates all [MemberProfile]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<MemberProfile>> update(
    _is.DatabaseSession session,
    List<MemberProfile> rows, {
    _is.ColumnSelections<MemberProfileTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<MemberProfile>(
      rows,
      columns: columns?.call(MemberProfile.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [MemberProfile]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<MemberProfile> updateRow(
    _is.DatabaseSession session,
    MemberProfile row, {
    _is.ColumnSelections<MemberProfileTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<MemberProfile>(
      row,
      columns: columns?.call(MemberProfile.t),
      transaction: transaction,
    );
  }

  /// Updates a single [MemberProfile] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<MemberProfile?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<MemberProfileUpdateTable> columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<MemberProfile>(
      id,
      columnValues: columnValues(MemberProfile.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [MemberProfile]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<MemberProfile>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<MemberProfileUpdateTable> columnValues,
    required _is.WhereExpressionBuilder<MemberProfileTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<MemberProfileTable>? orderBy,
    _is.OrderByListBuilder<MemberProfileTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<MemberProfile>(
      columnValues: columnValues(MemberProfile.t.updateTable),
      where: where(MemberProfile.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(MemberProfile.t),
      orderByList: orderByList?.call(MemberProfile.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [MemberProfile]s in the list and returns the deleted rows.
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
  Future<List<MemberProfile>> delete(
    _is.DatabaseSession session,
    List<MemberProfile> rows, {
    _is.OrderByBuilder<MemberProfileTable>? orderBy,
    _is.OrderByListBuilder<MemberProfileTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<MemberProfile>(
      rows,
      orderBy: orderBy?.call(MemberProfile.t),
      orderByList: orderByList?.call(MemberProfile.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [MemberProfile].
  Future<MemberProfile> deleteRow(
    _is.DatabaseSession session,
    MemberProfile row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<MemberProfile>(
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
  Future<List<MemberProfile>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<MemberProfileTable> where,
    _is.OrderByBuilder<MemberProfileTable>? orderBy,
    _is.OrderByListBuilder<MemberProfileTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<MemberProfile>(
      where: where(MemberProfile.t),
      orderBy: orderBy?.call(MemberProfile.t),
      orderByList: orderByList?.call(MemberProfile.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<MemberProfileTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<MemberProfile>(
      where: where?.call(MemberProfile.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [MemberProfile] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<MemberProfileTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<MemberProfile>(
      where: where(MemberProfile.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}

class MemberProfileAttachRowRepository {
  const MemberProfileAttachRowRepository._();

  /// Creates a relation between the given [MemberProfile] and [AuthUser]
  /// by setting the [MemberProfile]'s foreign key `authUserId` to refer to the [AuthUser].
  Future<void> authUser(
    _is.DatabaseSession session,
    MemberProfile memberProfile,
    _iacs.AuthUser authUser, {
    _is.Transaction? transaction,
  }) async {
    if (memberProfile.id == null) {
      throw ArgumentError.notNull('memberProfile.id');
    }
    if (authUser.id == null) {
      throw ArgumentError.notNull('authUser.id');
    }

    var $memberProfile = memberProfile.copyWith(authUserId: authUser.id);
    await session.db.updateRow<MemberProfile>(
      $memberProfile,
      columns: [MemberProfile.t.authUserId],
      transaction: transaction,
    );
  }
}
