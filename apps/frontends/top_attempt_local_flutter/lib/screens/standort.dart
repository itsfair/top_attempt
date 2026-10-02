import 'package:flutter/material.dart';
// Exports SiteConnectionState and LocalAdminInfo.
import 'package:top_attempt_local_client/top_attempt_client.dart';

import '../main.dart';

/// "Standort" page: the full snapshot of the enrolled site (fetched at
/// enrollment) plus the live connection state. Editing these properties
/// locally (with global propagation) is a TODO — see the local backend
/// AGENTS.md.
class StandortScreen extends StatefulWidget {
  const StandortScreen({super.key});

  @override
  State<StandortScreen> createState() => _StandortScreenState();
}

class _StandortScreenState extends State<StandortScreen> {
  LocalAdminInfo? _info;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadInfo();
  }

  Future<void> _loadInfo() async {
    try {
      final info = await client.siteSetup.adminInfo();
      if (!mounted) return;
      setState(() => _info = info);
    } on ServerpodClientException catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final info = _info;
    if (info == null && _error == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Standort',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          if (_error != null)
            Text(
              'Laden fehlgeschlagen: $_error',
              style: const TextStyle(color: Colors.redAccent),
            ),
          if (info != null) ...[
            const SizedBox(height: 8),
            _connectionChip(info),
            const SizedBox(height: 16),
            ..._siteLines(info),
            if (info.connectionError != null)
              Text(
                'Verbindungsfehler: ${info.connectionError}',
                style: const TextStyle(color: Colors.redAccent),
              ),
          ],
        ],
      ),
    );
  }

  Widget _connectionChip(final LocalAdminInfo info) {
    final String label;
    final Color color;
    switch (info.connectionState) {
      case SiteConnectionState.connected:
        label = 'Verbunden';
        color = Colors.green;
      case SiteConnectionState.reconnecting:
        label = 'Wiederverbinden…';
        color = Colors.orange;
      case SiteConnectionState.needsReSetup:
        label = 'Neu einrichten!';
        color = Colors.red;
      case SiteConnectionState.connecting:
        label = 'Verbinde…';
        color = Colors.orange;
      case SiteConnectionState.failure:
        label = 'Fehler';
        color = Colors.red;
      case SiteConnectionState.noneSetup:
        label = 'Noch nicht eingerichtet';
        color = Colors.blueGrey;
    }
    return Chip(
      avatar: Icon(Icons.circle, size: 14, color: color),
      label: Text(label, style: const TextStyle(color: Colors.black87)),
    );
  }

  Widget propertyLine(final String label, final Object? value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            TextSpan(text: ' ${value ?? "-"}'),
          ],
        ),
      ),
    );
  }

  List<Widget> _siteLines(final LocalAdminInfo info) => [
    propertyLine('ID', info.siteId),
    propertyLine('Name', info.siteName),
    propertyLine('Straße', info.siteStreet),
    propertyLine('PLZ', info.siteZipCode),
    propertyLine('Stadt', info.siteCity),
    propertyLine('Land', info.siteCountry),
    propertyLine('Firmenmail', info.siteCompanyEmail),
    if (info.lastConnectedAt case final lastConnected?)
      propertyLine('Letzte Aktivität', _formatDate(lastConnected)),
  ];

  String _formatDate(final DateTime dateTime) {
    return '${dateTime.day.toString().padLeft(2, '0')}.'
        '${dateTime.month.toString().padLeft(2, '0')}.${dateTime.year}';
  }
}
