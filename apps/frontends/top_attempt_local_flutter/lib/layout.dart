import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:top_attempt_local_client/top_attempt_client.dart';

import 'main.dart';

/// Shell layout of the site admin app: drawer navigation + AppBar with the
/// per-site connection chip (polled from the local backend).
class Layout extends StatefulWidget {
  final Widget child;

  const Layout({required this.child, super.key});

  @override
  State<Layout> createState() => _LayoutState();
}

class _LayoutState extends State<Layout> {
  SiteConnectionInfo? _status;
  String? _error;
  Timer? _pollTimer;

  @override
  void initState() {
    super.initState();
    _refreshStatus();
    _pollTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      _refreshStatus();
    });
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  Future<void> _refreshStatus() async {
    try {
      final status = await client.siteSetup.connectionStatus();
      if (!mounted) return;
      setState(() {
        _status = status;
        _error = null;
      });
      connectionStateNotifier.value = status.state;
    } on ServerpodClientException catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
    }
  }

  void _goTo(final String location) {
    context.go(location);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
        backgroundColor: Colors.blue[900],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.location_city),
            tooltip: 'Standort',
            onPressed: () => _goTo('/standort'),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(44),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: _error != null
                ? Text(
                    'Status-Abfrage fehlgeschlagen: $_error',
                    style: const TextStyle(color: Colors.redAccent),
                  )
                : _buildChip(),
          ),
        ),
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Text(
                'Navigation',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Home'),
              onTap: () => _goTo('/'),
            ),
            ListTile(
              leading: const Icon(Icons.location_city),
              title: const Text('Standort'),
              onTap: () => _goTo('/standort'),
            ),
            ListTile(
              leading: const Icon(Icons.person_outline),
              title: const Text('Profil'),
              onTap: () => _goTo('/profile'),
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Site-Einrichtung'),
              onTap: () => _goTo('/setup'),
            ),
          ],
        ),
      ),
      body: widget.child,
    );
  }

  Widget _buildChip() {
    final state = _status?.state;
    final String label;
    final Color color;
    switch (state) {
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
      default:
        label = '—';
        color = Colors.blueGrey;
    }
    return Chip(
      avatar: Icon(Icons.circle, size: 14, color: color),
      label: Text(label, style: const TextStyle(color: Colors.black87)),
    );
  }
}

/// Home: overview page (devices/members follow in later stages).
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Start page (device management in a later stage)'),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () => context.go('/standort'),
            icon: const Icon(Icons.location_city),
            label: const Text('Standort'),
          ),
        ],
      ),
    );
  }
}
