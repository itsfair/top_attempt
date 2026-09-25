import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:top_attempt_global_client/top_attempt_client.dart';

import '../main.dart';

/// Dialog to create a site: address data + choice of the first site admin
/// (from existing global users). On success returns [CreatedSiteInfo] to
/// the caller; the secrets are then displayed once in the onboarding modal.
class CreateSiteDialog extends StatefulWidget {
  const CreateSiteDialog({super.key});

  @override
  State<CreateSiteDialog> createState() => _CreateSiteDialogState();
}

class _CreateSiteDialogState extends State<CreateSiteDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _streetController = TextEditingController();
  final _zipCodeController = TextEditingController();
  final _cityController = TextEditingController();
  final _countryController = TextEditingController();
  final _emailController = TextEditingController();
  final _adminSearchController = TextEditingController();

  AdminUserSummary? _selectedAdmin;
  List<AdminUserSummary> _adminCandidates = [];
  bool _searchingAdmins = false;
  bool _saving = false;
  String? _error;

  Future<void> _searchAdmins(String value) {
    setState(() => _searchingAdmins = true);
    return client.usersAdmin
        .listUsers(query: value.trim(), offset: 0, limit: 25)
        .then(
          (page) {
            if (!mounted) return;
            setState(() => _adminCandidates = page.items);
          },
          onError: (Object e) {
            if (!mounted) return;
            setState(() => _error = 'Admin-Suche fehlgeschlagen: $e');
          },
        )
        .whenComplete(() {
          if (mounted) setState(() => _searchingAdmins = false);
        });
  }

  void _onAdminSearchChanged(String value) {
    final text = value.trim();
    Future.delayed(const Duration(milliseconds: 300), () {
      if (text == _adminSearchController.text.trim()) {
        _searchAdmins(text);
      }
    });
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final admin = _selectedAdmin;
    if (admin == null) {
      setState(
        () => _error = 'Bitte einen Site-Admin auswählen.',
      );
      return;
    }

    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final info = await client.sitesAdmin.createSite(
        name: _nameController.text,
        street: _streetController.text,
        zipCode: _zipCodeController.text,
        city: _cityController.text,
        country: _countryController.text,
        companyEmail: _emailController.text,
        firstAdminId: admin.authUserId,
      );
      if (!mounted) return;
      Navigator.of(context, rootNavigator: true).pop(info);
    } on ServerpodClientException catch (e) {
      if (!mounted) return;
      setState(() => _error = 'Anlegen fehlgeschlagen: $e');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog.fullscreen(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Site anlegen'),
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () =>
                Navigator.of(context, rootNavigator: true).pop(null),
          ),
        ),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Pflichtfeld' : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _streetController,
                decoration: const InputDecoration(labelText: 'Straße/Nr.'),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Pflichtfeld' : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _zipCodeController,
                decoration: const InputDecoration(labelText: 'PLZ'),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Pflichtfeld' : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _cityController,
                decoration: const InputDecoration(labelText: 'Stadt'),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Pflichtfeld' : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _countryController,
                decoration: const InputDecoration(labelText: 'Land'),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Pflichtfeld' : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Firmenmail'),
                keyboardType: TextInputType.emailAddress,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Pflichtfeld' : null,
              ),
              const SizedBox(height: 24),
              Text(
                'Erster Site-Admin',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _adminSearchController,
                decoration: const InputDecoration(
                  hintText: 'Suche (E-Mail oder Name)',
                  prefixIcon: Icon(Icons.person_search),
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                onChanged: _onAdminSearchChanged,
              ),
              if (_selectedAdmin != null) ...[
                const SizedBox(height: 8),
                ChipWithDelete(
                  user: _selectedAdmin!,
                  onDelete: () => setState(() => _selectedAdmin = null),
                ),
              ],
              if (_adminCandidates.isNotEmpty) ...[
                const SizedBox(height: 8),
                ..._adminCandidates.map(
                  (user) => ListTile(
                    leading: Icon(
                      _selectedAdmin?.authUserId == user.authUserId
                          ? Icons.radio_button_checked
                          : Icons.radio_button_unchecked,
                    ),
                    title: Text(
                      user.fullName?.isNotEmpty == true
                          ? user.fullName!
                          : (user.email ?? '(ohne E-Mail)'),
                    ),
                    subtitle: Text(user.email ?? ''),
                    onTap: () => setState(() => _selectedAdmin = user),
                  ),
                ),
              ],
              if (_searchingAdmins)
                const Padding(
                  padding: EdgeInsets.all(8),
                  child: LinearProgressIndicator(),
                ),
              if (_error != null) ...[
                const SizedBox(height: 8),
                Text(
                  _error!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ],
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _saving ? null : _save,
                child: _saving
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Site anlegen'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ChipWithDelete extends StatelessWidget {
  final AdminUserSummary user;
  final VoidCallback onDelete;

  const ChipWithDelete({super.key, required this.user, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return InputChip(
      label: Text(user.email ?? 'Benutzer'),
      onDeleted: onDelete,
      deleteIcon: const Icon(Icons.clear),
    );
  }
}

/// Shown once right after site creation: the two generated secrets. Neither
/// can be retrieved afterwards (the initial password is delivered once to
/// the local instance at first connect, then cleared; the one-time password
/// burns on enrollment). Stage 2 To-do: email delivery as an alternative.
class OnboardingSecretsDialog extends StatefulWidget {
  final CreatedSiteInfo info;

  const OnboardingSecretsDialog({super.key, required this.info});

  @override
  State<OnboardingSecretsDialog> createState() =>
      _OnboardingSecretsDialogState();
}

class _OnboardingSecretsDialogState extends State<OnboardingSecretsDialog> {
  bool _acknowledged = false;

  Future<void> _copy(String label, String value) async {
    await Clipboard.setData(ClipboardData(text: value));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$label kopiert')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Einrichtung — nur einmal sichtbar'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Diese Werte werden nie mehr angezeigt. '
            'Jetzt kopieren und sicher für die Einrichtung der lokalen '
            'Instanz aufbewahren.',
          ),
          const SizedBox(height: 16),
          ListTile(
            title: const Text('Einmalpasswort (lokale Instanz)'),
            subtitle: Text(widget.info.oneTimePassword ?? '-'),
            trailing: IconButton(
              icon: const Icon(Icons.copy),
              onPressed: () =>
                  _copy('Einmalpasswort', widget.info.oneTimePassword ?? ''),
            ),
          ),
          ListTile(
            title: Text('Initiales Passwort (Site-Admin)'),
            subtitle: Text(widget.info.initialAdminPassword ?? '-'),
            trailing: IconButton(
              icon: const Icon(Icons.copy),
              onPressed: () => _copy(
                'Initiales Passwort',
                widget.info.initialAdminPassword ?? '',
              ),
            ),
          ),
        ],
      ),
      actions: [
        CheckboxListTile(
          value: _acknowledged,
          onChanged: (v) => setState(() => _acknowledged = v ?? false),
          title: const Text('Ich habe beide Werte sicher gespeichert.'),
        ),
        FilledButton(
          onPressed: _acknowledged ? () => Navigator.of(context).pop() : null,
          child: const Text('Weiter zur Site'),
        ),
      ],
    );
  }
}
