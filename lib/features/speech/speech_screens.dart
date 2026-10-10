import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/app_state.dart';
import '../../core/navigation.dart';
import '../../core/theme.dart';
import '../../widgets/ui.dart';

class SpeechCaptureScreen extends StatelessWidget {
  const SpeechCaptureScreen({super.key, this.listening = false});
  final bool listening;
  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    return AppPage(
      title: listening ? 'Đang ghi âm...' : 'Giọng nói thành văn bản',
      child: Column(
        children: [
          const SizedBox(height: 24),
          PulseOrb(
            icon: Icons.mic_none,
            color: AppColors.teal,
            animate: listening,
            label: listening ? 'Đang lắng nghe' : 'Bắt đầu ghi nhận',
            onTap: listening
                ? null
                : () => openScreen(context, 'S17', replace: true),
          ),
          Heading(
            listening ? 'Đang lắng nghe...' : 'Sẵn sàng lắng nghe',
            center: true,
          ),
          const SizedBox(height: 12),
          BodyText(
            listening
                ? 'Hãy nói rõ ràng để chuyển thành văn bản.'
                : 'Nhấn vào microphone để bắt đầu ghi nhận.',
            center: true,
          ),
          const SizedBox(height: 28),
          if (listening) ...[
            const Waveform(),
            const SizedBox(height: 28),
            AppButton(
              'Dừng ghi nhận',
              color: AppColors.red,
              secondary: true,
              icon: Icons.stop,
              onPressed: () {
                state.update(
                  () => state.transcript =
                      'Xin chào, tôi có thể giúp gì cho bạn?',
                );
                openScreen(context, 'S18', replace: true);
              },
            ),
          ] else
            AppButton(
              'Bắt đầu ghi nhận',
              color: AppColors.teal,
              icon: Icons.mic,
              onPressed: () => openScreen(context, 'S17', replace: true),
            ),
          const SizedBox(height: 24),
          const Notice(
            'Chế độ demo: waveform và kết quả dùng dữ liệu mẫu. '
            'Ứng dụng chưa thu âm từ microphone.',
            color: AppColors.teal,
          ),
        ],
      ),
    );
  }
}

class TranscriptScreen extends StatefulWidget {
  const TranscriptScreen({super.key, this.fullscreen = false});
  final bool fullscreen;
  @override
  State<TranscriptScreen> createState() => _TranscriptScreenState();
}

class _TranscriptScreenState extends State<TranscriptScreen> {
  double fontSize = 28;
  @override
  void initState() {
    super.initState();
    if (widget.fullscreen) fontSize = 40;
  }

  void changeSize(double delta) =>
      setState(() => fontSize = (fontSize + delta).clamp(18, 72).toDouble());
  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final text = state.transcript;
    if (widget.fullscreen) {
      return Scaffold(
        backgroundColor: const Color(0xFF0B1220),
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    IconButton(
                      tooltip: 'Đóng',
                      onPressed: () => backOrHome(context),
                      icon: const Icon(Icons.close, color: Colors.white),
                    ),
                    const Expanded(
                      child: Text(
                        'Toàn màn hình',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white70),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Giảm cỡ chữ',
                      onPressed: () => changeSize(-6),
                      icon: const Icon(Icons.remove, color: Colors.white),
                    ),
                    IconButton(
                      tooltip: 'Tăng cỡ chữ',
                      onPressed: () => changeSize(6),
                      icon: const Icon(Icons.add, color: Colors.white),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(28),
                    child: Text(
                      text,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: fontSize,
                        height: 1.4,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24),
                child: AppButton(
                  'Quay lại',
                  outlined: true,
                  color: Colors.white,
                  onPressed: () => backOrHome(context),
                ),
              ),
            ],
          ),
        ),
      );
    }
    return AppPage(
      title: 'Kết quả văn bản',
      actions: [
        IconButton(
          tooltip: 'Giảm cỡ chữ',
          onPressed: () => changeSize(-4),
          icon: const Icon(Icons.remove),
        ),
        IconButton(
          tooltip: 'Tăng cỡ chữ',
          onPressed: () => changeSize(4),
          icon: const Icon(Icons.add),
        ),
      ],
      footer: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppButton(
            'Toàn màn hình',
            color: AppColors.teal,
            icon: Icons.fullscreen,
            onPressed: () => openScreen(context, 'S19'),
          ),
          const SizedBox(height: 10),
          AppButton(
            'Ghi nhận lại',
            outlined: true,
            icon: Icons.refresh,
            onPressed: () => openScreen(context, 'S16', replace: true),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SignVoiceBadge(
            'Kết quả demo',
            color: AppColors.teal,
            icon: Icons.check_circle_outline,
          ),
          const SizedBox(height: 18),
          AppCard(
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 180),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  text,
                  style: TextStyle(
                    fontSize: fontSize,
                    height: 1.4,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 18),
          AppButton(
            'Chỉnh sửa văn bản',
            secondary: true,
            icon: Icons.edit_outlined,
            onPressed: () async {
              final result = await editText(
                context,
                title: 'Chỉnh sửa văn bản',
                initial: text,
              );
              if (result != null && result.isNotEmpty) {
                state.update(() => state.transcript = result);
              }
            },
          ),
          const SizedBox(height: 10),
          AppButton(
            'Sao chép',
            outlined: true,
            icon: Icons.copy_outlined,
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: text));
              if (context.mounted) toast(context, 'Đã sao chép văn bản.');
            },
          ),
          const SizedBox(height: 10),
          AppButton(
            'Lưu lịch sử',
            color: AppColors.green,
            secondary: true,
            icon: Icons.save_outlined,
            onPressed: () {
              state.saveConversation(text, ConversationDirection.speechToText);
              openScreen(context, 'SS03');
            },
          ),
        ],
      ),
    );
  }
}
