import 'package:top_attempt_global_client/top_attempt_client.dart';
import 'package:flutter/material.dart';
import 'package:serverpod_flutter/serverpod_flutter.dart';
import 'package:serverpod_auth_idp_flutter/serverpod_auth_idp_flutter.dart';
import 'package:go_router/go_router.dart';

import 'layout.dart';

import 'screens/greetings_screen.dart';
import 'screens/sign_in.dart';
import 'screens/forbidden.dart';
import 'screens/sites.dart';
import 'screens/site_detail.dart';
import 'screens/members.dart';
import 'screens/member_detail.dart';

/// Sets up a global client object that can be used to talk to the server from
/// anywhere in our app. The client is generated from your server code
/// and is set up to connect to a Serverpod running on a local server on
/// the default port. You will need to modify this to connect to staging or
/// production servers.
/// In a larger app, you may want to use the dependency injection of your choice
/// instead of using a global client object. This is just a simple example.
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
  // defaults to http://$localhost:8080/ if not found.
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
    refreshListenable: client.auth.authInfoListenable,
    redirect: (context, state) {
      final location = state.matchedLocation;
      if (!client.auth.isAuthenticated && location != '/sign-in') {
        return '/sign-in';
      } else if (client.auth.isAuthenticated &&
          client.auth.authInfo?.scopeNames.contains('global-admin') != true) {
        return '/forbidden';
      } else {
        return null;
      }
    },
    routes: [
      ShellRoute(
        builder: (context, state, child) {
          return Layout(child: child);
        },
        routes: <RouteBase>[
          GoRoute(
            path: '/',
            builder: (context, state) => const GreetingsScreen(),
          ),
          GoRoute(
            path: '/sign-in',
            builder: (context, state) => SignIn(),
          ),
          GoRoute(
            path: '/forbidden',
            builder: (context, state) => const Forbidden(),
          ),
          GoRoute(
            path: '/members',
            builder: (context, state) => const MembersScreen(),
          ),
          GoRoute(
            path: '/members/:authUserId',
            builder: (context, state) => MemberDetailScreen(
              authUserId: state.pathParameters['authUserId']!,
            ),
          ),
          GoRoute(
            path: '/sites',
            builder: (context, state) => const SitesScreen(),
          ),
          GoRoute(
            path: '/sites/:siteId',
            builder: (context, state) => SiteDetailScreen(
              siteId: int.parse(state.pathParameters['siteId']!),
            ),
          ),
        ],
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Global Admin UI',
      theme: ThemeData(primarySwatch: Colors.blue),
      routerConfig: _router,
    );
  }
}
