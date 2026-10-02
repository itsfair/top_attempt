import 'dart:async';

import 'package:flutter/material.dart';

/// One injectable menu entry for [AccountDropdown]. Hosts supply their
/// app-specific items (e.g. the local app's "Standort"); each item
/// carries its own handler.
class AccountMenuItem {
  /// Stable value used as the popup item value.
  final String value;

  /// Human readable title.
  final String title;

  /// Leading icon.
  final IconData icon;

  /// Host-injected handler, receives the widget's [BuildContext].
  final void Function(BuildContext context) onTap;

  const AccountMenuItem({
    required this.value,
    required this.title,
    required this.icon,
    required this.onTap,
  });

  PopupMenuItem<String> toPopupItem() {
    return PopupMenuItem<String>(
      value: value,
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Icon(icon),
        title: Text(title),
      ),
    );
  }
}

/// Account dropdown for the AppBar: avatar with the profile image (or
/// initials) plus a popup menu (standard items Profil / Einstellungen /
/// Logout, plus host-injected [extraItems]) and a login button when
/// signed out.
///
/// Lives in `apps/frontends/shared` and is consumed by the end-user app,
/// the global admin app and the local admin app — changes here apply to
/// all of them.
///
/// App-specific behaviour is injected: [onLogin] (navigation on the
/// login button), [onLogout] (the host performs the REAL sign-out,
/// `client.auth.signOutDevice()` — MUST be wired), [onProfile]/
/// [onSettings] (shown as "not implemented" snack bars when null).
/// Data (image/initials) is passed in as plain fields, so each host can
/// source it from whatever state it uses.
class AccountDropdown extends StatelessWidget {
  /// Whether the user is signed in (drives login button vs. menu).
  final bool isSignedIn;

  /// Full name of the user; initial letters are used as avatar fallback
  /// ([fullName] null/empty or [imageUrl] present → person icon).
  final String? fullName;

  /// Image URL shown inside the avatar; an URV/URI string.
  final String? imageUrl;

  /// Host-injected additional entries (e.g. the local app's "Standort").
  final List<AccountMenuItem> extraItems;

  /// Whether the standard "Logout" entry is shown (local app keeps no
  /// local session flag before its login story lands).
  final bool showLogout;

  /// Called when the login button is tapped (host navigates).
  final void Function(BuildContext context)? onLogin;

  /// Performs the actual sign-out, e.g. `client.auth.signOutDevice()`.
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
    required this.isSignedIn,
    required this.extraItems,
    this.fullName,
    this.imageUrl,
    this.showLogout = true,
    this.onLogin,
    this.onLogout,
    this.onProfile,
    this.onSettings,
    this.onSignedOut,
    super.key,
  });

  String? get _initials {
    final trimmed = fullName?.trim();
    if (trimmed == null || trimmed.isEmpty) return null;
    return trimmed
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .map((part) => part[0].toUpperCase())
        .take(2)
        .join();
  }

  Future<void> _signOut() async {
    await onLogout?.call();
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
      default:
        final item = extraItems
            .where((item) => item.value == value)
            .firstOrNull;
        item?.onTap(context);
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

    return PopupMenuButton<String>(
      tooltip: 'Konto',
      offset: const Offset(0, kToolbarHeight),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
        ...extraItems.map((item) => item.toPopupItem()),
        if (showLogout) ...[
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
      ],
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 15,
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
              foregroundImage: imageUrl == null
                  ? null
                  : NetworkImage(imageUrl!),
              child: imageUrl != null
                  ? null
                  : _initials != null
                  ? Text(
                      _initials!,
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
  }

  @override
  Widget build(final BuildContext context) => _build(context);
}
