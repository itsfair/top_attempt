import 'package:flutter/material.dart';
import 'package:top_attempt_local_client/top_attempt_client.dart';

import '../main.dart';

/// View-only profile page: the mirrored person data of the site admin
/// (member row). Editing happens in the end-user app (link intentionally
/// hidden until the sync design is agreed, see the local frontend
/// AGENTS.md).
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  LocalAdminInfo? _info;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadInfo();
  }

  Future<void> _loadInfo() async {
    try {
      final info = await client.siteSetup.adminInfo();
      if (!mounted) return;
      setState(() => _info = info);
    } on ServerpodClientException catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final info = _info;
    if (info == null && _error == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final fullName = [
      info?.adminFirstName,
      info?.adminLastName,
    ].where((part) => part?.isNotEmpty == true).map((part) => part!).join(' ');

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Mein Profil',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          if (_error != null)
            Text(
              'Laden fehlgeschlagen: $_error',
              style: const TextStyle(color: Colors.redAccent),
            ),
          if (info != null) ...[
            const SizedBox(height: 8),
            Center(
              child: CircleAvatar(
                radius: 48,
                foregroundImage:
                    info.adminImageUrl == null || info.adminImageUrl!.isEmpty
                    ? null
                    : NetworkImage(info.adminImageUrl!),
                child:
                    (info.adminImageUrl == null || info.adminImageUrl!.isEmpty)
                    ? const Icon(Icons.person_outline, size: 44)
                    : null,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              fullName.isEmpty ? '(kein Name im Profil)' : fullName,
              style: const TextStyle(fontSize: 16),
            ),
            if (info.adminBirthday case final birthday?)
              Text('Geburtstag: ${_formatDate(birthday)}'),
            if (info.adminEmail case final email?) Text('E-Mail: $email'),
          ],
        ],
      ),
    );
  }

  String _formatDate(final DateTime dateTime) {
    return '${dateTime.day.toString().padLeft(2, '0')}.'
        '${dateTime.month.toString().padLeft(2, '0')}.${dateTime.year}';
  }
}
