import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:top_attempt_global_client/top_attempt_client.dart';

import '../main.dart';

/// Number of users loaded per page (mirrors UsersAdminEndpoint.pageSize).
const int _pageSize = 50;

/// Lists all users of the global instance and allows filtering.
///
/// Loads the newest [_pageSize] users first; a button at the end of the list
/// fetches more (same for filtered views). If there are more users than
/// loaded, an info banner tells how many are still missing.
class MembersScreen extends StatefulWidget {
  const MembersScreen({super.key});

  @override
  State<MembersScreen> createState() => _MembersScreenState();
}

class _MembersScreenState extends State<MembersScreen> {
  final TextEditingController _searchController = TextEditingController();

  List<AdminUserSummary> _items = [];
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
      final page = await client.usersAdmin.listUsers(
        query: _query,
        offset: 0,
        limit: _pageSize,
      );
      if (!mounted) return;
      setState(() {
        _items = page.items;
        _total = page.total;
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
      final page = await client.usersAdmin.listUsers(
        query: _query,
        offset: _items.length,
        limit: _pageSize,
      );
      if (!mounted) return;
      setState(() {
        _items.addAll(page.items);
        _total = page.total;
      });
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
    // Debounce: only search once typing pauses a moment.
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

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    hintText: 'Suche nach E-Mail oder Name',
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
                'Es gibt $_total Nutzer, ${_items.length} geladen — '
                'weitere laden oder Suche verfeinern.',
                style: theme.textTheme.bodySmall,
              ),
            ),
          Expanded(
            child: _items.isEmpty
                ? const Center(child: Text('Keine Nutzer gefunden.'))
                : ListView.builder(
                    itemCount: _items.length,
                    itemBuilder: (context, index) {
                      final user = _items[index];
                      return Card(
                        child: ListTile(
                          leading: Icon(
                            user.blocked ? Icons.block : Icons.person_outline,
                          ),
                          title: Text(
                            user.fullName?.isNotEmpty == true
                                ? user.fullName!
                                : (user.email ?? '(ohne E-Mail)'),
                          ),
                          subtitle: Text(user.email ?? ''),
                          trailing: Wrap(
                            spacing: 4,
                            children: [
                              if (user.scopeNames.contains('global-admin'))
                                const Chip(label: Text('admin')),
                              if (user.blocked)
                                const Chip(label: Text('gesperrt')),
                            ],
                          ),
                          onTap: () =>
                              context.go('/members/${user.authUserId.uuid}'),
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
    );
  }
}
