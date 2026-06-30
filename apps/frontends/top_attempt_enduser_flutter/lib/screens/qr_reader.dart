import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

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
          if (value != null) {
            setState(() => _detected = true);
            debugPrint('QR Code: $value');
            Future.delayed(const Duration(seconds: 2), () {
              if (mounted) setState(() => _detected = false);
            });
          }
        },
      ),
    );
  }
}
