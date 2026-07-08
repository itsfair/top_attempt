import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import 'ble_constants.dart';

enum BleTestPhase {
  idle,
  connecting,
  subscribing,
  writing,
  awaitingResponse,
  disconnecting,
  done,
  error,
}

class BleTestSessionResult {
  final BleTestPhase finalPhase;
  final String? responseJson;
  final String? errorMessage;

  BleTestSessionResult({
    required this.finalPhase,
    this.responseJson,
    this.errorMessage,
  });

  Map<String, dynamic>? get response {
    if (responseJson == null) return null;
    try {
      return jsonDecode(responseJson!) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }
}

typedef BleTestPhaseListener = void Function(BleTestPhase phase, String detail);

class BleTestSession {
  final String remoteId;
  final String? token;
  final String deviceId;
  final BleTestPhaseListener? onPhase;

  BluetoothDevice? _device;
  StreamSubscription<List<int>>? _notifySub;

  BleTestSession({
    required this.remoteId,
    this.token,
    required this.deviceId,
    this.onPhase,
  });

  Future<BleTestSessionResult> run() async {
    try {
      return await _runInternal();
    } catch (e, st) {
      debugPrint('BleTestSession error: $e\n$st');
      return BleTestSessionResult(
        finalPhase: BleTestPhase.error,
        errorMessage: '$e',
      );
    } finally {
      await _cleanup();
    }
  }

  Future<BleTestSessionResult> _runInternal() async {
    _emit(BleTestPhase.connecting, 'Verbinde mit $remoteId ...');
    _device = BluetoothDevice.fromId(remoteId);
    try {
      await _device!.connect(
        autoConnect: false,
        timeout: BleConstants.connectTimeout,
      );
    } catch (e) {
      return BleTestSessionResult(
        finalPhase: BleTestPhase.error,
        errorMessage: 'Connect fehlgeschlagen: $e',
      );
    }

    _emit(BleTestPhase.subscribing, 'Services/Characteristics entdecken ...');
    List<BluetoothService> services;
    try {
      services = await _device!.discoverServices();
    } catch (e) {
      return BleTestSessionResult(
        finalPhase: BleTestPhase.error,
        errorMessage: 'Service Discovery fehlgeschlagen: $e',
      );
    }

    final service = services.firstWhere(
      (s) => s.serviceUuid.toString().toLowerCase() == BleConstants.serviceUuid,
      orElse: () => throw Exception('DoorInterface-Service nicht gefunden'),
    );
    final reqChar = service.characteristics.firstWhere(
      (c) =>
          c.characteristicUuid.toString().toLowerCase() ==
          BleConstants.requestCharUuid,
      orElse: () => throw Exception('Request-Characteristic nicht gefunden'),
    );
    final resChar = service.characteristics.firstWhere(
      (c) =>
          c.characteristicUuid.toString().toLowerCase() ==
          BleConstants.responseCharUuid,
      orElse: () => throw Exception('Response-Characteristic nicht gefunden'),
    );

    final completer = Completer<String>();
    _notifySub = resChar.onValueReceived.listen((value) {
      if (!completer.isCompleted) {
        completer.complete(utf8.decode(value, allowMalformed: true));
      }
    });
    _emit(
      BleTestPhase.subscribing,
      'Subscribe auf Response-Characteristic ...',
    );
    await resChar.setNotifyValue(true);

    final request = jsonEncode({
      'action': 'test',
      'credential': token ?? '',
      'deviceId': deviceId,
    });
    _emit(BleTestPhase.writing, 'Sende Request: $request');
    await reqChar.write(utf8.encode(request), withoutResponse: false);

    _emit(
      BleTestPhase.awaitingResponse,
      'Warte auf Notify (Timeout ${BleConstants.responseTimeout.inSeconds}s) ...',
    );
    String responseJson;
    try {
      responseJson = await completer.future.timeout(
        BleConstants.responseTimeout,
      );
    } catch (e) {
      return BleTestSessionResult(
        finalPhase: BleTestPhase.error,
        errorMessage: 'Keine Antwort vom ESP: $e',
      );
    }
    _emit(
      BleTestPhase.disconnecting,
      'Antwort empfangen, trenne Verbindung ...',
    );

    return BleTestSessionResult(
      finalPhase: BleTestPhase.done,
      responseJson: responseJson,
    );
  }

  Future<void> _cleanup() async {
    final dev = _device;
    try {
      await _notifySub?.cancel();
    } catch (_) {}
    _notifySub = null;
    if (dev != null && dev.isConnected) {
      try {
        await dev.disconnect();
      } catch (_) {}
    }
  }

  void _emit(BleTestPhase phase, String detail) {
    debugPrint('[BleTestSession] ${phase.name}: $detail');
    onPhase?.call(phase, detail);
  }
}
