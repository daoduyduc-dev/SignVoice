import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/favorites_provider.dart';

/// User favorites screen
class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FavoritesProvider>().loadFavorites();
    });
  }

  @override
  Widget build(BuildContext context) {
    final favoritesProvider = context.watch<FavoritesProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Yêu thích'),
      ),
      body: RefreshIndicator(
        onRefresh: () => favoritesProvider.loadFavorites(),
        child: favoritesProvider.isLoading
            ? const Center(child: CircularProgressIndicator())
            : favoritesProvider.errorMessage != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Lỗi: ${favoritesProvider.errorMessage}'),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => favoritesProvider.loadFavorites(),
                          child: const Text('Thử lại'),
                        ),
                      ],
                    ),
                  )
                : favoritesProvider.favorites.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.favorite_border,
                                size: 64, color: Colors.grey[400]),
                            const SizedBox(height: 16),
                            Text(
                              'Chưa có mục yêu thích',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 8),
                            const Text('Hãy thêm từ yêu thích để xem ở đây'),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: favoritesProvider.favorites.length,
                        itemBuilder: (context, index) {
                          final favorite = favoritesProvider.favorites[index];
                          final entry = favorite.entry;

                          if (entry == null) {
                            return const SizedBox.shrink();
                          }

                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              title: Text(entry.word),
                              subtitle: Text(
                                entry.definition,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete_outline,
                                    color: Colors.red),
                                onPressed: () => _confirmRemove(
                                  context,
                                  entry.id,
                                  entry.word,
                                ),
                              ),
                              onTap: () => Navigator.pushNamed(
                                context,
                                '/dictionary/${entry.id}',
                              ),
                            ),
                          );
                        },
                      ),
      ),
    );
  }

  void _confirmRemove(BuildContext context, String entryId, String word) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa yêu thích'),
        content: Text('Bạn có chắc muốn xóa "$word" khỏi danh sách yêu thích?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<FavoritesProvider>().removeFavorite(entryId);
            },
            child: const Text('Xóa', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
