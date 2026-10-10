import 'package:flutter/material.dart';

import '../../core/app_state.dart';
import '../../core/navigation.dart';
import '../../core/theme.dart';
import '../../widgets/ui.dart';

class PermissionScreen extends StatelessWidget {
  const PermissionScreen({super.key, required this.camera});
  final bool camera;
  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final color = camera ? AppColors.blue : AppColors.teal;
    final device = camera ? 'camera' : 'microphone';
    return AppPage(
      title: camera ? 'Nhận diện ký hiệu' : 'Giọng nói → Văn bản',
      child: Column(
        children: [
          const SizedBox(height: 20),
          PulseOrb(
            icon: camera ? Icons.camera_alt_outlined : Icons.mic_none,
            color: color,
          ),
          Heading('Cho phép sử dụng $device', center: true),
          const SizedBox(height: 16),
          BodyText(
            camera ? 'SignVoice cần camera để nhận diện ký hiệu tay.' : 'SignVoice cần microphone để chuyển lời nói tiếng Việt thành văn bản.',
            center: true,
          ),
          const SizedBox(height: 24),
          Notice(
            'Bản FE đang mô phỏng quyền truy cập. '
            'Chưa mở camera hoặc ghi âm từ thiết bị.',
            color: color,
            icon: Icons.shield_outlined,
          ),
          const SizedBox(height: 24),
          AppButton(
            'Cho phép $device',
            color: color,
            onPressed: () {
              state.update(() {
                if (camera) {
                  state.cameraAllowed = true;
                } else {
                  state.microphoneAllowed = true;
                }
              });
              openScreen(context, camera ? 'S10' : 'S16', replace: true);
            },
          ),
          const SizedBox(height: 10),
          AppButton(
            'Từ chối',
            color: AppColors.red,
            secondary: true,
            onPressed: () {
              state.update(() => state.permissionCamera = camera);
              openScreen(context, 'SS06');
            },
          ),
          TextButton(
            onPressed: () => backOrHome(context),
            child: const Text('Để sau'),
          ),
        ],
      ),
    );
  }
}

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key, this.status = 0});
  // 0: sẵn sàng, 1: thành công, 2: thất bại.
  final int status;
  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  int errorType = 0;
  static const errors = [
    'Không thấy tay',
    'Nhiều bàn tay',
    'Ánh sáng yếu',
    'Ký hiệu chưa hỗ trợ',
  ];
  static const tips = [
    'Đưa một bàn tay vào khung hình.',
    'Chỉ đặt một bàn tay trong khung.',
    'Di chuyển đến nơi có ánh sáng tốt hơn.',
    'Ký hiệu này chưa có trong dữ liệu demo.',
  ];
  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final statusColor = widget.status == 1
        ? AppColors.green
        : widget.status == 2
        ? AppColors.red
        : Colors.white54;
    return Scaffold(
      backgroundColor: const Color(0xFF111827),
      appBar: AppBar(
        backgroundColor: const Color(0xFF111827),
        foregroundColor: Colors.white,
        title: const Text('Nhận diện ký hiệu'),
        leading: IconButton(
          tooltip: 'Quay lại',
          onPressed: () => backOrHome(context),
          icon: const Icon(Icons.chevron_left),
        ),
        actions: [
          IconButton(
            tooltip: 'Hướng dẫn',
            icon: const Icon(Icons.help_outline),
            onPressed: () => toast(
              context,
              'Đưa một bàn tay vào khung, giữ ổn định và đủ sáng.',
            ),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1F2937),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: statusColor, width: 2),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.back_hand_outlined,
                            size: 76,
                            color: Colors.white.withAlpha(95),
                          ),
                          const SizedBox(height: 18),
                          const Padding(
                            padding: EdgeInsets.all(16),
                            child: Text(
                              'Đưa một bàn tay vào khung hình',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Positioned(
                        top: 14,
                        left: 14,
                        right: 14,
                        child: Row(
                          children: [
                            SignVoiceBadge(
                              widget.status == 1
                                  ? 'Nhận diện thành công'
                                  : widget.status == 2
                                  ? errors[errorType]
                                  : 'Camera demo',
                              color: widget.status == 0
                                  ? AppColors.teal
                                  : statusColor,
                            ),
                          ],
                        ),
                      ),
                      const Positioned(
                        bottom: 16,
                        child: Text(
                          'Khung xem trước mô phỏng',
                          style: TextStyle(color: Colors.white54, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Flexible(
              flex: 0,
              child: Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * .58,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(28),
                  ),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (widget.status == 0) ...[
                        const AppCard(
                          child: BodyText(
                            'Kết quả sẽ hiển thị ở đây...',
                            center: true,
                          ),
                        ),
                        const SizedBox(height: 14),
                        const BodyText(
                          'Giữ tay ổn định để ứng dụng nhận diện.',
                          center: true,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: AppButton(
                                'Demo thành công',
                                compact: true,
                                secondary: true,
                                onPressed: () =>
                                    openScreen(context, 'S11', replace: true),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: AppButton(
                                'Demo thất bại',
                                compact: true,
                                secondary: true,
                                color: AppColors.red,
                                onPressed: () =>
                                    openScreen(context, 'S12', replace: true),
                              ),
                            ),
                          ],
                        ),
                      ] else if (widget.status == 1) ...[
                        AppCard(
                          borderColor: AppColors.green.withAlpha(100),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SignVoiceBadge(
                                'Kết quả mô phỏng • 96%',
                                color: AppColors.green,
                              ),
                              const SizedBox(height: 12),
                              Heading(state.detectedSign, size: 28),
                              const SizedBox(height: 14),
                              const LinearProgressIndicator(
                                value: .96,
                                color: AppColors.green,
                                backgroundColor: Color(0xFFE2E8F0),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          initialValue: state.detectedSign,
                          decoration: const InputDecoration(
                            labelText: 'Đổi ký hiệu demo',
                          ),
                          items: signs
                              .map(
                                (s) => DropdownMenuItem(
                                  value: s.name,
                                  child: Text(s.name),
                                ),
                              )
                              .toList(),
                          onChanged: (v) {
                            if (v != null) {
                              state.update(() => state.detectedSign = v);
                            }
                          },
                        ),
                        const SizedBox(height: 16),
                        AppButton(
                          'Thêm vào câu',
                          icon: Icons.add,
                          onPressed: () {
                            state.addWord(state.detectedSign);
                            openScreen(
                              context,
                              state.autoSpeak ? 'S14' : 'S13',
                            );
                          },
                        ),
                        TextButton(
                          onPressed: () =>
                              openScreen(context, 'S10', replace: true),
                          child: const Text('Nhận diện tiếp'),
                        ),
                      ] else ...[
                        Notice(
                          tips[errorType],
                          color: AppColors.red,
                          icon: Icons.error_outline,
                        ),
                        const SizedBox(height: 14),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: List.generate(
                            errors.length,
                            (i) => ChoiceChip(
                              label: Text(errors[i]),
                              selected: errorType == i,
                              onSelected: (_) => setState(() => errorType = i),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        AppButton(
                          'Thử lại',
                          icon: Icons.refresh,
                          onPressed: () =>
                              openScreen(context, 'S10', replace: true),
                        ),
                        TextButton(
                          onPressed: () => openRoot(context, 'S22'),
                          child: const Text('Xem từ điển'),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SentenceScreen extends StatelessWidget {
  const SentenceScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    return AppPage(
      title: 'Tạo câu',
      footer: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppButton(
            'Phát giọng nói',
            icon: Icons.volume_up_outlined,
            onPressed: state.sentence.isEmpty
                ? null
                : () => openScreen(context, 'S14'),
          ),
          const SizedBox(height: 10),
          AppButton(
            'Lưu lịch sử',
            secondary: true,
            icon: Icons.save_outlined,
            onPressed: state.sentence.isEmpty
                ? null
                : () {
                    state.saveConversation(
                      state.sentenceText,
                      ConversationDirection.signToSpeech,
                    );
                    openScreen(context, 'SS03');
                  },
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppCard(
            borderColor: AppColors.blue.withAlpha(90),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (state.sentence.isEmpty)
                  const EmptyView(
                    title: 'Chưa có từ trong câu',
                    description: 'Nhận diện ký hiệu hoặc chỉnh sửa để tạo câu.',
                    icon: Icons.back_hand_outlined,
                  )
                else ...[
                  Heading(state.sentenceText, size: 26),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: List.generate(
                      state.sentence.length,
                      (i) => InputChip(
                        label: Text(state.sentence[i]),
                        onDeleted: () =>
                            state.update(() => state.sentence.removeAt(i)),
                        backgroundColor: AppColors.blue.withAlpha(20),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 18),
          AppButton(
            'Thêm từ',
            icon: Icons.add,
            outlined: true,
            onPressed: () => openScreen(context, 'S10'),
          ),
          const SizedBox(height: 10),
          AppButton(
            'Xóa từ cuối',
            icon: Icons.backspace_outlined,
            secondary: true,
            onPressed: state.sentence.isEmpty
                ? null
                : () => state.update(() => state.sentence.removeLast()),
          ),
          const SizedBox(height: 10),
          AppButton(
            'Chỉnh sửa câu',
            icon: Icons.edit_outlined,
            secondary: true,
            onPressed: () async {
              final text = await editText(
                context,
                title: 'Chỉnh sửa câu',
                initial: state.sentence.join(', '),
              );
              if (text != null) {
                state.update(() {
                  state.sentence.clear();
                  if (text.isNotEmpty) {
                    state.sentence.add(text.replaceFirst(RegExp(r'\.$'), ''));
                  }
                });
              }
            },
          ),
          const SizedBox(height: 10),
          AppButton(
            'Xóa tất cả',
            icon: Icons.delete_outline,
            color: AppColors.red,
            secondary: true,
            onPressed: state.sentence.isEmpty
                ? null
                : () => state.update(() => state.sentence.clear()),
          ),
        ],
      ),
    );
  }
}

class VoicePlaybackScreen extends StatefulWidget {
  const VoicePlaybackScreen({super.key});
  @override
  State<VoicePlaybackScreen> createState() => _VoicePlaybackScreenState();
}

class _VoicePlaybackScreenState extends State<VoicePlaybackScreen> {
  bool playing = true;
  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    return AppPage(
      title: 'Phát giọng nói',
      footer: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppButton(
            'Lưu vào lịch sử',
            secondary: true,
            icon: Icons.save_outlined,
            onPressed: state.sentence.isEmpty
                ? null
                : () {
                    state.saveConversation(
                      state.sentenceText,
                      ConversationDirection.signToSpeech,
                    );
                    openScreen(context, 'SS03');
                  },
          ),
          TextButton(
            onPressed: () => backOrHome(context),
            child: const Text('Quay lại chỉnh sửa'),
          ),
        ],
      ),
      child: Column(
        children: [
          const SizedBox(height: 24),
          PulseOrb(
            icon: Icons.volume_up_outlined,
            color: AppColors.blue,
            animate: playing,
          ),
          BodyText(
            playing ? 'Đang mô phỏng phát giọng nói...' : 'Đã tạm dừng',
            center: true,
          ),
          const SizedBox(height: 18),
          Heading(
            state.sentenceText.isEmpty ? 'Xin chào.' : state.sentenceText,
            size: 28,
            center: true,
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton.filled(
                tooltip: playing ? 'Tạm dừng' : 'Phát',
                iconSize: 32,
                onPressed: () => setState(() => playing = !playing),
                icon: Icon(playing ? Icons.pause : Icons.play_arrow),
              ),
              const SizedBox(width: 16),
              IconButton.outlined(
                tooltip: 'Phát lại',
                iconSize: 30,
                onPressed: () => setState(() => playing = true),
                icon: const Icon(Icons.replay),
              ),
            ],
          ),
          const SizedBox(height: 28),
          const Notice(
            'Hiệu ứng phát là mô phỏng. Chưa tích hợp bộ đọc văn bản TTS.',
          ),
        ],
      ),
    );
  }
}
