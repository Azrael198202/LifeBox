import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/app_scaffold.dart';
import '../../../core/services/app_lock.dart';
import '../../auth/state/auth_controller.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lock = ref.watch(appLockProvider);
    final auth = ref.watch(authControllerProvider);

    // 示例：上传策略（这里先用本地状态占位，后续可接入本地DB/secure storage）
    // 若你想持久化，我可以下一步加 SharedPreferences / secure storage。
    return AppScaffold(
      title: '设置',
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ====== 账号信息（简版）======
          Card(
            child: ListTile(
              leading: const Icon(Icons.account_circle_outlined),
              title: Text(auth.user?.displayName ?? '未登录'),
              subtitle: Text(auth.user?.email ?? ''),
            ),
          ),

          const SizedBox(height: 12),

          // ====== 隐私：上传策略（示例占位）======
          Card(
            child: SwitchListTile(
              value: true,
              onChanged: (v) {
                // TODO: 保存配置（仅文本/允许原图）
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('已保存（示例：后续接入持久化）')),
                );
              },
              title: const Text('仅上传 OCR 文本（默认开）'),
              subtitle: const Text('隐私友好：默认不上传原图（后续可配置）'),
            ),
          ),

          const SizedBox(height: 12),

          // ====== 安全：应用锁（生物识别占位）======
          Card(
            child: SwitchListTile(
              value: lock.enabled,
              onChanged: (v) => ref.read(appLockProvider.notifier).setEnabled(v),
              title: const Text('启用应用锁（推荐）'),
              subtitle: const Text('从后台回来需解锁（后续支持面部/指纹/系统认证）'),
            ),
          ),

          const SizedBox(height: 12),

          // ====== 本地缓存（占位）======
          Card(
            child: ListTile(
              leading: const Icon(Icons.storage_outlined),
              title: const Text('本地缓存'),
              subtitle: const Text('保留 7/30/永久（TODO）'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('TODO：缓存策略设置页')),
                );
              },
            ),
          ),

          const SizedBox(height: 12),

          // ====== 清除数据（占位）======
          Card(
            child: ListTile(
              leading: const Icon(Icons.delete_outline),
              title: const Text('清除数据'),
              subtitle: const Text('本地清除 / 云端清除（接口预留）'),
              onTap: () async {
                final ok = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('确认清除？'),
                    content: const Text('这将清除本地缓存数据（示例占位）。'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        child: const Text('取消'),
                      ),
                      FilledButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        child: const Text('清除'),
                      ),
                    ],
                  ),
                );

                if (ok == true) {
                  // TODO: 清除本地 DB / 缓存
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('已清除（示例：后续接入真实清理逻辑）')),
                  );
                }
              },
            ),
          ),

          const SizedBox(height: 12),

          // ====== 退出登录 ======
          Card(
            child: ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('退出登录'),
              onTap: () async {
                final ok = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('退出登录'),
                    content: const Text('确定要退出当前账号吗？'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        child: const Text('取消'),
                      ),
                      FilledButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        child: const Text('退出'),
                      ),
                    ],
                  ),
                );

                if (ok == true) {
                  await ref.read(authControllerProvider.notifier).logout();
                }
              },
            ),
          ),

          const SizedBox(height: 24),

          // ====== 版本信息（占位）======
          const Center(
            child: Text(
              'Life Inbox • v0.1.0 (MVP)',
              style: TextStyle(color: Colors.black45),
            ),
          ),
        ],
      ),
    );
  }
}
