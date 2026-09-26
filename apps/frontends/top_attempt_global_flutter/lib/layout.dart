import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:serverpod_auth_idp_flutter/serverpod_auth_idp_flutter.dart';
import 'package:top_attempt_shared/widgets/account_dropdown.dart';

import 'main.dart';

/// Shell layout of the global admin app.
///
/// The account dropdown comes from `apps/frontends/shared`
/// (`AccountDropdown`) and is consumed identically by the
/// `top_attempt_enduser_flutter` app — changes apply to both.
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
          AccountDropdown(
            profileState: profileState,
            isSignedIn: _isSignedIn,
            onLogin: (context) => context.go('/sign-in'),
            onLogout: () => client.auth.signOutDevice(),
            onProfile: (context) => context.go('/profile'),
            onSignedOut: () {
              if (mounted) context.go('/');
            },
          ),
        ],
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
