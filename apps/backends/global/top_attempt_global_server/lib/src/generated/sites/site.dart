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
import '../sites/site_setup_status.dart' as _i3pb1w5u;

/// A site ("Betrieb") at the global instance. One operating local instance
/// per site; the local BackendMeldung enrolls itself with the generated one
/// time password and establishes the connection to this record.
abstract class Site implements _is.TableRow<int?>, _is.ProtocolSerialization {
  Site._({
    this.id,
    required this.name,
    required this.street,
    required this.zipCode,
    required this.city,
    required this.country,
    required this.companyEmail,
    _i3pb1w5u.SiteSetupStatus? status,
    required this.firstAdminId,
    this.firstAdmin,
    this.oneTimePasswordHash,
    this.initialAdminPasswordEncrypted,
    this.registeredAt,
    this.lastSeenAt,
    DateTime? createdAt,
  }) : status = status ?? _i3pb1w5u.SiteSetupStatus.pendingSetup,
       createdAt = createdAt ?? DateTime.now();

  factory Site({
    int? id,
    required String name,
    required String street,
    required String zipCode,
    required String city,
    required String country,
    required String companyEmail,
    _i3pb1w5u.SiteSetupStatus? status,
    required _is.UuidValue firstAdminId,
    _iacs.AuthUser? firstAdmin,
    String? oneTimePasswordHash,
    String? initialAdminPasswordEncrypted,
    DateTime? registeredAt,
    DateTime? lastSeenAt,
    DateTime? createdAt,
  }) = _SiteImpl;

  factory Site.fromJson(Map<String, dynamic> jsonSerialization) {
    return Site(
      id: jsonSerialization['id'] as int?,
      name: jsonSerialization['name'] as String,
      street: jsonSerialization['street'] as String,
      zipCode: jsonSerialization['zipCode'] as String,
      city: jsonSerialization['city'] as String,
      country: jsonSerialization['country'] as String,
      companyEmail: jsonSerialization['companyEmail'] as String,
      status: jsonSerialization['status'] == null
          ? null
          : _i3pb1w5u.SiteSetupStatus.fromJson(
              (jsonSerialization['status'] as String),
            ),
      firstAdminId: _is.UuidValueJsonExtension.fromJson(
        jsonSerialization['firstAdminId'],
      ),
      firstAdmin: jsonSerialization['firstAdmin'] == null
          ? null
          : _in02tfqf.Protocol().deserialize<_iacs.AuthUser>(
              jsonSerialization['firstAdmin'],
            ),
      oneTimePasswordHash: jsonSerialization['oneTimePasswordHash'] as String?,
      initialAdminPasswordEncrypted:
          jsonSerialization['initialAdminPasswordEncrypted'] as String?,
      registeredAt: jsonSerialization['registeredAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(
              jsonSerialization['registeredAt'],
            ),
      lastSeenAt: jsonSerialization['lastSeenAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['lastSeenAt']),
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _is.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
    );
  }

  static final t = SiteTable();

  static const db = SiteRepository._();

  @override
  int? id;

  /// Name of the site/company.
  String name;

  /// Address data (single fields; the UI renders them as one block).
  String street;

  String zipCode;

  String city;

  String country;

  /// Company email (contact mail of the operating company, for later
  /// mail-based delivery of setup material).
  String companyEmail;

  /// Connect status of the site (setup pending / registered).
  _i3pb1w5u.SiteSetupStatus status;

  _is.UuidValue firstAdminId;

  /// Creation-time convenience link to the first site administrator
  /// (authoritative linkage is the `SiteMembership` with role siteAdmin).
  _iacs.AuthUser? firstAdmin;

  /// Hash of the one-time password the local instance uses to register.
  String? oneTimePasswordHash;

  /// Initial password for the local admin AuthUser; deliverable at first
  /// connect, cleared immediately after transfer. Encrypted at rest (key
  /// from `passwords.yaml`).
  String? initialAdminPasswordEncrypted;

  /// When the local instance registered at the global instance.
  DateTime? registeredAt;

  /// Last heartbeat of the local instance (connectivity display).
  DateTime? lastSeenAt;

  /// When the site record was created.
  DateTime createdAt;

  @override
  _is.Table<int?> get table => t;

  /// Returns a shallow copy of this [Site]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  Site copyWith({
    int? id,
    String? name,
    String? street,
    String? zipCode,
    String? city,
    String? country,
    String? companyEmail,
    _i3pb1w5u.SiteSetupStatus? status,
    _is.UuidValue? firstAdminId,
    _iacs.AuthUser? firstAdmin,
    String? oneTimePasswordHash,
    String? initialAdminPasswordEncrypted,
    DateTime? registeredAt,
    DateTime? lastSeenAt,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'Site',
      if (id != null) 'id': id,
      'name': name,
      'street': street,
      'zipCode': zipCode,
      'city': city,
      'country': country,
      'companyEmail': companyEmail,
      'status': status.toJson(),
      'firstAdminId': firstAdminId.toJson(),
      if (firstAdmin != null) 'firstAdmin': firstAdmin?.toJson(),
      if (oneTimePasswordHash != null)
        'oneTimePasswordHash': oneTimePasswordHash,
      if (initialAdminPasswordEncrypted != null)
        'initialAdminPasswordEncrypted': initialAdminPasswordEncrypted,
      if (registeredAt != null) 'registeredAt': registeredAt?.toJson(),
      if (lastSeenAt != null) 'lastSeenAt': lastSeenAt?.toJson(),
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'Site',
      if (id != null) 'id': id,
      'name': name,
      'street': street,
      'zipCode': zipCode,
      'city': city,
      'country': country,
      'companyEmail': companyEmail,
      'status': status.toJson(),
      'firstAdminId': firstAdminId.toJson(),
      if (firstAdmin != null) 'firstAdmin': firstAdmin?.toJson(),
      if (registeredAt != null) 'registeredAt': registeredAt?.toJson(),
      if (lastSeenAt != null) 'lastSeenAt': lastSeenAt?.toJson(),
      'createdAt': createdAt.toJson(),
    };
  }

  static SiteInclude include({_iacs.AuthUserInclude? firstAdmin}) {
    return SiteInclude._(firstAdmin: firstAdmin);
  }

  static SiteIncludeList includeList({
    _is.WhereExpressionBuilder<SiteTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<SiteTable>? orderBy,
    _is.OrderByListBuilder<SiteTable>? orderByList,
    SiteInclude? include,
  }) {
    return SiteIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(Site.t),
      orderByList: orderByList?.call(Site.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _SiteImpl extends Site {
  _SiteImpl({
    int? id,
    required String name,
    required String street,
    required String zipCode,
    required String city,
    required String country,
    required String companyEmail,
    _i3pb1w5u.SiteSetupStatus? status,
    required _is.UuidValue firstAdminId,
    _iacs.AuthUser? firstAdmin,
    String? oneTimePasswordHash,
    String? initialAdminPasswordEncrypted,
    DateTime? registeredAt,
    DateTime? lastSeenAt,
    DateTime? createdAt,
  }) : super._(
         id: id,
         name: name,
         street: street,
         zipCode: zipCode,
         city: city,
         country: country,
         companyEmail: companyEmail,
         status: status,
         firstAdminId: firstAdminId,
         firstAdmin: firstAdmin,
         oneTimePasswordHash: oneTimePasswordHash,
         initialAdminPasswordEncrypted: initialAdminPasswordEncrypted,
         registeredAt: registeredAt,
         lastSeenAt: lastSeenAt,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [Site]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  Site copyWith({
    Object? id = _Undefined,
    String? name,
    String? street,
    String? zipCode,
    String? city,
    String? country,
    String? companyEmail,
    _i3pb1w5u.SiteSetupStatus? status,
    _is.UuidValue? firstAdminId,
    Object? firstAdmin = _Undefined,
    Object? oneTimePasswordHash = _Undefined,
    Object? initialAdminPasswordEncrypted = _Undefined,
    Object? registeredAt = _Undefined,
    Object? lastSeenAt = _Undefined,
    DateTime? createdAt,
  }) {
    return Site(
      id: id is int? ? id : this.id,
      name: name ?? this.name,
      street: street ?? this.street,
      zipCode: zipCode ?? this.zipCode,
      city: city ?? this.city,
      country: country ?? this.country,
      companyEmail: companyEmail ?? this.companyEmail,
      status: status ?? this.status,
      firstAdminId: firstAdminId ?? this.firstAdminId,
      firstAdmin: firstAdmin is _iacs.AuthUser?
          ? firstAdmin
          : this.firstAdmin?.copyWith(),
      oneTimePasswordHash: oneTimePasswordHash is String?
          ? oneTimePasswordHash
          : this.oneTimePasswordHash,
      initialAdminPasswordEncrypted: initialAdminPasswordEncrypted is String?
          ? initialAdminPasswordEncrypted
          : this.initialAdminPasswordEncrypted,
      registeredAt: registeredAt is DateTime?
          ? registeredAt
          : this.registeredAt,
      lastSeenAt: lastSeenAt is DateTime? ? lastSeenAt : this.lastSeenAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class SiteUpdateTable extends _is.UpdateTable<SiteTable> {
  SiteUpdateTable(super.table);

  _is.ColumnValue<String, String> name(String value) => _is.ColumnValue(
    table.name,
    value,
  );

  _is.ColumnValue<String, String> street(String value) => _is.ColumnValue(
    table.street,
    value,
  );

  _is.ColumnValue<String, String> zipCode(String value) => _is.ColumnValue(
    table.zipCode,
    value,
  );

  _is.ColumnValue<String, String> city(String value) => _is.ColumnValue(
    table.city,
    value,
  );

  _is.ColumnValue<String, String> country(String value) => _is.ColumnValue(
    table.country,
    value,
  );

  _is.ColumnValue<String, String> companyEmail(String value) => _is.ColumnValue(
    table.companyEmail,
    value,
  );

  _is.ColumnValue<_i3pb1w5u.SiteSetupStatus, _i3pb1w5u.SiteSetupStatus> status(
    _i3pb1w5u.SiteSetupStatus value,
  ) => _is.ColumnValue(
    table.status,
    value,
  );

  _is.ColumnValue<_is.UuidValue, _is.UuidValue> firstAdminId(
    _is.UuidValue value,
  ) => _is.ColumnValue(
    table.firstAdminId,
    value,
  );

  _is.ColumnValue<String, String> oneTimePasswordHash(String? value) =>
      _is.ColumnValue(
        table.oneTimePasswordHash,
        value,
      );

  _is.ColumnValue<String, String> initialAdminPasswordEncrypted(
    String? value,
  ) => _is.ColumnValue(
    table.initialAdminPasswordEncrypted,
    value,
  );

  _is.ColumnValue<DateTime, DateTime> registeredAt(DateTime? value) =>
      _is.ColumnValue(
        table.registeredAt,
        value,
      );

  _is.ColumnValue<DateTime, DateTime> lastSeenAt(DateTime? value) =>
      _is.ColumnValue(
        table.lastSeenAt,
        value,
      );

  _is.ColumnValue<DateTime, DateTime> createdAt(DateTime value) =>
      _is.ColumnValue(
        table.createdAt,
        value,
      );
}

class SiteTable extends _is.Table<int?> {
  SiteTable({super.tableRelation}) : super(tableName: 'sites') {
    updateTable = SiteUpdateTable(this);
    name = _is.ColumnString(
      'name',
      this,
    );
    street = _is.ColumnString(
      'street',
      this,
    );
    zipCode = _is.ColumnString(
      'zipCode',
      this,
    );
    city = _is.ColumnString(
      'city',
      this,
    );
    country = _is.ColumnString(
      'country',
      this,
    );
    companyEmail = _is.ColumnString(
      'companyEmail',
      this,
    );
    status = _is.ColumnEnum(
      'status',
      this,
      _is.EnumSerialization.byName,
    );
    firstAdminId = _is.ColumnUuid(
      'firstAdminId',
      this,
    );
    oneTimePasswordHash = _is.ColumnString(
      'oneTimePasswordHash',
      this,
    );
    initialAdminPasswordEncrypted = _is.ColumnString(
      'initialAdminPasswordEncrypted',
      this,
    );
    registeredAt = _is.ColumnDateTime(
      'registeredAt',
      this,
    );
    lastSeenAt = _is.ColumnDateTime(
      'lastSeenAt',
      this,
    );
    createdAt = _is.ColumnDateTime(
      'createdAt',
      this,
    );
  }

  late final SiteUpdateTable updateTable;

  /// Name of the site/company.
  late final _is.ColumnString name;

  /// Address data (single fields; the UI renders them as one block).
  late final _is.ColumnString street;

  late final _is.ColumnString zipCode;

  late final _is.ColumnString city;

  late final _is.ColumnString country;

  /// Company email (contact mail of the operating company, for later
  /// mail-based delivery of setup material).
  late final _is.ColumnString companyEmail;

  /// Connect status of the site (setup pending / registered).
  late final _is.ColumnEnum<_i3pb1w5u.SiteSetupStatus> status;

  late final _is.ColumnUuid firstAdminId;

  /// Creation-time convenience link to the first site administrator
  /// (authoritative linkage is the `SiteMembership` with role siteAdmin).
  _iacs.AuthUserTable? _firstAdmin;

  /// Hash of the one-time password the local instance uses to register.
  late final _is.ColumnString oneTimePasswordHash;

  /// Initial password for the local admin AuthUser; deliverable at first
  /// connect, cleared immediately after transfer. Encrypted at rest (key
  /// from `passwords.yaml`).
  late final _is.ColumnString initialAdminPasswordEncrypted;

  /// When the local instance registered at the global instance.
  late final _is.ColumnDateTime registeredAt;

  /// Last heartbeat of the local instance (connectivity display).
  late final _is.ColumnDateTime lastSeenAt;

  /// When the site record was created.
  late final _is.ColumnDateTime createdAt;

  _iacs.AuthUserTable get firstAdmin {
    if (_firstAdmin != null) return _firstAdmin!;
    _firstAdmin = _is.createRelationTable(
      relationFieldName: 'firstAdmin',
      field: Site.t.firstAdminId,
      foreignField: _iacs.AuthUser.t.id,
      tableRelation: tableRelation,
      createTable: (foreignTableRelation) =>
          _iacs.AuthUserTable(tableRelation: foreignTableRelation),
    );
    return _firstAdmin!;
  }

  @override
  List<_is.Column> get columns => [
    id,
    name,
    street,
    zipCode,
    city,
    country,
    companyEmail,
    status,
    firstAdminId,
    oneTimePasswordHash,
    initialAdminPasswordEncrypted,
    registeredAt,
    lastSeenAt,
    createdAt,
  ];

  @override
  _is.Table? getRelationTable(String relationField) {
    if (relationField == 'firstAdmin') {
      return firstAdmin;
    }
    return null;
  }
}

class SiteInclude extends _is.IncludeObject {
  SiteInclude._({_iacs.AuthUserInclude? firstAdmin}) {
    _firstAdmin = firstAdmin;
  }

  _iacs.AuthUserInclude? _firstAdmin;

  @override
  Map<String, _is.Include?> get includes => {'firstAdmin': _firstAdmin};

  @override
  _is.Table<int?> get table => Site.t;
}

class SiteIncludeList extends _is.IncludeList {
  SiteIncludeList._({
    _is.WhereExpressionBuilder<SiteTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(Site.t);
  }

  @override
  Map<String, _is.Include?> get includes => include?.includes ?? {};

  @override
  _is.Table<int?> get table => Site.t;
}

class SiteRepository {
  const SiteRepository._();

  final attachRow = const SiteAttachRowRepository._();

  /// Returns a list of [Site]s matching the given query parameters.
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
  Future<List<Site>> find(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<SiteTable>? where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<SiteTable>? orderBy,
    _is.OrderByListBuilder<SiteTable>? orderByList,
    _is.Transaction? transaction,
    SiteInclude? include,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.find<Site>(
      where: where?.call(Site.t),
      orderBy: orderBy?.call(Site.t),
      orderByList: orderByList?.call(Site.t),
      limit: limit,
      offset: offset,
      transaction: transaction,
      include: include,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Returns the first matching [Site] matching the given query parameters.
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
  Future<Site?> findFirstRow(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<SiteTable>? where,
    int? offset,
    _is.OrderByBuilder<SiteTable>? orderBy,
    _is.OrderByListBuilder<SiteTable>? orderByList,
    _is.Transaction? transaction,
    SiteInclude? include,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findFirstRow<Site>(
      where: where?.call(Site.t),
      orderBy: orderBy?.call(Site.t),
      orderByList: orderByList?.call(Site.t),
      offset: offset,
      transaction: transaction,
      include: include,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Finds a single [Site] by its [id] or null if no such row exists.
  Future<Site?> findById(
    _is.DatabaseSession session,
    int id, {
    _is.Transaction? transaction,
    SiteInclude? include,
    _is.LockMode? lockMode,
    _is.LockBehavior? lockBehavior,
  }) async {
    return session.db.findById<Site>(
      id,
      transaction: transaction,
      include: include,
      lockMode: lockMode,
      lockBehavior: lockBehavior,
    );
  }

  /// Inserts all [Site]s in the list and returns the inserted rows.
  ///
  /// The returned [Site]s will have their `id` fields set.
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
  Future<List<Site>> insert(
    _is.DatabaseSession session,
    List<Site> rows, {
    _is.Transaction? transaction,
    bool ignoreConflicts = false,
    bool noReturn = false,
  }) async {
    return session.db.insert<Site>(
      rows,
      transaction: transaction,
      ignoreConflicts: ignoreConflicts,
      noReturn: noReturn,
    );
  }

  /// Inserts a single [Site] and returns the inserted row.
  ///
  /// The returned [Site] will have its `id` field set.
  Future<Site> insertRow(
    _is.DatabaseSession session,
    Site row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.insertRow<Site>(
      row,
      transaction: transaction,
    );
  }

  /// Upserts all [Site]s in the list and returns the resulting rows.
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
  /// The returned [Site]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails,
  /// none of the rows will be affected.
  ///
  /// If [noReturn] is set to `true`, the resulting rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<Site>> upsert(
    _is.DatabaseSession session,
    List<Site> rows, {
    required _is.ColumnSelections<SiteTable> conflictColumns,
    _is.ColumnSelections<SiteTable>? updateColumns,
    _is.WhereExpressionBuilder<SiteTable>? updateWhere,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.upsert<Site>(
      rows,
      conflictColumns: conflictColumns(Site.t),
      updateColumns: updateColumns?.call(Site.t),
      updateWhere: updateWhere?.call(Site.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Upserts a single [Site] and returns the resulting row.
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
  /// The returned [Site] will have its `id` field set.
  Future<Site?> upsertRow(
    _is.DatabaseSession session,
    Site row, {
    required _is.ColumnSelections<SiteTable> conflictColumns,
    _is.ColumnSelections<SiteTable>? updateColumns,
    _is.WhereExpressionBuilder<SiteTable>? updateWhere,
    _is.Transaction? transaction,
  }) async {
    return session.db.upsertRow<Site>(
      row,
      conflictColumns: conflictColumns(Site.t),
      updateColumns: updateColumns?.call(Site.t),
      updateWhere: updateWhere?.call(Site.t),
      transaction: transaction,
    );
  }

  /// Updates all [Site]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<Site>> update(
    _is.DatabaseSession session,
    List<Site> rows, {
    _is.ColumnSelections<SiteTable>? columns,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.update<Site>(
      rows,
      columns: columns?.call(Site.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Updates a single [Site]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<Site> updateRow(
    _is.DatabaseSession session,
    Site row, {
    _is.ColumnSelections<SiteTable>? columns,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateRow<Site>(
      row,
      columns: columns?.call(Site.t),
      transaction: transaction,
    );
  }

  /// Updates a single [Site] by its [id] with the specified [columnValues].
  /// Returns the updated row or null if no row with the given id exists.
  Future<Site?> updateById(
    _is.DatabaseSession session,
    int id, {
    required _is.ColumnValueListBuilder<SiteUpdateTable> columnValues,
    _is.Transaction? transaction,
  }) async {
    return session.db.updateById<Site>(
      id,
      columnValues: columnValues(Site.t.updateTable),
      transaction: transaction,
    );
  }

  /// Updates all [Site]s matching the [where] expression with the specified [columnValues].
  /// Returns the list of updated rows.
  ///
  /// If [noReturn] is set to `true`, the updated rows are not read back from
  /// the database and an empty list is returned. This avoids the overhead of
  /// transferring and deserializing the rows when the result is not needed.
  Future<List<Site>> updateWhere(
    _is.DatabaseSession session, {
    required _is.ColumnValueListBuilder<SiteUpdateTable> columnValues,
    required _is.WhereExpressionBuilder<SiteTable> where,
    int? limit,
    int? offset,
    _is.OrderByBuilder<SiteTable>? orderBy,
    _is.OrderByListBuilder<SiteTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.updateWhere<Site>(
      columnValues: columnValues(Site.t.updateTable),
      where: where(Site.t),
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(Site.t),
      orderByList: orderByList?.call(Site.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes all [Site]s in the list and returns the deleted rows.
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
  Future<List<Site>> delete(
    _is.DatabaseSession session,
    List<Site> rows, {
    _is.OrderByBuilder<SiteTable>? orderBy,
    _is.OrderByListBuilder<SiteTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.delete<Site>(
      rows,
      orderBy: orderBy?.call(Site.t),
      orderByList: orderByList?.call(Site.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Deletes a single [Site].
  Future<Site> deleteRow(
    _is.DatabaseSession session,
    Site row, {
    _is.Transaction? transaction,
  }) async {
    return session.db.deleteRow<Site>(
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
  Future<List<Site>> deleteWhere(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<SiteTable> where,
    _is.OrderByBuilder<SiteTable>? orderBy,
    _is.OrderByListBuilder<SiteTable>? orderByList,
    _is.Transaction? transaction,
    bool noReturn = false,
  }) async {
    return session.db.deleteWhere<Site>(
      where: where(Site.t),
      orderBy: orderBy?.call(Site.t),
      orderByList: orderByList?.call(Site.t),
      transaction: transaction,
      noReturn: noReturn,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _is.DatabaseSession session, {
    _is.WhereExpressionBuilder<SiteTable>? where,
    int? limit,
    _is.Transaction? transaction,
  }) async {
    return session.db.count<Site>(
      where: where?.call(Site.t),
      limit: limit,
      transaction: transaction,
    );
  }

  /// Acquires row-level locks on [Site] rows matching the [where] expression.
  Future<void> lockRows(
    _is.DatabaseSession session, {
    required _is.WhereExpressionBuilder<SiteTable> where,
    required _is.LockMode lockMode,
    required _is.Transaction transaction,
    _is.LockBehavior lockBehavior = _is.LockBehavior.wait,
  }) async {
    return session.db.lockRows<Site>(
      where: where(Site.t),
      lockMode: lockMode,
      lockBehavior: lockBehavior,
      transaction: transaction,
    );
  }
}

class SiteAttachRowRepository {
  const SiteAttachRowRepository._();

  /// Creates a relation between the given [Site] and [AuthUser]
  /// by setting the [Site]'s foreign key `firstAdminId` to refer to the [AuthUser].
  Future<void> firstAdmin(
    _is.DatabaseSession session,
    Site site,
    _iacs.AuthUser firstAdmin, {
    _is.Transaction? transaction,
  }) async {
    if (site.id == null) {
      throw ArgumentError.notNull('site.id');
    }
    if (firstAdmin.id == null) {
      throw ArgumentError.notNull('firstAdmin.id');
    }

    var $site = site.copyWith(firstAdminId: firstAdmin.id);
    await session.db.updateRow<Site>(
      $site,
      columns: [Site.t.firstAdminId],
      transaction: transaction,
    );
  }
}
