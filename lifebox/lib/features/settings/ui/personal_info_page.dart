import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/app_scaffold.dart';
import '../../auth/state/auth_controller.dart';
import '../state/settings_providers.dart';
import 'avatar_picker.dart';

class PersonalInfoPage extends ConsumerWidget {
  const PersonalInfoPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authControllerProvider);
    final profile = ref.watch(userProfileProvider);

    final displayName = (profile.nickname.isNotEmpty)
        ? profile.nickname
        : (auth.user?.displayName ?? '---');

    return AppScaffold(
      title: '個人情報',
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Column(
              children: [
                ListTile(
                  title: const Text('プロフィール画像'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AvatarCircle(
                        avatarId: profile.avatarId,
                        radius: 16,
                        imageUrl: auth.user?.avatarUrl,
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.chevron_right),
                    ],
                  ),
                  onTap: () async {
                    final picked = await showAvatarPickerSheet(
                      context,
                      selectedId: profile.avatarId,
                    );
                    if (picked == null) return;
                    await ref
                        .read(userProfileProvider.notifier)
                        .setAvatarId(picked);
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  title: const Text('ニックネーム'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(displayName,
                          style: const TextStyle(color: Colors.black54)),
                      const SizedBox(width: 8),
                      const Icon(Icons.chevron_right),
                    ],
                  ),
                  onTap: () async {
                    final v = await _showEditTextDialog(
                      context,
                      title: 'ニックネーム',
                      initialValue: profile.nickname.isNotEmpty
                          ? profile.nickname
                          : (auth.user?.displayName ?? ''),
                    );
                    if (v == null) return;
                    await ref
                        .read(userProfileProvider.notifier)
                        .setNickname(v.trim());
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<String?> _showEditTextDialog(
    BuildContext context, {
    required String title,
    required String initialValue,
  }) async {
    final c = TextEditingController(text: initialValue);
    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: c,
          autofocus: true,
          style: const TextStyle(
            color: Colors.black87, // ✅ 输入文字颜色
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('キャンセル')),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, c.text),
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }
}
