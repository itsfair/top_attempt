import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../main.dart';

/// Login screen of the site admin app — hand-written email/password form
/// (no Serverpod SignInWidget: local self-registration is intentionally
/// disabled, so the widget's sign-up affordances must not appear).
class LocalSignInScreen extends StatefulWidget {
  const LocalSignInScreen({super.key});

  @override
  State<LocalSignInScreen> createState() => _LocalSignInScreenState();
}

class _LocalSignInScreenState extends State<LocalSignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _signingIn = false;

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _signingIn = true);
    final messenger = ScaffoldMessenger.of(context);
    try {
      // Password login against the LOCAL backend's email IdP
      // (registration is off — accounts are created by enrollment only).
      await client.emailIdp.login(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      if (!mounted) return;
      messenger.showSnackBar(
        const SnackBar(content: Text('Angemeldet.')),
      );
      if (context.mounted) context.go('/');
    } on FormatException catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text('Anmelden fehlgeschlagen: $e')),
      );
    } finally {
      if (mounted) setState(() => _signingIn = false);
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
                  'Anmelden',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'E-Mail',
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
                    labelText: 'Passwort',
                    prefixIcon: Icon(Icons.password),
                  ),
                  obscureText: true,
                  validator: (v) =>
                      (v == null || v.isEmpty) ? 'Pflichtfeld' : null,
                  onFieldSubmitted: (_) => _submit(),
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: _signingIn ? null : _submit,
                  child: _signingIn
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Anmelden'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
