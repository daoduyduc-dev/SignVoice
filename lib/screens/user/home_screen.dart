import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/dictionary_provider.dart';
import '../../providers/history_provider.dart';

/// User home/dashboard screen
class UserHomeScreen extends StatefulWidget {
  const UserHomeScreen({super.key});

  @override
  State<UserHomeScreen> createState() => _UserHomeScreenState();
}

class _UserHomeScreenState extends State<UserHomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DictionaryProvider>().loadPopularEntries(limit: 5);
      context.read<HistoryProvider>().loadHistory();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final dictionaryProvider = context.watch<DictionaryProvider>();
    final historyProvider = context.watch<HistoryProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('SignVoice'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => Navigator.pushNamed(context, '/dictionary/search'),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await Future.wait([
            dictionaryProvider.loadPopularEntries(limit: 5),
            historyProvider.loadHistory(),
          ]);
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Greeting
            Text(
              'Xin chào, ${authProvider.user?.displayName ?? "Bạn"}!',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 24),

            // Quick actions
            Row(
              children: [
                Expanded(
                  child: _QuickActionCard(
                    icon: Icons.book,
                    label: 'Từ điển',
                    onTap: () => Navigator.pushNamed(context, '/dictionary'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _QuickActionCard(
                    icon: Icons.favorite,
                    label: 'Yêu thích',
                    onTap: () => Navigator.pushNamed(context, '/favorites'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _QuickActionCard(
                    icon: Icons.category,
                    label: 'Danh mục',
                    onTap: () => Navigator.pushNamed(context, '/categories'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _QuickActionCard(
                    icon: Icons.history,
                    label: 'Lịch sử',
                    onTap: () => Navigator.pushNamed(context, '/history'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Popular entries
            Text(
              'Từ phổ biến',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            if (dictionaryProvider.isLoading)
              const Center(child: CircularProgressIndicator())
            else if (dictionaryProvider.entries.isEmpty)
              const Center(child: Text('Chưa có dữ liệu'))
            else
              ...dictionaryProvider.entries.map((entry) => Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      title: Text(entry.word),
                      subtitle: Text(
                        entry.definition,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () => Navigator.pushNamed(
                        context,
                        '/dictionary/${entry.id}',
                      ),
                    ),
                  )),
            const SizedBox(height: 24),

            // Recent history
            if (historyProvider.history.isNotEmpty) ...[
              Text(
                'Xem gần đây',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              ...historyProvider.history.take(5).map((historyEntry) {
                final entry = historyEntry.entry;
                if (entry == null) return const SizedBox.shrink();
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    title: Text(entry.word),
                    subtitle: Text(
                      entry.definition,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () => Navigator.pushNamed(
                      context,
                      '/dictionary/${entry.id}',
                    ),
                  ),
                );
              }),
            ],
          ],
        ),
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(icon, size: 32),
              const SizedBox(height: 8),
              Text(label, textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}
