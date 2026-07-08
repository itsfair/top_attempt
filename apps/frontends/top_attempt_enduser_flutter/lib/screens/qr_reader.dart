import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../ble/ble_constants.dart';

class QRReader extends StatefulWidget {
  const QRReader({super.key});

  @override
  State<QRReader> createState() => _QRReaderState();
}

class _QRReaderState extends State<QRReader> {
  final MobileScannerController _controller = MobileScannerController();
  bool _detected = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: MobileScanner(
        controller: _controller,
        onDetect: (capture) {
          if (_detected) return;
          final value = capture.barcodes.firstOrNull?.rawValue;
          if (value == null) return;
          setState(() => _detected = true);
          debugPrint('QR Code: $value');
          final parsed = ParsedQr.tryParse(value);
          if (parsed == null) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('QR nicht DoorInterface-Format: $value'),
                ),
              );
            }
            Future.delayed(const Duration(seconds: 2), () {
              if (mounted) setState(() => _detected = false);
            });
            return;
          }
          context.go(
            '/ble-test',
            extra: {
              'remoteId': parsed.remoteId,
              if (parsed.token != null) 'token': parsed.token,
            },
          );
        },
      ),
    );
  }
}
