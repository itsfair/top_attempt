import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:serverpod_auth_idp_flutter/serverpod_auth_idp_flutter.dart';
import 'package:top_attempt_shared/widgets/account_dropdown.dart';

import 'main.dart';

/// Shell layout of the end-user app.
///
/// The account dropdown comes from `apps/frontends/shared`
/// (`AccountDropdown`) and is consumed identically by the
/// `top_attempt_global_flutter` admin app — changes apply to both.
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
      body: widget.child,
      bottomNavigationBar: BottomAppBar(
        shape: CircularNotchedRectangle(),
        notchMargin: 6.0,
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            IconButton(
              icon: Icon(Icons.home),
              onPressed: () {
                context.go('/');
              },
            ),
            IconButton(
              icon: Icon(Icons.notifications),
              onPressed: () {},
            ),
            SizedBox(width: 40), // Platz für den FAB
            IconButton(
              icon: Icon(Icons.messenger),
              onPressed: () {},
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        shape: const CircleBorder(),
        onPressed: () {
          context.go('/qr-reader');
        },
        child: Icon(Icons.qr_code_scanner),
      ),
    );
  }
}
