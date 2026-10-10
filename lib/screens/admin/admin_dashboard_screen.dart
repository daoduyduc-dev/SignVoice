import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/admin_provider.dart';

/// Admin dashboard screen
class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().loadStats();
    });
  }

  @override
  Widget build(BuildContext context) {
    final adminProvider = context.watch<AdminProvider>();
    final stats = adminProvider.stats;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản trị hệ thống'),
      ),
      body: RefreshIndicator(
        onRefresh: () => adminProvider.loadStats(),
        child: adminProvider.isLoading && stats == null
            ? const Center(child: CircularProgressIndicator())
            : adminProvider.errorMessage != null && stats == null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Lỗi: ${adminProvider.errorMessage}'),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => adminProvider.loadStats(),
                          child: const Text('Thử lại'),
                        ),
                      ],
                    ),
                  )
                : ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      Text(
                        'Thống kê hệ thống',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 16),

                      // User stats
                      if (stats != null) ...[
                        _StatCard(
                          title: 'Người dùng',
                          items: [
                            _StatItem('Tổng số', stats.users.total.toString()),
                            _StatItem('Hoạt động', stats.users.active.toString()),
                            _StatItem('Đình chỉ', stats.users.suspended.toString()),
                            _StatItem('Khách', stats.users.guests.toString()),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Content stats
                        _StatCard(
                          title: 'Nội dung',
                          items: [
                            _StatItem('Tổng số', stats.content.total.toString()),
                            _StatItem('Đã xuất bản', stats.content.published.toString()),
                            _StatItem('Chờ duyệt', stats.content.pending.toString()),
                            _StatItem('Đã lưu trữ', stats.content.archived.toString()),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Session stats
                        _StatCard(
                          title: 'Phiên đăng nhập',
                          items: [
                            _StatItem('Tổng số', stats.sessions.total.toString()),
                            _StatItem('Đang hoạt động', stats.sessions.active.toString()),
                          ],
                        ),
                      ],
                      const SizedBox(height: 24),

                      // Quick actions
                      Text(
                        'Thao tác nhanh',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 12),
                      Card(
                        child: Column(
                          children: [
                            ListTile(
                              leading: const Icon(Icons.people),
                              title: const Text('Quản lý người dùng'),
                              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                              onTap: () => Navigator.pushNamed(context, '/admin/users'),
                            ),
                            const Divider(height: 1),
                            ListTile(
                              leading: const Icon(Icons.pending_actions),
                              title: const Text('Xét duyệt nội dung'),
                              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                              onTap: () => Navigator.pushNamed(context, '/admin/content'),
                            ),
                            const Divider(height: 1),
                            ListTile(
                              leading: const Icon(Icons.category),
                              title: const Text('Quản lý danh mục'),
                              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                              onTap: () => Navigator.pushNamed(context, '/admin/categories'),
                            ),
                            const Divider(height: 1),
                            ListTile(
                              leading: const Icon(Icons.devices),
                              title: const Text('Quản lý phiên'),
                              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                              onTap: () => Navigator.pushNamed(context, '/admin/sessions'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final List<_StatItem> items;

  const _StatCard({
    required this.title,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            ...items.map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(item.label),
                      Text(
                        item.value,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }
}

class _StatItem {
  final String label;
  final String value;

  _StatItem(this.label, this.value);
}
