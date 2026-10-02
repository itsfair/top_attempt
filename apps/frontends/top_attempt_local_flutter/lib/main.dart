import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:serverpod_flutter/serverpod_flutter.dart';
import 'package:serverpod_auth_idp_flutter/serverpod_auth_idp_flutter.dart';
import 'package:top_attempt_local_client/top_attempt_client.dart';

import 'layout.dart';
import 'screens/profile.dart';
import 'screens/site_setup.dart';
import 'screens/sign_in.dart';
import 'screens/standort.dart';

/// Sets up a local client object that can be used to talk to the server from
/// anywhere in our app. The client is generated from your server code
/// and is set up to connect to a Serverpod running on a local server on
/// the default port. You will need to modify this to connect to staging or
/// production servers.
late final Client client;

late String serverUrl;

/// Local mirror of the device-connection setup state: the shell polls
/// `siteSetup.connectionStatus` and updates this notifier, so the
/// GoRouter redirect re-evaluates after enrollments/connectivity changes.
final ValueNotifier<SiteConnectionState> connectionStateNotifier =
    ValueNotifier(SiteConnectionState.noneSetup);

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

  await client.auth.initialize();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final GoRouter _router = GoRouter(
    initialLocation: '/',
    refreshListenable: Listenable.merge([
      client.auth.authInfoListenable,
      connectionStateNotifier,
    ]),
    redirect: (context, state) {
      final location = state.matchedLocation;
      final enrolled =
          connectionStateNotifier.value != SiteConnectionState.noneSetup;
      final signedIn = client.auth.isAuthenticated;

      // Not enrolled at a global instance yet -> setup screen.
      if (!enrolled && location != '/setup') {
        return '/setup';
      }

      // Enrolled but not locally signed in -> login screen
      // (first enrollment creates the local login account).
      if (enrolled && !signedIn && location != '/sign-in') {
        return '/sign-in';
      }

      // Signed in users don't need the login/setup screens.
      if (signedIn && (location == '/sign-in' || location == '/setup')) {
        return '/';
      }

      return null;
    },
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
            path: '/standort',
            builder: (context, state) => const StandortScreen(),
          ),
          GoRoute(
            path: '/profile',
            builder: (context, state) => const ProfileScreen(),
          ),
          GoRoute(
            path: '/setup',
            builder: (context, state) => const SiteSetupScreen(),
          ),
          GoRoute(
            path: '/sign-in',
            builder: (context, state) => const LocalSignInScreen(),
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
