/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters
// ignore_for_file: invalid_use_of_internal_member
// ignore_for_file: dead_code, unnecessary_type_check

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:serverpod_auth_core_client/serverpod_auth_core_client.dart'
    as _iacc;
import 'package:serverpod_auth_idp_client/serverpod_auth_idp_client.dart'
    as _iaic;
import 'package:serverpod_client/serverpod_client.dart' as _isc;
import 'greetings/greeting.dart' as _izw8z7ou;
import 'profile/profile_details.dart' as _is7ofcfc;
import 'site/member.dart' as _ixt8mg2q;
import 'site/site_candidate_local.dart' as _iin2gxgd;
import 'site/site_connection.dart' as _irwm5040;
import 'site/site_connection_info.dart' as _i9oolunz;
import 'site/site_connection_state.dart' as _ifrxdjdr;
import 'site/site_setup_exception.dart' as _imfczqeb;
import 'site/site_setup_result.dart' as _in5mc098;
export 'greetings/greeting.dart';
export 'profile/profile_details.dart';
export 'site/member.dart';
export 'site/site_candidate_local.dart';
export 'site/site_connection.dart';
export 'site/site_connection_info.dart';
export 'site/site_connection_state.dart';
export 'site/site_setup_exception.dart';
export 'site/site_setup_result.dart';
export 'client.dart';

class Protocol extends _isc.SerializationManager {
  Protocol._();

  factory Protocol() => _instance;

  static final Protocol _instance = Protocol._().._registerHostProtocols();

  static String? getClassNameFromObjectJson(dynamic data) {
    if (data is! Map) return null;
    final className = data['__className__'] as String?;
    return className;
  }

  @override
  T deserialize<T>(
    dynamic data, [
    Type? t,
  ]) {
    t ??= T;

    final dataClassName = getClassNameFromObjectJson(data);
    if (dataClassName != null && dataClassName != getClassNameForType(t)) {
      try {
        return deserializeByClassName({
          'className': dataClassName,
          'data': data,
        });
      } on _isc.DeserializationClassNameNotFoundException catch (_) {
        // If the className is not recognized (e.g., older client receiving
        // data with a new subtype), fall back to deserializing without the
        // className, using the expected type T.
      }
    }

    if (t == _izw8z7ou.Greeting) {
      return _izw8z7ou.Greeting.fromJson(data) as T;
    }
    if (t == _is7ofcfc.ProfileDetails) {
      return _is7ofcfc.ProfileDetails.fromJson(data) as T;
    }
    if (t == _ixt8mg2q.Member) {
      return _ixt8mg2q.Member.fromJson(data) as T;
    }
    if (t == _iin2gxgd.SiteCandidateLocal) {
      return _iin2gxgd.SiteCandidateLocal.fromJson(data) as T;
    }
    if (t == _irwm5040.SiteConnection) {
      return _irwm5040.SiteConnection.fromJson(data) as T;
    }
    if (t == _i9oolunz.SiteConnectionInfo) {
      return _i9oolunz.SiteConnectionInfo.fromJson(data) as T;
    }
    if (t == _ifrxdjdr.SiteConnectionState) {
      return _ifrxdjdr.SiteConnectionState.fromJson(data) as T;
    }
    if (t == _imfczqeb.SiteSetupException) {
      return _imfczqeb.SiteSetupException.fromJson(data) as T;
    }
    if (t == _in5mc098.SiteSetupResult) {
      return _in5mc098.SiteSetupResult.fromJson(data) as T;
    }
    if (t == _isc.getType<_izw8z7ou.Greeting?>()) {
      return (data != null ? _izw8z7ou.Greeting.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_is7ofcfc.ProfileDetails?>()) {
      return (data != null ? _is7ofcfc.ProfileDetails.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_ixt8mg2q.Member?>()) {
      return (data != null ? _ixt8mg2q.Member.fromJson(data) : null) as T;
    }
    if (t == _isc.getType<_iin2gxgd.SiteCandidateLocal?>()) {
      return (data != null ? _iin2gxgd.SiteCandidateLocal.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_irwm5040.SiteConnection?>()) {
      return (data != null ? _irwm5040.SiteConnection.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_i9oolunz.SiteConnectionInfo?>()) {
      return (data != null ? _i9oolunz.SiteConnectionInfo.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_ifrxdjdr.SiteConnectionState?>()) {
      return (data != null
              ? _ifrxdjdr.SiteConnectionState.fromJson(data)
              : null)
          as T;
    }
    if (t == _isc.getType<_imfczqeb.SiteSetupException?>()) {
      return (data != null ? _imfczqeb.SiteSetupException.fromJson(data) : null)
          as T;
    }
    if (t == _isc.getType<_in5mc098.SiteSetupResult?>()) {
      return (data != null ? _in5mc098.SiteSetupResult.fromJson(data) : null)
          as T;
    }
    if (t == List<_iin2gxgd.SiteCandidateLocal>) {
      return (data as List)
              .map((e) => deserialize<_iin2gxgd.SiteCandidateLocal>(e))
              .toList()
          as T;
    }
    try {
      return _iaic.Protocol().deserialize<T>(data, t);
    } on _isc.DeserializationTypeNotFoundException catch (_) {}
    try {
      return _iacc.Protocol().deserialize<T>(data, t);
    } on _isc.DeserializationTypeNotFoundException catch (_) {}
    return super.deserialize<T>(data, t);
  }

  static String? getClassNameForType(Type type) {
    return switch (type) {
      _izw8z7ou.Greeting => 'Greeting',
      _is7ofcfc.ProfileDetails => 'ProfileDetails',
      _ixt8mg2q.Member => 'Member',
      _iin2gxgd.SiteCandidateLocal => 'SiteCandidateLocal',
      _irwm5040.SiteConnection => 'SiteConnection',
      _i9oolunz.SiteConnectionInfo => 'SiteConnectionInfo',
      _ifrxdjdr.SiteConnectionState => 'SiteConnectionState',
      _imfczqeb.SiteSetupException => 'SiteSetupException',
      _in5mc098.SiteSetupResult => 'SiteSetupResult',
      _ => null,
    };
  }

  @override
  String? getClassNameForObject(Object? data) {
    String? className = super.getClassNameForObject(data);
    if (className != null) return className;

    if (data is Map<String, dynamic> && data['__className__'] is String) {
      return (data['__className__'] as String).replaceFirst(
        'top_attempt_local.',
        '',
      );
    }

    switch (data) {
      case _izw8z7ou.Greeting():
        return 'Greeting';
      case _is7ofcfc.ProfileDetails():
        return 'ProfileDetails';
      case _ixt8mg2q.Member():
        return 'Member';
      case _iin2gxgd.SiteCandidateLocal():
        return 'SiteCandidateLocal';
      case _irwm5040.SiteConnection():
        return 'SiteConnection';
      case _i9oolunz.SiteConnectionInfo():
        return 'SiteConnectionInfo';
      case _ifrxdjdr.SiteConnectionState():
        return 'SiteConnectionState';
      case _imfczqeb.SiteSetupException():
        return 'SiteSetupException';
      case _in5mc098.SiteSetupResult():
        return 'SiteSetupResult';
    }
    className = _iaic.Protocol().getClassNameForObject(data);
    if (className != null) {
      return className.contains('.')
          ? className
          : 'serverpod_auth_idp.$className';
    }
    className = _iacc.Protocol().getClassNameForObject(data);
    if (className != null) {
      return className.contains('.')
          ? className
          : 'serverpod_auth_core.$className';
    }
    return null;
  }

  @override
  dynamic deserializeByClassName(Map<String, dynamic> data) {
    var dataClassName = data['className'];
    if (dataClassName is! String) {
      return super.deserializeByClassName(data);
    }
    if (dataClassName == 'Greeting') {
      return deserialize<_izw8z7ou.Greeting>(data['data']);
    }
    if (dataClassName == 'ProfileDetails') {
      return deserialize<_is7ofcfc.ProfileDetails>(data['data']);
    }
    if (dataClassName == 'Member') {
      return deserialize<_ixt8mg2q.Member>(data['data']);
    }
    if (dataClassName == 'SiteCandidateLocal') {
      return deserialize<_iin2gxgd.SiteCandidateLocal>(data['data']);
    }
    if (dataClassName == 'SiteConnection') {
      return deserialize<_irwm5040.SiteConnection>(data['data']);
    }
    if (dataClassName == 'SiteConnectionInfo') {
      return deserialize<_i9oolunz.SiteConnectionInfo>(data['data']);
    }
    if (dataClassName == 'SiteConnectionState') {
      return deserialize<_ifrxdjdr.SiteConnectionState>(data['data']);
    }
    if (dataClassName == 'SiteSetupException') {
      return deserialize<_imfczqeb.SiteSetupException>(data['data']);
    }
    if (dataClassName == 'SiteSetupResult') {
      return deserialize<_in5mc098.SiteSetupResult>(data['data']);
    }
    if (dataClassName.startsWith('serverpod_auth_idp.')) {
      data['className'] = dataClassName.substring(19);
      return _iaic.Protocol().deserializeByClassName(data);
    }
    if (dataClassName.startsWith('serverpod_auth_core.')) {
      data['className'] = dataClassName.substring(20);
      return _iacc.Protocol().deserializeByClassName(data);
    }
    return super.deserializeByClassName(data);
  }

  void _registerHostProtocols() {
    _iaic.Protocol().registerHostProtocol('top_attempt_local', this);
    _iacc.Protocol().registerHostProtocol('top_attempt_local', this);
  }

  @override
  String getModuleName() => 'top_attempt_local';

  /// Maps any `Record`s known to this [Protocol] to their JSON representation
  ///
  /// Throws in case the record type is not known.
  ///
  /// This method will return `null` (only) for `null` inputs.
  Map<String, dynamic>? mapRecordToJson(Record? record) {
    if (record == null) {
      return null;
    }
    try {
      return _iaic.Protocol().mapRecordToJson(record);
    } catch (_) {}
    try {
      return _iacc.Protocol().mapRecordToJson(record);
    } catch (_) {}
    throw Exception('Unsupported record type ${record.runtimeType}');
  }
}
