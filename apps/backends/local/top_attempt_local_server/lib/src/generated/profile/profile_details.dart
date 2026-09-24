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

abstract class ProfileDetails
    implements _is.TableRow<int?>, _is.ProtocolSerialization {
  ProfileDetails._({
    this.id,
    required this.authUserId,
    this.authUser,
    this.firstName,
    this.lastName,
    this.birthday,
  });

  factory ProfileDetails({
    int? id,
    required _is.UuidValue authUserId,
    _iacs.AuthUser? authUser,
    String? firstName,
    String? lastName,
    DateTime? birthday,
  }) = _ProfileDetailsImpl;

  factory ProfileDetails.fromJson(Map<String, dynamic> jsonSerialization) {
    return ProfileDetails(
      id: jsonSerialization['id'] as int?,
      authUserId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['authUserId'],
      ),
      authUser: jsonSerialization['authUser'] == null
          ? null
          : _ianhe7y2.Protocol().deserialize<_iacs.AuthUser>(
              jsonSerialization['authUser'],
            ),
      firstName: jsonSerialization['firstName'] as String?,
      lastName: jsonSerialization['lastName'] as String?,
      birthday: jsonSerialization['birthday'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['birthday']),
    );
  }

  static final t = ProfileDetailsTable();

  static const db = ProfileDetailsRepository._();

  @override
  int? id;

  _is.UuidValue authUserId;

  /// The AuthUser this data belongs to.
  _iacs.AuthUser? authUser;

  String? firstName;

  String? lastName;

  DateTime? birthday;

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [ProfileDetails]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  ProfileDetails copyWith({
    int? id,
    _is.UuidValue? authUserId,
    _iacs.AuthUser? authUser,
    String? firstName,
    String? lastName,
    DateTime? birthday,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'ProfileDetails',
      if (id != null) 'id': id,
      'authUserId': authUserId.toJson(),
      if (authUser != null) 'authUser': authUser?.toJson(),
      if (firstName != null) 'firstName': firstName,
      if (lastName != null) 'lastName': lastName,
      if (birthday != null) 'birthday': birthday?.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'ProfileDetails',
      if (id != null) 'id': id,
      'authUserId': authUserId.toJson(),
      if (authUser != null) 'authUser': authUser?.toJson(),
      if (firstName != null) 'firstName': firstName,
      if (lastName != null) 'lastName': lastName,
      if (birthday != null) 'birthday': birthday?.toJson(),
    };
  }

  static ProfileDetailsInclude include({_iacs.AuthUserInclude? authUser}) {
    return ProfileDetailsInclude._(authUser: authUser);
  }

  static ProfileDetailsIncludeList includeList({
    _is.WhereExpressionBuilder<ProfileDetailsTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<ProfileDetailsTable>? orderBy,
    _is.OrderByListBuilder<ProfileDetailsTable>? orderByList,
    ProfileDetailsInclude? include,
  }) {
    return ProfileDetailsIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(ProfileDetails.t),
      orderByList: orderByList?.call(ProfileDetails.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _ProfileDetailsImpl extends ProfileDetails {
  _ProfileDetailsImpl({
    int? id,
    required _is.UuidValue authUserId,
    _iacs.AuthUser? authUser,
    String? firstName,
    String? lastName,
    DateTime? birthday,
  }) : super._(
         id: id,
         authUserId: authUserId,
         authUser: authUser,
         firstName: firstName,
         lastName: lastName,
         birthday: birthday,
       );

  /// Returns a shallow copy of this [ProfileDetails]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  ProfileDetails copyWith({
    Object? id = _Undefined,
    _is.UuidValue? authUserId,
    Object? authUser = _Undefined,
    Object? firstName = _Undefined,
    Object? lastName = _Undefined,
    Object? birthday = _Undefined,
  }) {
    return ProfileDetails(
      id: id is int? ? id : this.id,
      authUserId: authUserId ?? this.authUserId,
      authUser: authUser is _iacs.AuthUser?
          ? authUser
          : this.authUser?.copyWith(),
      firstName: firstName is String? ? firstName : this.firstName,
      lastName: lastName is String? ? lastName : this.lastName,
      birthday: birthday is DateTime? ? birthday : this.birthday,
    );
  }
}

class ProfileDetailsUpdateTable extends _is.UpdateTable<ProfileDetailsTable> {
  ProfileDetailsUpdateTable(super.table);

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> authUserId(
    _is.UuidValue value,
  ) => _is.ColumnValue(
    table.authUserId,
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
}

class ProfileDetailsTable extends _is.Table<int?> {
  ProfileDetailsTable({super.tableRelation})
    : super(tableName: 'profile_details') {
    updateTable = ProfileDetailsUpdateTable(this);
    authUserId = _is.ColumnUuid(
      'authUserId',
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
  }

  late final ProfileDetailsUpdateTable updateTable;

  late final _is.ColumnUuid authUserId;

  /// The AuthUser this data belongs to.
  _iacs.AuthUserTable? _authUser;

  late final _is.ColumnString firstName;

  late final _is.ColumnString lastName;

  late final _is.ColumnDateTime birthday;

  _iacs.AuthUserTable get authUser {
    if (_authUser != null) return _authUser!;
    _authUser = _is.createRelationTable(
      relationFieldName: 'authUser',
      field: ProfileDetails.t.authUserId,
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
    firstName,
    lastName,
    birthday,
  ];

  @override
  _is.Table? getRelationTable(String relationField) {
    if (relationField == 'authUser') {
      return authUser;
    }
    return null;
  }
}

class ProfileDetailsInclude extends _is.IncludeObject {
  ProfileDetailsInclude._({_iacs.AuthUserInclude? authUser}) {
    _authUser = authUser;
  }

  _iacs.AuthUserInclude? _authUser;

  @override
  Map<String, _is.Include?> get includes => {'authUser': _authUser};

  @override
  _is.Table<int?> get table => ProfileDetails.t;
}

class ProfileDetailsIncludeList extends _is.IncludeList {
  ProfileDetailsIncludeList._({
    _is.WhereExpressionBuilder<ProfileDetailsTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(ProfileDetails.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => ProfileDetails.t;
}

class ProfileDetailsRepository {
  const ProfileDetailsRepository._();

  final attachRow = const ProfileDetailsAttachRowRepository._();

  /// Returns a list of [ProfileDetails]s matching the given query parameters.
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
  Future<List<ProfileDetails>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<ProfileDetailsTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<ProfileDetailsTable>? orderBy,
    _is.OrderByListBuilder<ProfileDetailsTable>? orderByList,
    _is.Transaction? transaction,
    ProfileDetailsInclude? include,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<ProfileDetails>(
      where: where?.call(ProfileDetails.t),
      orderBy: orderBy?.call(ProfileDetails.t),
      orderByList: orderByList?.call(ProfileDetails.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      include: include,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [ProfileDetails] matching the given query parameters.
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
  Future<ProfileDetails?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<ProfileDetailsTable>? where,
    int? offset,
    _is.OrderByBuilder<ProfileDetailsTable>? orderBy,
    _is.OrderByListBuilder<ProfileDetailsTable>? orderByList,
    _is.Transaction? transaction,
    ProfileDetailsInclude? include,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<ProfileDetails>(
      where: where?.call(ProfileDetails.t),
      orderBy: orderBy?.call(ProfileDetails.t),
      orderByList: orderByList?.call(ProfileDetails.t),
      offset: offset,
      transaction: transaction,
      include: include,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [ProfileDetails] by its [id] or null if no such row exists.
  Future<ProfileDetails?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    ProfileDetailsInclude? include,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<ProfileDetails>(
      id,
      transaction: transaction,
      include: include,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [ProfileDetails]s in the list and returns the inserted rows.
  ///
  /// The returned [ProfileDetails]s will have their `id` fields set.
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
  Future<List<ProfileDetails>> insert(
    _is.DatabaseSession session,
    List<ProfileDetails> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<ProfileDetails>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [ProfileDetails] and returns the inserted row.
  ///
  /// The returned [ProfileDetails] will have its `id` field set.
  Future<ProfileDetails> insertRow(
    _is.DatabaseSession session,
    ProfileDetails row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<ProfileDetails>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [ProfileDetails]s in the list and returns the resulting rows.
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
  /// The returned [ProfileDetails]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<ProfileDetails>> upsert(
    _is.DatabaseSession session,
    List<ProfileDetails> rows, {
    required _is.ColumnSelections<ProfileDetailsTable> conflictColumns,
    _is.ColumnSelections<ProfileDetailsTable>? updateColumns,
    _is.WhereExpressionBuilder<ProfileDetailsTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<ProfileDetails>(
      rows,
      conflictColumns: conflictColumns(ProfileDetails.t),
      updateColumns: updateColumns?.call(ProfileDetails.t),
      updateWhere: updateWhere?.call(ProfileDetails.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [ProfileDetails] and returns the resulting row.
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
  /// The returned [ProfileDetails] will have its `id` field set.
  Future<ProfileDetails?> upsertRow(
    _is.DatabaseSession session,
    ProfileDetails row, {
    required _is.ColumnSelections<ProfileDetailsTable> conflictColumns,
    _is.ColumnSelections<ProfileDetailsTable>? updateColumns,
    _is.WhereExpressionBuilder<ProfileDetailsTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<ProfileDetails>(
      row,
      conflictColumns: conflictColumns(ProfileDetails.t),
      updateColumns: updateColumns?.call(ProfileDetails.t),
      updateWhere: updateWhere?.call(ProfileDetails.t),
      transaction: transaction,
    );
  }

  /// Updates all [ProfileDetails]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<ProfileDetails>> update(
    _is.DatabaseSession session,
    List<ProfileDetails> rows, {
    _is.ColumnSelections<ProfileDetailsTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<ProfileDetails>(
      rows,
      columns: columns?.call(ProfileDetails.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [ProfileDetails]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<ProfileDetails> updateRow(
    _is.DatabaseSession session,
    ProfileDetails row, {
    _is.ColumnSelections<ProfileDetailsTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<ProfileDetails>(
      row,
      columns: columns?.call(ProfileDetails.t),
      transaction: transaction,
    );
  }

  /// Updates a single [ProfileDetails] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<ProfileDetails?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<ProfileDetailsUpdateTable> columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<ProfileDetails>(
      id,
      columnValues: columnValues(ProfileDetails.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [ProfileDetails]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<ProfileDetails>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<ProfileDetailsUpdateTable> columnValues,
    required _is.WhereExpressionBuilder<ProfileDetailsTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<ProfileDetailsTable>? orderBy,
    _is.OrderByListBuilder<ProfileDetailsTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<ProfileDetails>(
      columnValues: columnValues(ProfileDetails.t.updateTable),
      where: where(ProfileDetails.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(ProfileDetails.t),
      orderByList: orderByList?.call(ProfileDetails.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [ProfileDetails]s in the list and returns the deleted rows.
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
  Future<List<ProfileDetails>> delete(
    _is.DatabaseSession session,
    List<ProfileDetails> rows, {
    _is.OrderByBuilder<ProfileDetailsTable>? orderBy,
    _is.OrderByListBuilder<ProfileDetailsTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<ProfileDetails>(
      rows,
      orderBy: orderBy?.call(ProfileDetails.t),
      orderByList: orderByList?.call(ProfileDetails.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [ProfileDetails].
  Future<ProfileDetails> deleteRow(
    _is.DatabaseSession session,
    ProfileDetails row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<ProfileDetails>(
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
  Future<List<ProfileDetails>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<ProfileDetailsTable> where,
    _is.OrderByBuilder<ProfileDetailsTable>? orderBy,
    _is.OrderByListBuilder<ProfileDetailsTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<ProfileDetails>(
      where: where(ProfileDetails.t),
      orderBy: orderBy?.call(ProfileDetails.t),
      orderByList: orderByList?.call(ProfileDetails.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<ProfileDetailsTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<ProfileDetails>(
      where: where?.call(ProfileDetails.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [ProfileDetails] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<ProfileDetailsTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<ProfileDetails>(
      where: where(ProfileDetails.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}

class ProfileDetailsAttachRowRepository {
  const ProfileDetailsAttachRowRepository._();

  /// Creates a relation between the given [ProfileDetails] and [AuthUser]
  /// by setting the [ProfileDetails]'s foreign key `authUserId` to refer to the [AuthUser].
  Future<void> authUser(
    _is.DatabaseSession session,
    ProfileDetails profileDetails,
    _iacs.AuthUser authUser, {
    _is.Transaction? transaction,
  }) async {
    if (profileDetails.id == null) {
      throw ArgumentError.notNull('profileDetails.id');
    }
    if (authUser.id == null) {
      throw ArgumentError.notNull('authUser.id');
    }

    var $profileDetails = profileDetails.copyWith(authUserId: authUser.id);
    await session.db.updateRow<ProfileDetails>(
      $profileDetails,
      columns: [ProfileDetails.t.authUserId],
      transaction: transaction,
    );
  }
}
