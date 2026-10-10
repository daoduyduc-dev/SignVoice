import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/app_state.dart';
import '../../core/navigation.dart';
import '../../core/theme.dart';
import '../../widgets/ui.dart';
import '../../services/admin/admin_workspace_service.dart';
import '../../services/api/api_exception.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});
  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String query = '', filter = 'Tất cả';
  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final items = state.history.where((item) {
      final categoryMatches =
          filter == 'Tất cả' ||
          filter == 'Yêu thích' && item.favorite ||
          filter == 'Ký hiệu' &&
              item.direction == ConversationDirection.signToSpeech ||
          filter == 'Giọng nói' &&
              item.direction == ConversationDirection.speechToText;
      return categoryMatches &&
          item.content.toLowerCase().contains(query.toLowerCase());
    }).toList();
    return AppPage(
      title: 'Lịch sử hội thoại',
      showBack: false,
      tabIndex: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            decoration: const InputDecoration(
              hintText: 'Tìm kiếm hội thoại...',
              prefixIcon: Icon(Icons.search),
            ),
            onChanged: (v) => setState(() => query = v),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: ['Tất cả', 'Ký hiệu', 'Giọng nói', 'Yêu thích']
                .map(
                  (s) => ChoiceChip(
                    label: Text(s),
                    selected: filter == s,
                    onSelected: (_) => setState(() => filter = s),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 20),
          if (items.isEmpty)
            EmptyView(
              title: state.history.isEmpty
                  ? 'Chưa có lịch sử'
                  : 'Không tìm thấy kết quả',
              description: state.history.isEmpty
                  ? 'Bắt đầu một phiên dịch để ghi lại cuộc hội thoại.'
                  : 'Hãy thử từ khóa hoặc bộ lọc khác.',
              action: AppButton(
                'Bắt đầu phiên dịch',
                compact: true,
                onPressed: () => openRoot(context, 'S08'),
              ),
            ),
          for (final item in items) ...[
            AppCard(
              onTap: () {
                state.selectConversation(item);
                openScreen(context, 'S21');
              },
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SignVoiceBadge(
                          item.direction == ConversationDirection.signToSpeech
                              ? 'Ký hiệu'
                              : 'Giọng nói',
                          color:
                              item.direction ==
                                  ConversationDirection.signToSpeech
                              ? AppColors.blue
                              : AppColors.teal,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          item.content,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 8),
                        BodyText(item.time),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: item.favorite ? 'Bỏ yêu thích' : 'Yêu thích',
                    onPressed: () => state.toggleConversation(item),
                    icon: Icon(
                      item.favorite ? Icons.favorite : Icons.favorite_border,
                      color: item.favorite
                          ? AppColors.red
                          : Theme.of(context).colorScheme.outline,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }
}

class HistoryDetailScreen extends StatelessWidget {
  const HistoryDetailScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final item = state.selectedConversation;
    if (item == null) {
      return const AppPage(
        title: 'Chi tiết lịch sử',
        child: EmptyView(
          title: 'Không có bản ghi',
          description: 'Bản ghi đã được xóa hoặc chưa được lưu.',
        ),
      );
    }
    return AppPage(
      title: 'Chi tiết lịch sử',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SignVoiceBadge(
                  item.label,
                  color: item.direction == ConversationDirection.signToSpeech
                      ? AppColors.blue
                      : AppColors.teal,
                ),
                const SizedBox(height: 22),
                Heading(item.content, size: 26),
                const SizedBox(height: 22),
                const Divider(),
                BodyText(item.time),
                const SizedBox(height: 6),
                const BodyText('Nguồn: phiên dịch demo'),
              ],
            ),
          ),
          const SizedBox(height: 20),
          AppButton(
            'Phát giọng nói',
            secondary: true,
            icon: Icons.volume_up_outlined,
            onPressed: () {
              state.update(() {
                state.sentence.clear();
                state.sentence.add(
                  item.content.replaceFirst(RegExp(r'\.$'), ''),
                );
              });
              openScreen(context, 'S14');
            },
          ),
          const SizedBox(height: 10),
          AppButton(
            'Sao chép',
            outlined: true,
            icon: Icons.copy_outlined,
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: item.content));
              if (context.mounted) toast(context, 'Đã sao chép hội thoại.');
            },
          ),
          const SizedBox(height: 10),
          AppButton(
            item.favorite ? 'Bỏ yêu thích' : 'Thêm yêu thích',
            secondary: true,
            icon: item.favorite ? Icons.favorite : Icons.favorite_border,
            onPressed: () => state.toggleConversation(item),
          ),
          const SizedBox(height: 10),
          AppButton(
            'Xóa hội thoại',
            secondary: true,
            color: AppColors.red,
            icon: Icons.delete_outline,
            onPressed: () async {
              final approved = await confirm(
                context,
                title: 'Xóa hội thoại?',
                message: 'Bản ghi này sẽ được xóa khỏi dữ liệu demo.',
              );
              if (approved) {
                state.removeConversation(item.id);
                if (context.mounted) backOrHome(context);
              }
            },
          ),
        ],
      ),
    );
  }
}

class DictionaryScreen extends StatefulWidget {
  const DictionaryScreen({super.key, this.favoritesOnly = false});
  final bool favoritesOnly;
  @override
  State<DictionaryScreen> createState() => _DictionaryScreenState();
}

class _DictionaryScreenState extends State<DictionaryScreen> {
  String query = '', category = 'Tất cả';
  String? categoryId, error;
  int page = 1, pages = 1, _request = 0;
  bool loading = true;
  List<SignEntry> catalog = [];
  List<AdminRecord> topics = [];
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _load();
    });
  }

  Future<void> _load() async {
    final request = ++_request;
    final service = context.read<AdminWorkspaceService>();
    setState(() {
      loading = true;
      error = null;
    });
    try {
      final result = widget.favoritesOnly
          ? await service.favoriteEntries(AppScope.of(context).favorites)
          : await service.published(
              page: page,
              search: query,
              categoryId: categoryId,
            );
      final categories = await service.activeCategories();
      if (mounted && request == _request) {
        setState(() {
          topics = categories;
          pages = result.pages;
          catalog = result.items
              .map(
                (item) => SignEntry(
                  '${item['word']}',
                  item['categoryId'] is Map
                      ? '${item['categoryId']['name']}'
                      : 'Danh mục',
                  '${item['definition']}',
                  '${item['usageExample'] ?? ''}',
                  id: '${item['_id']}',
                  videoUrl: item['videoUrl'] as String?,
                  instructions: item['notes'] as String?,
                ),
              )
              .toList();
        });
      }
    } catch (e) {
      if (mounted && request == _request) {
        setState(
          () => error = e is ApiException
              ? e.message
              : 'Không tải được từ điển. Hãy thử lại.',
        );
      }
    } finally {
      if (mounted && request == _request) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final entries = catalog
        .where(
          (s) =>
              (!widget.favoritesOnly ||
                  state.favorites.contains(s.favoriteKey)) &&
              (category == 'Tất cả' || s.category == category),
        )
        .toList();
    return AppPage(
      title: widget.favoritesOnly ? 'Ký hiệu yêu thích' : 'Từ điển ký hiệu',
      showBack: widget.favoritesOnly,
      tabIndex: widget.favoritesOnly ? null : 1,
      actions: widget.favoritesOnly
          ? null
          : [
              IconButton(
                tooltip: 'Làm mới',
                onPressed: loading ? null : _load,
                icon: const Icon(Icons.refresh),
              ),
              IconButton(
                tooltip: 'Xem yêu thích',
                onPressed: () => openScreen(context, 'S24'),
                icon: const Icon(Icons.favorite_border),
              ),
            ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            decoration: InputDecoration(
              hintText: 'Tìm kiếm ký hiệu...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: IconButton(
                tooltip: 'Tìm kiếm',
                onPressed: () {
                  page = 1;
                  _load();
                },
                icon: const Icon(Icons.arrow_forward),
              ),
            ),
            onChanged: (v) => query = v,
            onSubmitted: (_) {
              page = 1;
              _load();
            },
          ),
          const SizedBox(height: 14),
          if (!widget.favoritesOnly) ...[
            SizedBox(
              height: 44,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children:
                    ['Tất cả', ...topics.map((topic) => '${topic['name']}')]
                        .map(
                          (c) => Padding(
                            padding: const EdgeInsets.only(right: 6),
                            child: ChoiceChip(
                              label: Text(c),
                              selected: category == c,
                              onSelected: (_) {
                                category = c;
                                categoryId = null;
                                for (final topic in topics) {
                                  if (topic['name'] == c) {
                                    categoryId = '${topic['_id']}';
                                  }
                                }
                                page = 1;
                                _load();
                              },
                            ),
                          ),
                        )
                        .toList(),
              ),
            ),
            const SizedBox(height: 14),
          ],
          if (loading) const LinearProgressIndicator(),
          if (error != null) ...[
            Text(error!),
            TextButton(onPressed: _load, child: const Text('Thử lại')),
          ],
          if (entries.isEmpty && !loading && error == null)
            EmptyView(
              title: widget.favoritesOnly
                  ? 'Chưa có ký hiệu yêu thích'
                  : 'Không tìm thấy kết quả',
              description: widget.favoritesOnly
                  ? 'Nhấn vào trái tim trên ký hiệu để lưu tại đây.'
                  : 'Hãy thử từ khóa khác.',
              icon: widget.favoritesOnly ? Icons.favorite_border : Icons.search,
            ),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: entries.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 14,
              crossAxisSpacing: 14,
              mainAxisExtent:
                  185 * MediaQuery.textScalerOf(context).scale(1).clamp(1, 1.6),
            ),
            itemBuilder: (context, i) {
              final s = entries[i];
              final favorite = state.favorites.contains(s.favoriteKey);
              return AppCard(
                padding: EdgeInsets.zero,
                onTap: () {
                  state.selectSign(s);
                  openScreen(context, 'S23');
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Container(
                        color:
                            (widget.favoritesOnly
                                    ? AppColors.red
                                    : AppColors.blue)
                                .withAlpha(15),
                        child: Stack(
                          children: [
                            const Center(
                              child: Icon(
                                Icons.back_hand_outlined,
                                size: 42,
                                color: AppColors.blue,
                              ),
                            ),
                            Positioned(
                              right: 2,
                              top: 2,
                              child: IconButton(
                                tooltip: favorite
                                    ? 'Bỏ yêu thích'
                                    : 'Yêu thích',
                                onPressed: () =>
                                    state.toggleSign(s.favoriteKey),
                                icon: Icon(
                                  favorite
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  color: favorite
                                      ? AppColors.red
                                      : Theme.of(context).colorScheme.outline,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            s.name,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            s.category,
                            style: TextStyle(
                              fontSize: 11,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          if (pages > 1)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  tooltip: 'Trang trước',
                  onPressed: !loading && page > 1
                      ? () {
                          page--;
                          _load();
                        }
                      : null,
                  icon: const Icon(Icons.chevron_left),
                ),
                Text('$page / $pages'),
                IconButton(
                  tooltip: 'Trang sau',
                  onPressed: !loading && page < pages
                      ? () {
                          page++;
                          _load();
                        }
                      : null,
                  icon: const Icon(Icons.chevron_right),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class SignDetailScreen extends StatefulWidget {
  const SignDetailScreen({super.key});
  @override
  State<SignDetailScreen> createState() => _SignDetailScreenState();
}

class _SignDetailScreenState extends State<SignDetailScreen> {
  bool playing = false;
  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final sign = state.selectedSign;
    final favorite = state.favorites.contains(sign.favoriteKey);
    return AppPage(
      title: sign.name,
      actions: [
        IconButton(
          tooltip: favorite ? 'Bỏ yêu thích' : 'Yêu thích',
          onPressed: () => state.toggleSign(sign.favoriteKey),
          icon: Icon(
            favorite ? Icons.favorite : Icons.favorite_border,
            color: favorite ? AppColors.red : null,
          ),
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppCard(
            color: AppColors.blue.withAlpha(15),
            child: Column(
              children: [
                const SizedBox(height: 10),
                const Icon(
                  Icons.back_hand_outlined,
                  color: AppColors.blue,
                  size: 74,
                ),
                const SizedBox(height: 14),
                BodyText(
                  playing
                      ? 'Đang mô phỏng trình phát minh họa'
                      : sign.videoUrl != null
                      ? 'Video ký hiệu'
                      : 'Minh họa giữ chỗ cho video ký hiệu',
                  center: true,
                ),
                const SizedBox(height: 12),
                IconButton.filled(
                  tooltip: playing ? 'Dừng minh họa' : 'Xem minh họa',
                  onPressed: () async {
                    if (sign.videoUrl != null) {
                      try {
                        final opened = await launchUrl(
                          Uri.parse(sign.videoUrl!),
                          mode: LaunchMode.externalApplication,
                        );
                        if (!opened && context.mounted) {
                          toast(context, 'Không mở được video.');
                        }
                      } catch (_) {
                        if (context.mounted) {
                          toast(context, 'Không mở được video.');
                        }
                      }
                    } else {
                      setState(() => playing = !playing);
                    }
                  },
                  icon: Icon(playing ? Icons.pause : Icons.play_arrow),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Heading('Ý nghĩa', size: 16),
                const SizedBox(height: 8),
                BodyText(sign.meaning),
                const SizedBox(height: 20),
                const Heading('Hướng dẫn thực hiện', size: 16),
                const SizedBox(height: 8),
                BodyText(
                  sign.instructions ?? 'Video và hướng dẫn cho ký hiệu này sẽ được bổ sung từ bộ dữ liệu VSL đã kiểm chứng.',
                ),
                const SizedBox(height: 20),
                const Heading('Ví dụ', size: 16),
                const SizedBox(height: 8),
                BodyText('“${sign.example}”'),
              ],
            ),
          ),
          const SizedBox(height: 18),
          if (sign.id == null)
            const Notice(
              'Nội dung từ điển là dữ liệu demo từ thiết kế. '
              'Hướng dẫn ký hiệu cần được kiểm chứng trước khi dùng làm tài liệu học.',
            ),
        ],
      ),
    );
  }
}
