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
          _chipFor(site),
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
          if (site.lastSeenAt != null) ...[
            const SizedBox(height: 8),
            Text(
              'Letzte Aktivität: ${_dateTimeText(site.lastSeenAt!)}',
            ),
          ],
          const SizedBox(height: 16),
          const Card(
            child: Padding(
              padding: EdgeInsets.all(12),
              child: Text(
                'Einrichtung vor Ort: Der Site-Admin gibt in der lokalen '
                'Admin-App seine globalen Anmeldedaten ein — daraus entsteht '
                'der lokale Admin-Login (gleiches Passwort) und die '
                'gesicherte Verbindung wird hergestellt. Keine Secrets hier.',
              ),
            ),
          ),
          const SizedBox(height: 8),
          if (registered)
            OutlinedButton(
              onPressed: _revokeConnection,
              child: const Text('Verbindung widerrufen'),
            ),
        ],
      ),
    );
  }

  /// Per-site connectivity chip state derived from the `lastSeenAt`
  /// heartbeats (device WS pings).
  Widget _chipFor(final Site site) {
    final registered = site.status == SiteSetupStatus.registered;
    if (!registered) {
      return const Chip(
        avatar: Icon(Icons.pending_actions_outlined),
        label: Text('Einrichtung ausstehend (lokale Instanz fehlt)'),
      );
    }

    final lastSeen = site.lastSeenAt;
    if (lastSeen == null) {
      return const Chip(
        avatar: Icon(Icons.wifi_off, color: Colors.red),
        label: Text('Registriert — noch nie gesehen'),
      );
    }

    final offlineFor = DateTime.now().difference(lastSeen);
    if (offlineFor <= const Duration(seconds: 90)) {
      return const Chip(
        avatar: Icon(Icons.wifi, color: Colors.green),
        label: Text('Verbunden'),
      );
    }

    return Chip(
      avatar: const Icon(Icons.wifi_off, color: Colors.red),
      label: Text(
        'Offline seit ${_durationText(offlineFor)}',
      ),
    );
  }

  String _durationText(final Duration duration) {
    if (duration.inHours >= 24) return '${duration.inDays} Tag(e)';
    if (duration.inMinutes >= 60) return '${duration.inHours} Std.';
    return '${duration.inMinutes} Min.';
  }

  String _dateTimeText(final DateTime dateTime) {
    return '${dateTime.day.toString().padLeft(2, '0')}.'
        '${dateTime.month.toString().padLeft(2, '0')}.${dateTime.year} '
        '${dateTime.hour.toString().padLeft(2, '0')}:'
        '${dateTime.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _revokeConnection() async {
    final site = _site;
    if (site == null) return;

    showAdaptiveDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Verbindung widerrufen?'),
        content: const Text(
          'Die lokale Instanz verliert ihre Geräte-Anmeldung und muss die '
          'Einrichtung vor Ort mit globalen Anmeldedaten des Site-Admins '
          'wiederherstellen. Die Site selbst bleibt erhalten.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Abbrechen'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await client.sitesAdmin.revokeSiteConnection(
                siteId: site.id!,
              );
              await _loadSite();
            },
            child: const Text('Widerrufen'),
          ),
        ],
      ),
    );
  }
}
