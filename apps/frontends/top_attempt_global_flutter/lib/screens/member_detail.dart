import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:serverpod_auth_idp_flutter/serverpod_auth_idp_flutter.dart';
import 'package:top_attempt_global_client/top_attempt_client.dart';

import '../main.dart';

/// Editor for a single user: toggles the `global-admin` scope and the
/// blocked status. Saving calls the backend, which revokes the user's
/// tokens so the change becomes effective immediately.
class MemberDetailScreen extends StatefulWidget {
  final String authUserId;

  const MemberDetailScreen({super.key, required this.authUserId});

  @override
  State<MemberDetailScreen> createState() => _MemberDetailScreenState();
}

class _MemberDetailScreenState extends State<MemberDetailScreen> {
  AdminUserSummary? _user;
  bool _isAdmin = false;
  bool _isBlocked = false;
  bool _loading = true;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final uuid = UuidValue.fromString(widget.authUserId);
      final user = await client.usersAdmin.getUser(authUserId: uuid);
      if (!mounted) return;
      setState(() {
        _user = user;
        _isAdmin = user.scopeNames.contains('global-admin');
        _isBlocked = user.blocked;
      });
    } on ServerpodClientException catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
    } on FormatException {
      if (!mounted) return;
      setState(() => _error = 'Ungültige Benutzer-ID: ${widget.authUserId}');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _save() async {
    final user = _user;
    if (user == null) return;
    setState(() => _saving = true);
    final messenger = ScaffoldMessenger.of(context);
    try {
      // Self-protection mirrors the backend: an admin can neither revoke
      // their own global-admin scope nor change their own blocked state
      // (both would lock themselves out with no way back through this
      // endpoint). Catch it in the UI directly, so the error is readable
      // instead of a backend roundtrip exception.
      final isSelf = client.auth.authInfo?.authUserId == user.authUserId;

      if (isSelf && !_isAdmin && user.scopeNames.contains('global-admin')) {
        messenger.showSnackBar(
          const SnackBar(
            content: Text(
              'Die eigene Global-Admin-Rolle kann nicht hier entzogen '
              'werden. Nutze ein zweites Admin-Konto oder ein DB-Update.',
            ),
          ),
        );
        setState(() {
          _isAdmin = true;
          _saving = false;
        });
        return;
      }

      if (isSelf && _isBlocked != user.blocked) {
        messenger.showSnackBar(
          const SnackBar(
            content: Text(
              'Die eigene Sperre kann hier nicht geändert werden. '
              'Dafür ist ein zweites Admin-Konto nötig.',
            ),
          ),
        );
        setState(() => _isBlocked = user.blocked);
      }

      final scopeChanged = _isAdmin != user.scopeNames.contains('global-admin');
      final blockedChanged = _isBlocked != user.blocked;

      if (!scopeChanged && !blockedChanged) {
        setState(() => _saving = false);
        return;
      }

      if (scopeChanged) {
        final result = await client.usersAdmin.setGlobalAdmin(
          authUserId: user.authUserId,
          isGlobalAdmin: _isAdmin,
        );
        if (!mounted) return;
        setState(() => _user = result);
      }
      if (blockedChanged) {
        await client.usersAdmin.setBlocked(
          authUserId: user.authUserId,
          blocked: _isBlocked,
        );
      }

      if (!mounted) return;
      if (scopeChanged || blockedChanged) {
        messenger.showSnackBar(
          const SnackBar(
            content: Text(
              'Gespeichert — laufende Sessions des Nutzers wurden beendet.',
            ),
          ),
        );
      }
      if (context.mounted) context.go('/members');
    } on ServerpodClientException catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text('Speichern fehlgeschlagen: $e')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_user?.email ?? 'Benutzer'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/members'),
        ),
      ),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Laden fehlgeschlagen: $_error',
                style: TextStyle(color: Theme.of(context).colorScheme.error),
                textAlign: TextAlign.center,
              ),
            ),
            OutlinedButton(
              onPressed: _loadUser,
              child: const Text('Erneut laden'),
            ),
            OutlinedButton(
              onPressed: () => context.go('/members'),
              child: const Text('Zur Liste'),
            ),
          ],
        ),
      );
    }

    final user = _user!;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('E-Mail: ${user.email ?? '(ohne)'}'),
          Text('Name: ${user.fullName ?? '(ohne)'}'),
          Text('ID: ${user.authUserId.uuid}'),
          Text('Erstellt: ${_formatDate(user.createdAt)}'),
          if (user.scopeNames.contains('global-admin'))
            const Padding(
              padding: EdgeInsets.only(top: 4),
              child: Chip(label: Text('global admin')),
            ),
          const Divider(height: 32),
          SwitchListTile(
            title: const Text('Global Admin'),
            subtitle: const Text(
              'Vergibt/entfernt den Scope global-admin. '
              'Laufende Sessions des Nutzers werden beendet.',
            ),
            value: _isAdmin,
            onChanged: _saving ? null : (v) => setState(() => _isAdmin = v),
          ),
          SwitchListTile(
            title: const Text('Gesperrt'),
            subtitle: const Text(
              'Gesperrte Nutzer können sich nicht mehr anmelden; '
              'laufende Sessions werden beendet.',
            ),
            value: _isBlocked,
            onChanged: _saving ? null : (v) => setState(() => _isBlocked = v),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _saving ? null : _save,
            child: _saving
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Speichern'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.'
        '${date.month.toString().padLeft(2, '0')}.${date.year}';
  }
}
