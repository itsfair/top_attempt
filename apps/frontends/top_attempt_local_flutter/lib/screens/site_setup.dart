import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:top_attempt_local_client/top_attempt_client.dart';

import '../main.dart';

/// Site setup mask: enter the site admin's **global credentials** to enroll
/// this local instance at the global backend (also fixes its recovery
/// path — no global-admin involvement needed when credentials die).
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
  String? _error;
  String? _successMessage;

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() {
      _enrolling = true;
      _error = null;
      _successMessage = null;
    });
    final messenger = ScaffoldMessenger.of(context);
    try {
      final result = await client.siteSetup.enterSetup(
        email: _emailController.text.trim(),
        password: _passwordController.text,
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

      // The local backend finished: persisted enrollment + admin transfer.
      _successMessage =
          'Erfolgreich eingerichtet als Site "${result.siteName ?? ''}".';
      _requiresSiteSelection = false;
      _candidates = const [];
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            'Einrichtung gespeichert. Die lokale Instanz verbindet sich '
            'nun bei jedem Start mit der globalen Instanz.',
          ),
        ),
      );
      if (context.mounted) context.go('/');
    } on ServerpodClientException catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text('Setup fehlgeschlagen: $e')),
      );
      if (!mounted) return;
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _enrolling = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Site-Einrichtung'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Text(
                'Einrichtung (Enrollment)',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 4),
              const Text(
                'Diese Einrichtung verifiziert die lokale Instanz bei der '
                'globalen Instanz mit den globalen Anmeldedaten des Site-'
                'Admins (der Nutzer, der bei der Site-Anlage ausgewählt '
                'wurde). Damit werden Member-Daten übernommen und die '
                'Verbindung steht ab jetzt auch nach Neustarts wieder.',
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
              const SizedBox(height: 8),
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
                Text(
                  'Site wählen',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                ..._candidates.map(
                  (candidate) => ListTile(
                    leading: Icon(
                      _selectedSiteId == candidate.siteId
                          ? Icons.radio_button_checked
                          : Icons.radio_button_unchecked,
                    ),
                    title: Text(candidate.siteName),
                    onTap: () => setState(
                      () => _selectedSiteId = candidate.siteId,
                    ),
                  ),
                ),
              ],
              if (_error != null) ...[
                const SizedBox(height: 8),
                Text(
                  'Laden fehlgeschlagen: $_error',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
              ],
              if (_successMessage != null) ...[
                const SizedBox(height: 8),
                Text(
                  'Setup erfolgreich.',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
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
    );
  }
}
