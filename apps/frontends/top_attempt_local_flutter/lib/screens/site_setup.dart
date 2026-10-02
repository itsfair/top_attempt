import 'package:flutter/material.dart';
import 'package:top_attempt_local_client/top_attempt_client.dart';

import '../main.dart';

/// Site setup mask: enroll this instance at its site's global instance by
/// verifying with the **global credentials of the site admin** (the user
/// chosen at site creation). On success, the connection is persisted and
/// the shell redirect lands on the local login screen.
class SiteSetupScreen extends StatefulWidget {
  const SiteSetupScreen({super.key});

  @override
  State<SiteSetupScreen> createState() => _SiteSetupScreenState();
}

class _SiteSetupScreenState extends State<SiteSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  int? _selectedSiteId;
  List<SiteCandidateLocal> _candidates = const [];
  bool _requiresSiteSelection = false;
  bool _enrolling = false;

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _enrolling = true);
    final messenger = ScaffoldMessenger.of(context);
    try {
      final result = await client.siteSetup.enterSetup(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        // Site picker only after the first hint-result.
        siteId: _requiresSiteSelection ? _selectedSiteId : null,
      );

      if (!mounted) return;
      if (result.requiresSiteSelection) {
        setState(() {
          _requiresSiteSelection = true;
          _candidates = result.candidates;
          _selectedSiteId =
              _selectedSiteId ??
              (result.candidates.isNotEmpty
                  ? result.candidates.first.siteId
                  : null);
        });
        return;
      }

      messenger.showSnackBar(
        SnackBar(
          content: Text(
            'Einrichtung erfolgreich ("${result.siteName ?? ''}"'
            '). Jetzt mit denselben Zugangsdaten lokal anmelden.',
          ),
        ),
      );
      // The shell's connectionStateNotifier updates via polling and the
      // redirect lands on /sign-in.
    } on ServerpodClientException catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text('Setup fehlgeschlagen: $e')),
      );
    } finally {
      if (mounted) setState(() => _enrolling = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        margin: const EdgeInsets.all(24),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Site-Einrichtung (Enrollment)',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Diese Maske verifiziert die lokale Instanz bei der '
                  'globalen Instanz mit den globalen Anmeldedaten des '
                  'Site-Admins (der Nutzer, der bei der Site-Anlage '
                  'ausgewählt wurde). Members-Daten werden übernommen und '
                  'ab jetzt stellt sich die Verbindung bei jedem Start '
                  'selbst wieder her.',
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Globale E-Mail',
                    prefixIcon: Icon(Icons.mail_outline),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Pflichtfeld' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(
                    labelText: 'Globales Passwort',
                    prefixIcon: Icon(Icons.password),
                  ),
                  obscureText: true,
                  validator: (v) =>
                      (v == null || v.isEmpty) ? 'Pflichtfeld' : null,
                ),
                if (_requiresSiteSelection) ...[
                  const SizedBox(height: 16),
                  const Text(
                    'Site wählen',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  ..._candidates.map(
                    (candidate) => ListTile(
                      leading: Icon(
                        _selectedSiteId == candidate.siteId
                            ? Icons.radio_button_checked
                            : Icons.radio_button_unchecked,
                      ),
                      title: Text(candidate.siteName),
                      onTap: () =>
                          setState(() => _selectedSiteId = candidate.siteId),
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: _enrolling ? null : _submit,
                  child: _enrolling
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Verbinden'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
