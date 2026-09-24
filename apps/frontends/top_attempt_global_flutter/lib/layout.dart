import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:serverpod_auth_idp_flutter/serverpod_auth_idp_flutter.dart';

import 'main.dart';

class Layout extends StatefulWidget {
  final Widget child;

  const Layout({required this.child, super.key});

  @override
  State<Layout> createState() => _LayoutState();
}

class _LayoutState extends State<Layout> {
  bool _isSignedIn = false;
  @override
  void initState() {
    super.initState();
    client.auth.authInfoListenable.addListener(_updateAuthState);
    _updateAuthState();
  }

  @override
  void dispose() {
    client.auth.authInfoListenable.removeListener(_updateAuthState);
    super.dispose();
  }

  void _updateAuthState() {
    setState(() {
      _isSignedIn = client.auth.isAuthenticated;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
        backgroundColor: Colors.blue[900],
        foregroundColor: Colors.white,
        actions: [
          if (_isSignedIn)
            IconButton(
              icon: const Icon(Icons.logout),
              tooltip: 'Abmelden',
              onPressed: () async {
                client.auth.signOutDevice();
                context.go('/');
              },
            )
          else
            IconButton(
              icon: const Icon(Icons.login),
              tooltip: 'Anmelden',
              onPressed: () => context.go('/sign-in'),
            ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue
              ),
              child: Text(
                'Navigation',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
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
              leading: const Icon(Icons.people),
              title: const Text('Members'),
              onTap: () {
                context.go('/members');
              },
            ),
            ListTile(
              leading: const Icon(Icons.location_city),
              title: const Text('Sites'),
              onTap: () {
                context.go('/sites');
              },
            ),
          ],
        ),
      ),
      body: widget.child,
    );
  }
}