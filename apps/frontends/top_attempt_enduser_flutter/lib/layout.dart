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
  String? _displayName;
  ImageProvider<Object>? _avatarImage;

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
      if (!_isSignedIn) {
        _displayName = null;
        _avatarImage = null;
      }
    });
  }

  String? get _initials {
    final name = _displayName?.trim();
    if (name == null || name.isEmpty) return null;
    return name
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .map((part) => part[0].toUpperCase())
        .take(2)
        .join();
  }

  void _showNotImplemented(String feature) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$feature ist noch nicht implementiert')),
    );
  }

  Future<void> _signOut() async {
    await client.auth.signOutDevice();
    if (mounted) context.go('/');
  }

  Widget _buildAccountAction(BuildContext context) {
    if (!_isSignedIn) {
      return IconButton(
        icon: const Icon(Icons.login),
        tooltip: 'Anmelden',
        onPressed: () => context.go('/sign-in'),
      );
    }

    final initials = _initials;
    return PopupMenuButton<String>(
      tooltip: 'Konto',
      offset: const Offset(0, kToolbarHeight),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onSelected: (value) {
        switch (value) {
          case 'profil':
            _showNotImplemented('Profil');
          case 'einstellungen':
            _showNotImplemented('Einstellungen');
          case 'logout':
            _signOut();
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem<String>(
          value: 'profil',
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.person_outline),
            title: Text('Profil'),
          ),
        ),
        const PopupMenuItem<String>(
          value: 'einstellungen',
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.settings_outlined),
            title: Text('Einstellungen'),
          ),
        ),
        const PopupMenuDivider(),
        const PopupMenuItem<String>(
          value: 'logout',
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.logout),
            title: Text('Logout'),
          ),
        ),
      ],
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 15,
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              foregroundImage: _avatarImage,
              child: _avatarImage == null && initials != null
                  ? Text(
                      initials,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    )
                  : Icon(
                      Icons.person_outline,
                      size: 18,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
            ),
            const Icon(Icons.arrow_drop_down),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
        backgroundColor: Colors.blue[900],
        foregroundColor: Colors.white,
        actions: [
          _buildAccountAction(context),
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
