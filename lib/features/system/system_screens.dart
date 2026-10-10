import 'package:flutter/material.dart';

import '../../core/app_state.dart';
import '../../core/navigation.dart';
import '../../core/theme.dart';
import '../../widgets/ui.dart';

class SystemScreen extends StatelessWidget {
  const SystemScreen({super.key, required this.id});
  final String id;
  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final titles = {
      'SS01': 'Đang tải...',
      'SS02': 'Lịch sử hội thoại',
      'SS03': 'Lưu thành công',
      'SS04': 'Lỗi',
      'SS05': 'Không có kết nối',
      'SS06': 'Quyền bị từ chối',
    };
    final headings = {
      'SS01': 'Đang tải dữ liệu',
      'SS02': 'Chưa có lịch sử',
      'SS03': 'Đã lưu thành công!',
      'SS04': 'Đã xảy ra lỗi',
      'SS05': 'Mất kết nối mạng',
      'SS06': 'Quyền truy cập bị từ chối',
    };
    final messages = {
      'SS01': 'Vui lòng chờ trong giây lát. Đây là trạng thái tải mẫu.',
      'SS02':
          'Bắt đầu một phiên dịch và lưu cuộc hội thoại để xem lại tại đây.',
      'SS03': 'Cuộc hội thoại đã được thêm vào lịch sử demo trong phiên này.',
      'SS04': 'Không thể xử lý yêu cầu lúc này. Vui lòng thử lại sau.',
      'SS05': 'Trong bản FE, bạn vẫn có thể xem từ điển và lịch sử demo. Đồng bộ cần kết nối.',
      'SS06': 'Luồng demo chưa được cấp quyền camera/microphone. Hãy thử cấp quyền lại.',
    };
    final icons = {
      'SS01': Icons.hourglass_empty,
      'SS02': Icons.history,
      'SS03': Icons.check_circle_outline,
      'SS04': Icons.error_outline,
      'SS05': Icons.wifi_off,
      'SS06': Icons.lock_outline,
    };
    final color = id == 'SS03'
        ? AppColors.green
        : id == 'SS04' || id == 'SS06'
        ? AppColors.red
        : id == 'SS05'
        ? const Color(0xFFD97706)
        : AppColors.blue;
    return AppPage(
      title: titles[id]!,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 36),
          Center(
            child: Container(
              width: 112,
              height: 112,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withAlpha(18),
              ),
              child: id == 'SS01'
                  ? const Padding(
                      padding: EdgeInsets.all(32),
                      child: CircularProgressIndicator(),
                    )
                  : Icon(icons[id], size: 54, color: color),
            ),
          ),
          const SizedBox(height: 28),
          Heading(headings[id]!, center: true),
          const SizedBox(height: 14),
          BodyText(messages[id]!, center: true),
          const SizedBox(height: 28),
          if (id == 'SS01') ...[
            const LinearProgressIndicator(),
            const SizedBox(height: 26),
            AppButton(
              'Về trang chủ',
              onPressed: () => openRoot(context, 'S08'),
            ),
          ],
          if (id == 'SS02') ...[
            AppButton(
              'Nhận diện ký hiệu',
              icon: Icons.back_hand_outlined,
              onPressed: () => openScreen(context, 'S09'),
            ),
            const SizedBox(height: 12),
            AppButton(
              'Ghi âm giọng nói',
              icon: Icons.mic_none,
              secondary: true,
              onPressed: () => openScreen(context, 'S15'),
            ),
          ],
          if (id == 'SS03') ...[
            AppCard(
              borderColor: color.withAlpha(60),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    state.selectedConversation?.content ??
                        'Màn hình trạng thái thành công mẫu.',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 10),
                  const SignVoiceBadge('Dữ liệu demo', color: AppColors.green),
                ],
              ),
            ),
            const SizedBox(height: 20),
            AppButton(
              'Xem lịch sử',
              icon: Icons.history,
              onPressed: () => openRoot(context, 'S20'),
            ),
            TextButton(
              onPressed: () => openRoot(context, 'S08'),
              child: const Text('Về trang chủ'),
            ),
          ],
          if (id == 'SS04') ...[
            const Notice(
              'Lỗi kết nối mẫu. Không có yêu cầu mạng thực tế trong bản FE.',
              color: AppColors.red,
            ),
            const SizedBox(height: 20),
            AppButton(
              'Thử lại',
              icon: Icons.refresh,
              onPressed: () {
                toast(context, 'Đã thử lại luồng demo.');
                openRoot(context, 'S08');
              },
            ),
          ],
          if (id == 'SS05') ...[
            const Notice(
              'Kết nối demo đang tắt. Dữ liệu hiện tại vẫn nằm trong phiên ứng dụng.',
              color: Color(0xFFD97706),
              icon: Icons.wifi_off,
            ),
            const SizedBox(height: 20),
            AppButton(
              'Thử kết nối lại',
              secondary: true,
              icon: Icons.wifi,
              onPressed: () {
                state.update(() => state.online = true);
                openScreen(context, 'S29', replace: true);
              },
            ),
          ],
          if (id == 'SS06') ...[
            const Notice(
              'Khi tích hợp thiết bị thật, quyền truy cập sẽ được quản lý trong Cài đặt điện thoại.',
              icon: Icons.settings_outlined,
            ),
            const SizedBox(height: 20),
            AppButton(
              'Thử cấp quyền demo',
              icon: Icons.settings_outlined,
              onPressed: () => openScreen(
                context,
                state.permissionCamera ? 'S09' : 'S15',
                replace: true,
              ),
            ),
            TextButton(
              onPressed: () => openRoot(context, 'S08'),
              child: const Text('Để sau'),
            ),
          ],
        ],
      ),
    );
  }
}

class ScreenCatalog extends StatelessWidget {
  const ScreenCatalog({super.key});
  @override
  Widget build(BuildContext context) => AppPage(
    title: 'Danh mục 37 màn hình',
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Notice(
          'Danh mục giúp kiểm tra từng màn hình theo mã trong Figma. '
          'Các trạng thái demo có thể mở trực tiếp từ đây.',
        ),
        const SizedBox(height: 18),
        for (final entry in screenNames.entries) ...[
          AppCard(
            padding: EdgeInsets.zero,
            onTap: () => openScreen(context, entry.key),
            child: ListTile(
              leading: SignVoiceBadge(entry.key),
              title: Text(entry.value),
              trailing: const Icon(Icons.chevron_right),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ],
    ),
  );
}
