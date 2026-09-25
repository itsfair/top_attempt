import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:serverpod_flutter/serverpod_flutter.dart';
import 'package:top_attempt_local_client/top_attempt_client.dart';
import 'package:serverpod_auth_idp_flutter/serverpod_auth_idp_flutter.dart';

import 'screens/site_setup.dart';

/// Sets up a local client object that can be used to talk to the server from
/// anywhere in our app. The client is generated from your server code
/// and is set up to connect to a Serverpod running on a local server on
/// the default port. You will need to modify this to connect to staging or
/// production servers.
late final Client client;

late String serverUrl;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // When you are running the app on a physical device, you need to set the
  // server URL to the IP address of your computer. You can find the IP
  // address by running `ipconfig` on Windows or `ifconfig` on Mac/Linux.
  //
  // You can set the variable when running or building your app like this:
  // E.g. `flutter run --dart-define=SERVER_URL=https://api.example.com/`.
  //
  // Otherwise, the server URL is fetched from the assets/config.json file or
  // defaults to http://$localhost:8180/ if not found.
  final serverUrl = await getServerUrl();

  client = Client(serverUrl)
    ..connectivityMonitor = FlutterConnectivityMonitor()
    ..authSessionManager = FlutterAuthSessionManager();

    client.auth.initialize();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final GoRouter _router = GoRouter(
    routes: [
      ShellRoute(
        builder: (context, state, child) {
          return Layout(child: child);
        },
        routes: <RouteBase>[
          GoRoute(
            path: '/',
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: '/setup',
            builder: (context, state) => const SiteSetupScreen(),
          ),
        ],
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Site Admin UI',
      theme: ThemeData(primarySwatch: Colors.blue),
      routerConfig: _router,
    );
  }
}

/// Shell layout with the connection chip (polls the local backend).
class Layout extends StatefulWidget {
  final Widget child;

  const Layout({required this.child, super.key});

  @override
  State<Layout> createState() => _LayoutState();
}

class _LayoutState extends State<Layout> {
  SiteConnectionInfo? _status;
  Timer? _timer;
  String? _error;

  @override
  void initState() {
    super.initState();
    _refreshStatus();
    _timer = Timer.periodic(const Duration(seconds: 10), (_) {
      _refreshStatus();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
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
    } on ServerpodClientException catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
    }
  }

  Widget _chipForStatus() {
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
        label = 'Not set up yet';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Home"),
        backgroundColor: Colors.blue[900],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Site-Einrichtung',
            onPressed: () => context.go('/setup'),
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
                : _chipForStatus(),
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
              onTap: () {
                context.go('/');
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Site-Einrichtung'),
              onTap: () {
                context.go('/setup');
              },
            ),
          ],
        ),
      ),
      body: widget.child,
    );
  }
}

/// Home: overview state page (devices/members come in follow-up stages).
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Start page (Devices in a subsequent stage)'),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () => context.go('/setup'),
            icon: const Icon(Icons.settings),
            label: const Text('Einrichtung'),
          ),
        ],
      ),
    );
  }
}
