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
                                  : Icons.check_circle_outline,
                            ),
                            title: Text(site.name),
                            subtitle: Text(
                              '${site.zipCode} ${site.city} · '
                              '${site.companyEmail}',
                            ),
                            trailing: Chip(
                              label: Text(
                                site.status == SiteSetupStatus.pendingSetup
                                    ? 'Setup offen'
                                    : 'Registriert',
                              ),
                            ),
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

  Future<void> _openCreateDialog() async {
    final created = await showDialog<CreatedSiteInfo>(
      context: context,
      barrierDismissible: false,
      builder: (context) => const CreateSiteDialog(),
    );
    if (created == null || !mounted) return;

    // The secrets are shown exactly once, directly after creation.
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => OnboardingSecretsDialog(info: created),
    );
    if (mounted) {
      context.go('/sites/${created.siteId}');
    }
  }
}
