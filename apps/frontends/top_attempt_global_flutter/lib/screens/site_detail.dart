import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:top_attempt_global_client/top_attempt_client.dart';

import '../main.dart';

/// Detail view of a site: address data, first admin, status. The generated
/// secrets are never shown here (handed over once at creation; the initial
/// password is cleared globally after the first successful connection of
/// the local instance).
class SiteDetailScreen extends StatefulWidget {
  final int siteId;

  const SiteDetailScreen({super.key, required this.siteId});

  @override
  State<SiteDetailScreen> createState() => _SiteDetailScreenState();
}

class _SiteDetailScreenState extends State<SiteDetailScreen> {
  Site? _site;
  bool _loading = true;
  String? _firstAdminDisplay;

  @override
  void initState() {
    super.initState();
    _loadSite();
  }

  Future<void> _loadSite() async {
    setState(() {
      _loading = true;
    });
    try {
      final site = await client.sitesAdmin.getSite(siteId: widget.siteId);
      if (!mounted) return;
      setState(() => _site = site);
      final admin = await client.usersAdmin.getUser(
        authUserId: site.firstAdminId,
      );
      if (!mounted) return;
      setState(
        () => _firstAdminDisplay =
            admin.email ?? admin.fullName ?? '(ohne E-Mail)',
      );
    } on ServerpodClientException catch (e) {
      if (!mounted) return;
      showAdaptiveDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Laden fehlgeschlagen'),
          content: Text('$e'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                context.go('/sites');
              },
              child: const Text('Zur Liste'),
            ),
          ],
        ),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_site?.name ?? 'Site'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/sites'),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    final site = _site!;
    final registered = site.status == SiteSetupStatus.registered;

    return RefreshIndicator(
      onRefresh: _loadSite,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(site.name, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          Chip(
            label: Text(
              registered
                  ? 'Registriert'
                  : 'Einrichtung ausstehend (lokale Instanz fehlt)',
            ),
            avatar: Icon(
              registered
                  ? Icons.check_circle_outline
                  : Icons.pending_actions_outlined,
            ),
          ),
          // Per-site WS-connectivity status (via lastSeenAt heartbeats) is a
          // Stage 2 To-do and will be shown here/in the list.
          const SizedBox(height: 16),
          Text(
            '${site.street}\n'
            '${site.zipCode} ${site.city}\n'
            '${site.country}',
          ),
          const SizedBox(height: 8),
          Text('Firmenmail: ${site.companyEmail}'),
          const SizedBox(height: 16),
          Text(
            'Erster Site-Admin',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          Text(
            _firstAdminDisplay ?? '(Site-Admin wird geladen…)',
          ),
          const SizedBox(height: 16),
          const Card(
            child: Padding(
              padding: EdgeInsets.all(12),
              child: Text(
                'Einrichtungsgeheimnisse sind einmalig übermittelt und werden '
                'nicht erneut angezeigt. Nach der Registrierung der lokalen '
                'Instanz und der Übertragung des Admin-Initialpassworts '
                'werden beide Geheimnisse serverseitig vernichtet.',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
