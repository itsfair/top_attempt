abstract final class BleConstants {
  static const String qrPrefix = 'doorinterface|';
  static const String serviceUuid = '5f6d4f5a-0001-0001-8000-00805f9b34fb';
  static const String requestCharUuid = '5f6d4f5a-0002-0001-8000-00805f9b34fb';
  static const String responseCharUuid = '5f6d4f5a-0003-0001-8000-00805f9b34fb';
  static const Duration responseTimeout = Duration(seconds: 5);
  static const Duration connectTimeout = Duration(seconds: 10);
}

class ParsedQr {
  final String remoteId;
  final String? token;

  ParsedQr({required this.remoteId, this.token});

  static ParsedQr? tryParse(String raw) {
    if (!raw.startsWith(BleConstants.qrPrefix)) return null;
    final rest = raw.substring(BleConstants.qrPrefix.length);
    final parts = rest.split('|');
    if (parts.isEmpty || parts.first.isEmpty) return null;
    final remoteId = parts.first.toUpperCase();
    if (!_isValidMac(remoteId)) return null;
    return ParsedQr(
      remoteId: remoteId,
      token: parts.length > 1 ? parts.sublist(1).join('|') : null,
    );
  }

  static bool _isValidMac(String mac) {
    final re = RegExp(r'^([0-9A-Fa-f]{2}:){5}[0-9A-Fa-f]{2}$');
    return re.hasMatch(mac);
  }
}