import 'dart:async';

import 'package:flutter/material.dart';

import '../profile_state.dart';

/// Account dropdown for the AppBar: avatar with the profile image (or
/// initials) plus a popup menu (Profil / Einstellungen / Logout) and a
/// login button when signed out.
///
/// Lives in `apps/frontends/shared` and is consumed by the end-user app
/// and the global admin app identically — changes here apply to both.
///
/// App-specific behaviour is injected: [onLogin] (navigation on the
/// login button), [onLogout] (the host performs the REAL sign-out,
/// `client.auth.signOutDevice()`), [onProfile]/[onSettings] (shown as
/// "not implemented" snack bars when null).
class AccountDropdown extends StatelessWidget {
  /// Shared profile state of the signed-in user.
  final ProfileState profileState;

  /// Whether the user is signed in (drives login button vs. menu).
  final bool isSignedIn;

  /// Called when the login button is tapped (host navigates).
  final void Function(BuildContext context)? onLogin;

  /// Performs the actual sign-out, e.g. `client.auth.signOutDevice()`.
  /// The widget awaits it, then clears [profileState] and calls
  /// [onSignedOut].
  final Future<void> Function()? onLogout;

  /// Called for the "Profil" menu entry; shows a "not implemented" snack
  /// bar passim when null.
  final void Function(BuildContext context)? onProfile;

  /// Called for the "Einstellungen" menu entry; shows a "not implemented"
  /// snack bar passim when null.
  final void Function(BuildContext context)? onSettings;

  /// Called after signing out (host app navigates where it wants).
  final void Function()? onSignedOut;

  const AccountDropdown({
    required this.profileState,
    required this.isSignedIn,
    this.onLogin,
    this.onLogout,
    this.onProfile,
    this.onSettings,
    this.onSignedOut,
    super.key,
  });

  String? _initials(final ProfileState profileState) {
    final fullName = profileState.profile?.fullName?.trim();
    if (fullName == null || fullName.isEmpty) return null;
    return fullName
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .map((part) => part[0].toUpperCase())
        .take(2)
        .join();
  }

  Future<void> _signOut() async {
    await onLogout?.call();
    // Immediate local state clear; the host's auth listener re-asserts
    // this when `authInfoListenable` fires after the device sign-out.
    profileState.reset();
    onSignedOut?.call();
  }

  void _handleSelection(final BuildContext context, final String value) {
    switch (value) {
      case 'profil':
        final handler = onProfile;
        if (handler != null) {
          handler(context);
          break;
        }
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profilverwaltung ist hier noch nicht implementiert'),
          ),
        );
      case 'einstellungen':
        final handler = onSettings;
        if (handler != null) {
          handler(context);
          break;
        }
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Einstellungen sind noch nicht implementiert'),
          ),
        );
      case 'logout':
        unawaited(_signOut());
    }
  }

  Widget _build(BuildContext context) {
    // Signed-out users only get the login button (host-injected
    // navigation).
    if (!isSignedIn) {
      return IconButton(
        icon: const Icon(Icons.login),
        tooltip: 'Anmelden',
        onPressed: () => onLogin?.call(context),
      );
    }

    return ListenableBuilder(
      listenable: profileState,
      builder: (context, _) {
        final imageUrl = profileState.profile?.imageUrl;
        final initials = _initials(profileState);

        return PopupMenuButton<String>(
          tooltip: 'Konto',
          offset: const Offset(0, kToolbarHeight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          onSelected: (value) => _handleSelection(context, value),
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
                  backgroundColor: Theme.of(
                    context,
                  ).colorScheme.primaryContainer,
                  foregroundColor: Theme.of(
                    context,
                  ).colorScheme.onPrimaryContainer,
                  foregroundImage: imageUrl == null
                      ? null
                      : NetworkImage(imageUrl.toString()),
                  child: imageUrl != null
                      ? null
                      : initials != null
                      ? Text(
                          initials,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        )
                      : const Icon(Icons.person_outline, size: 18),
                ),
                const Icon(Icons.arrow_drop_down),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(final BuildContext context) => _build(context);
}
