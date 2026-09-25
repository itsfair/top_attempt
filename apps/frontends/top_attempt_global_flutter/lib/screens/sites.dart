import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:top_attempt_global_client/top_attempt_client.dart';

import '../main.dart';
import 'create_site_dialog.dart';

/// Number of sites loaded per page (mirrors SitesAdminEndpoint.pageSize).
const int _pageSize = 50;

/// Lists all sites ("Betriebe"); a floating action button opens the
/// create-site flow (details + first site admin, returns the one-time
/// setup token and the local admin's initial password — shown once).
/// Connectivity display per site (WS status) is a Stage 2 To-do.
class SitesScreen extends StatefulWidget {
  const SitesScreen({super.key});

  @override
  State<SitesScreen> createState() => _SitesScreenState();
}

class _SitesScreenState extends State<SitesScreen> {
  final TextEditingController _searchController = TextEditingController();

  List<Site> _items = [];
  int _total = 0;
  bool _loading = false;
  bool _loadingMore = false;
  String? _error;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _loadFirstPage();
  }

  Future<void> _loadFirstPage() async {
    setState(() {
      _loading = true;
      _error = null;
      _items = [];
    });
    try {
      final items = await client.sitesAdmin.listSites(
        query: _query,
        offset: 0,
        limit: _pageSize,
      );
      final total = await client.sitesAdmin.countSites(query: _query);
      if (!mounted) return;
      setState(() {
        _items = items;
        _total = total;
      });
    } on ServerpodClientException catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _loadMore() async {
    setState(() => _loadingMore = true);
    try {
      final items = await client.sitesAdmin.listSites(
        query: _query,
        offset: _items.length,
        limit: _pageSize,
      );
      if (!mounted) return;
      setState(() => _items.addAll(items));
    } on ServerpodClientException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Laden fehlgeschlagen: $e')),
      );
    } finally {
      if (mounted) setState(() => _loadingMore = false);
    }
  }

  void _onSearchChanged(String value) {
    final text = value.trim();
    Future.delayed(const Duration(milliseconds: 300), () {
      if (text == _searchController.text.trim() && text != _query) {
        _query = text;
        _loadFirstPage();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasMore = _items.length < _total;

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add_business),
        label: const Text('Site anlegen'),
        onPressed: _openCreateDialog,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      hintText: 'Suche nach Name, E-Mail oder Stadt',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    onChanged: _onSearchChanged,
                  ),
                ),
                IconButton(
                  tooltip: 'Neu laden',
                  onPressed: _loading ? null : _loadFirstPage,
                  icon: const Icon(Icons.refresh),
                ),
              ],
            ),
          ),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.all(8),
              child: Text(
                'Laden fehlgeschlagen: $_error',
                style: TextStyle(color: theme.colorScheme.error),
              ),
            )
          else if (_loading)
            const Padding(
              padding: EdgeInsets.all(32),
              child: CircularProgressIndicator(),
            )
          else ...[
            if (hasMore)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Text(
                  'Es gibt $_total Sites, ${_items.length} geladen — '
                  'weitere laden oder Suche verfeinern.',
                  style: theme.textTheme.bodySmall,
                ),
              ),
            Expanded(
              child: _items.isEmpty
                  ? const Center(child: Text('Keine Sites gefunden.'))
                  : ListView.builder(
                      itemCount: _items.length,
                      itemBuilder: (context, index) {
                        final site = _items[index];
                        return Card(
                          child: ListTile(
                            leading: Icon(
                              site.status == SiteSetupStatus.pendingSetup
                                  ? Icons.business_outlined
                                  : site.status == SiteSetupStatus.registered
                                  ? Icons.wifi
                                  : Icons.check_circle_outline,
                            ),
                            title: Text(site.name),
                            subtitle: Text(
                              '${site.zipCode} ${site.city} · '
                              '${site.companyEmail}',
                            ),
                            trailing: _chipFor(site),
                            onTap: () => context.go('/sites/${site.id!}'),
                          ),
                        );
                      },
                    ),
            ),
            if (hasMore)
              Center(
                child: _loadingMore
                    ? const CircularProgressIndicator()
                    : Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: OutlinedButton(
                          onPressed: _loadMore,
                          child: Text('Weitere $_pageSize laden'),
                        ),
                      ),
              ),
          ],
        ],
      ),
    );
  }

  /// Per-site connection chip, derived from the local instance's
  /// `lastSeenAt` heartbeats (WS pings). Registered + fresh = connected;
  /// stale = offline; pendingSetup = no local instance yet. Live push
  /// (Serverpod message central) is a To-do — this polls.
  Widget _chipFor(final Site site) {
    if (site.status == SiteSetupStatus.pendingSetup) {
      return const Chip(
        avatar: Icon(Icons.pending_outlined, size: 16, color: Colors.blueGrey),
        label: Text('Setup offen'),
      );
    }

    final lastSeen = site.lastSeenAt;
    if (lastSeen == null) {
      return const Chip(
        avatar: Icon(Icons.wifi_off, size: 16, color: Colors.red),
        label: Text('Offline'),
      );
    }

    final offlineFor = DateTime.now().difference(lastSeen);
    if (offlineFor <= const Duration(seconds: 90)) {
      return const Chip(
        avatar: Icon(Icons.wifi, size: 16, color: Colors.green),
        label: Text('Verbunden'),
      );
    }

    return Chip(
      avatar: const Icon(Icons.wifi_off, size: 16, color: Colors.red),
      label: Text('Offline seit ${_shortDuration(offlineFor)}'),
    );
  }

  String _shortDuration(final Duration duration) {
    if (duration.inHours >= 24) return '${duration.inDays} d';
    if (duration.inMinutes >= 60) return '${duration.inHours} h';
    return '${duration.inMinutes} m';
  }

  Future<void> _openCreateDialog() async {
    final created = await showDialog<Site>(
      context: context,
      barrierDismissible: false,
      builder: (context) => const CreateSiteDialog(),
    );
    if (created == null || !mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Site angelegt. Die Einrichtung erfolgt vor Ort: der Site-Admin '
          'gibt dort seine globalen Anmeldedaten ein (keine Secrets nötig).',
        ),
      ),
    );
    context.go('/sites/${created.id!}');
  }
}
