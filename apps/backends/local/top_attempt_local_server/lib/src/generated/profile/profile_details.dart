/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters
// ignore_for_file: invalid_use_of_internal_member
// ignore_for_file: unnecessary_null_comparison

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:serverpod/serverpod.dart' as _i1;
import 'package:serverpod_auth_core_server/serverpod_auth_core_server.dart'
    as _i2;
import 'package:top_attempt_local_server/src/generated/protocol.dart' as _i3;

abstract class ProfileDetails
    implements _i1.TableRow<int?>, _i1.ProtocolSerialization {
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
    required _i1.UuidValue authUserId,
    _i2.AuthUser? authUser,
    String? firstName,
    String? lastName,
    DateTime? birthday,
  }) = _ProfileDetailsImpl;

  factory ProfileDetails.fromJson(Map<String, dynamic> jsonSerialization) {
    return ProfileDetails(
      id: jsonSerialization['id'] as int?,
      authUserId: _i1.UuidValueJsonExtension.fromJson(
        jsonSerialization['authUserId'],
      ),
      authUser: jsonSerialization['authUser'] == null
          ? null
          : _i3.Protocol().deserialize<_i2.AuthUser>(
              jsonSerialization['authUser'],
            ),
      firstName: jsonSerialization['firstName'] as String?,
      lastName: jsonSerialization['lastName'] as String?,
      birthday: jsonSerialization['birthday'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['birthday']),
    );
  }

  static final t = ProfileDetailsTable();

  static const db = ProfileDetailsRepository._();

  @override
  int? id;

  _i1.UuidValue authUserId;

  /// The AuthUser this data belongs to.
  _i2.AuthUser? authUser;

  String? firstName;

  String? lastName;

  DateTime? birthday;

  @override
  _i1.Table<int?> get table => t;

  /// Returns a shallow copy of this [ProfileDetails]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  ProfileDetails copyWith({
    int? id,
    _i1.UuidValue? authUserId,
    _i2.AuthUser? authUser,
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
      if (authUser != null) 'authUser': authUser?.toJsonForProtocol(),
      if (firstName != null) 'firstName': firstName,
      if (lastName != null) 'lastName': lastName,
      if (birthday != null) 'birthday': birthday?.toJson(),
    };
  }

  static ProfileDetailsInclude include({_i2.AuthUserInclude? authUser}) {
    return ProfileDetailsInclude._(authUser: authUser);
  }

  static ProfileDetailsIncludeList includeList({
    _i1.WhereExpressionBuilder<ProfileDetailsTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<ProfileDetailsTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<ProfileDetailsTable>? orderByList,
    ProfileDetailsInclude? include,
  }) {
    return ProfileDetailsIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(ProfileDetails.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(ProfileDetails.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _ProfileDetailsImpl extends ProfileDetails {
  _ProfileDetailsImpl({
    int? id,
    required _i1.UuidValue authUserId,
    _i2.AuthUser? authUser,
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
  @_i1.useResult
  @override
  ProfileDetails copyWith({
    Object? id = _Undefined,
    _i1.UuidValue? authUserId,
    Object? authUser = _Undefined,
    Object? firstName = _Undefined,
    Object? lastName = _Undefined,
    Object? birthday = _Undefined,
  }) {
    return ProfileDetails(
      id: id is int? ? id : this.id,
      authUserId: authUserId ?? this.authUserId,
      authUser: authUser is _i2.AuthUser?
          ? authUser
          : this.authUser?.copyWith(),
      firstName: firstName is String? ? firstName : this.firstName,
      lastName: lastName is String? ? lastName : this.lastName,
      birthday: birthday is DateTime? ? birthday : this.birthday,
    );
  }
}

class ProfileDetailsUpdateTable extends _i1.UpdateTable<ProfileDetailsTable> {
  ProfileDetailsUpdateTable(super.table);

  _i1.ColumnValue<_i1.UuidValue, _i1.UuidValue> authUserId(
    _i1.UuidValue value,
  ) => _i1.ColumnValue(
    table.authUserId,
    value,
  );

  _i1.ColumnValue<String, String> firstName(String? value) => _i1.ColumnValue(
    table.firstName,
    value,
  );

  _i1.ColumnValue<String, String> lastName(String? value) => _i1.ColumnValue(
    table.lastName,
    value,
  );

  _i1.ColumnValue<DateTime, DateTime> birthday(DateTime? value) =>
      _i1.ColumnValue(
        table.birthday,
        value,
      );
}

class ProfileDetailsTable extends _i1.Table<int?> {
  ProfileDetailsTable({super.tableRelation})
    : super(tableName: 'profile_details') {
    updateTable = ProfileDetailsUpdateTable(this);
    authUserId = _i1.ColumnUuid(
      'authUserId',
      this,
    );
    firstName = _i1.ColumnString(
      'firstName',
      this,
    );
    lastName = _i1.ColumnString(
      'lastName',
      this,
    );
    birthday = _i1.ColumnDateTime(
      'birthday',
      this,
    );
  }

  late final ProfileDetailsUpdateTable updateTable;

  late final _i1.ColumnUuid authUserId;

  /// The AuthUser this data belongs to.
  _i2.AuthUserTable? _authUser;

  late final _i1.ColumnString firstName;

  late final _i1.ColumnString lastName;

  late final _i1.ColumnDateTime birthday;

  _i2.AuthUserTable get authUser {
    if (_authUser != null) return _authUser!;
    _authUser = _i1.createRelationTable(
      relationFieldName: 'authUser',
      field: ProfileDetails.t.authUserId,
      foreignField: _i2.AuthUser.t.id,
      tableRelation: tableRelation,
      createTable: (foreignTableRelation) =>
          _i2.AuthUserTable(tableRelation: foreignTableRelation),
    );
    return _authUser!;
  }

  @override
  List<_i1.Column> get columns => [
    id,
    authUserId,
    firstName,
    lastName,
    birthday,
  ];

  @override
  _i1.Table? getRelationTable(String relationField) {
    if (relationField == 'authUser') {
      return authUser;
    }
    return null;
  }
}

class ProfileDetailsInclude extends _i1.IncludeObject {
  ProfileDetailsInclude._({_i2.AuthUserInclude? authUser}) {
    _authUser = authUser;
  }

  _i2.AuthUserInclude? _authUser;

  @override
  Map<String, _i1.Include?> get includes => {'authUser': _authUser};

  @override
  _i1.Table<int?> get table => ProfileDetails.t;
}

class ProfileDetailsIncludeList extends _i1.IncludeList {
  ProfileDetailsIncludeList._({
    _i1.WhereExpressionBuilder<ProfileDetailsTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(ProfileDetails.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<int?> get table => ProfileDetails.t;
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
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<ProfileDetailsTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<ProfileDetailsTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<ProfileDetailsTable>? orderByList,
    _i1.Transaction? transaction,
    ProfileDetailsInclude? include,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<ProfileDetails>(
      where: where?.call(ProfileDetails.t),
      orderBy: orderBy?.call(ProfileDetails.t),
      orderByList: orderByList?.call(ProfileDetails.t),
      orderDescending: orderDescending,
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
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<ProfileDetailsTable>? where,
    int? offset,
    _i1.OrderByBuilder<ProfileDetailsTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<ProfileDetailsTable>? orderByList,
    _i1.Transaction? transaction,
    ProfileDetailsInclude? include,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<ProfileDetails>(
      where: where?.call(ProfileDetails.t),
      orderBy: orderBy?.call(ProfileDetails.t),
      orderByList: orderByList?.call(ProfileDetails.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
      include: include,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [ProfileDetails] by its [id] or null if no such row exists.
  Future<ProfileDetails?> findById(
    _i1.DatabaseSession session,
    int id, {
    _i1.Transaction? transaction,
    ProfileDetailsInclude? include,
    _i1.LockMode? lockMode,
    _i1.LockBehavior? lockBehavior,
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
  Future<List<ProfileDetails>> insert(
    _i1.DatabaseSession session,
    List<ProfileDetails> rows, {
    _i1.Transaction? transaction,
    bool ignoreConflicts = false,
  }) async {
    return session.db.insert<ProfileDetails>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
    );
  }

  /// Inserts a single [ProfileDetails] and returns the inserted row.
  ///
  /// The returned [ProfileDetails] will have its `id` field set.
  Future<ProfileDetails> insertRow(
    _i1.DatabaseSession session,
    ProfileDetails row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<ProfileDetails>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [ProfileDetails]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<ProfileDetails>> update(
    _i1.DatabaseSession session,
    List<ProfileDetails> rows, {
    _i1.ColumnSelections<ProfileDetailsTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<ProfileDetails>(
      rows,
      columns: columns?.call(ProfileDetails.t),
      transaction: transaction,
    );
  }

  /// Updates a single [ProfileDetails]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<ProfileDetails> updateRow(
    _i1.DatabaseSession session,
    ProfileDetails row, {
    _i1.ColumnSelections<ProfileDetailsTable>? columns,
    _i1.Transaction? transaction,
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
    _i1.DatabaseSession session,
    int id, {
    required _i1.ColumnValueListBuilder<ProfileDetailsUpdateTable> columnValues,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateById<ProfileDetails>(
      id,
      columnValues: columnValues(ProfileDetails.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [ProfileDetails]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  Future<List<ProfileDetails>> updateWhere(
    _i1.DatabaseSession session, {
    required _i1.ColumnValueListBuilder<ProfileDetailsUpdateTable> columnValues,
    required _i1.WhereExpressionBuilder<ProfileDetailsTable> where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<ProfileDetailsTable>? orderBy,
    _i1.OrderByListBuilder<ProfileDetailsTable>? orderByList,
    bool orderDescending = false,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateWhere<ProfileDetails>(
      columnValues: columnValues(ProfileDetails.t.updateTable),
      where: where(ProfileDetails.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(ProfileDetails.t),
      orderByList: orderByList?.call(ProfileDetails.t),
      orderDescending: orderDescending,
      transaction: transaction,
    );
  }

  /// Deletes all [ProfileDetails]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<ProfileDetails>> delete(
    _i1.DatabaseSession session,
    List<ProfileDetails> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<ProfileDetails>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [ProfileDetails].
  Future<ProfileDetails> deleteRow(
    _i1.DatabaseSession session,
    ProfileDetails row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<ProfileDetails>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<ProfileDetails>> deleteWhere(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<ProfileDetailsTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<ProfileDetails>(
      where: where(ProfileDetails.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.DatabaseSession session, {
    _i1.WhereExpressionBuilder<ProfileDetailsTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<ProfileDetails>(
      where: where?.call(ProfileDetails.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [ProfileDetails] rows matching the [where] expression.
  Future<void> lockRows(
    _i1.DatabaseSession session, {
    required _i1.WhereExpressionBuilder<ProfileDetailsTable> where,
    required _i1.LockMode lockMode,
    required _i1.Transaction transaction,
    _i1.LockBehavior lockBehavior = _i1.LockBehavior.wait,
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
    _i1.DatabaseSession session,
    ProfileDetails profileDetails,
    _i2.AuthUser authUser, {
    _i1.Transaction? transaction,
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
