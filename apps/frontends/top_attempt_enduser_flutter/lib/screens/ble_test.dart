import 'dart:convert';

import 'package:flutter/material.dart';

import '../ble/ble_test_session.dart';

class BleTestScreen extends StatefulWidget {
  final String remoteId;
  final String? token;

  const BleTestScreen({required this.remoteId, this.token, super.key});

  @override
  State<BleTestScreen> createState() => _BleTestScreenState();
}

class _BleTestScreenState extends State<BleTestScreen> {
  BleTestPhase _phase = BleTestPhase.idle;
  String _detail = '';
  String? _responseJsonRaw;
  String? _error;
  bool _finished = false;

  @override
  void initState() {
    super.initState();
    _startSession();
  }

  Future<void> _startSession() async {
    final deviceId = 'flutter-enduser';
    final session = BleTestSession(
      remoteId: widget.remoteId,
      token: widget.token,
      deviceId: deviceId,
      onPhase: (phase, detail) {
        if (mounted) {
          setState(() {
            _phase = phase;
            _detail = detail;
            if (phase == BleTestPhase.awaitingResponse) {
              _responseJsonRaw = null;
            }
          });
        }
      },
    );
    final result = await session.run();
    if (!mounted) return;
    setState(() {
      _error = result.errorMessage;
      _phase = result.finalPhase;
      _responseJsonRaw = result.responseJson;
      _finished = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BLE-Verbindungstest'),
        backgroundColor: Colors.blue[900],
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            _infoRow('Ziel (Remote ID)', widget.remoteId),
            if (widget.token != null) _infoRow('Token', widget.token!),
            _infoRow('Phase', _phase.name),
            const SizedBox(height: 16),
            if (_phase != BleTestPhase.done && _phase != BleTestPhase.error)
              const LinearProgressIndicator(),
            if (_detail.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(_detail, style: Theme.of(context).textTheme.bodyMedium),
            ],
            const SizedBox(height: 24),
            if (_responseJsonRaw != null) ...[
              Text(
                'Antwort (ESP):',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SelectableText(
                  _formatJson(_responseJsonRaw!),
                  style: const TextStyle(
                    fontFeatures: [],
                    fontFamily: 'monospace',
                  ),
                ),
              ),
            ],
            if (_error != null) ...[
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SelectableText(_error!),
              ),
            ],
            const SizedBox(height: 24),
            if (_finished)
              FilledButton(
                onPressed: () => Navigator.of(context).maybePop(),
                child: const Text('Zurück'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  String _formatJson(String raw) {
    try {
      final decoded = jsonDecode(raw);
      return const JsonEncoder.withIndent('  ').convert(decoded);
    } catch (_) {
      return raw;
    }
  }
}
