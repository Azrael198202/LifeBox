import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lifebox/l10n/app_localizations.dart';

import '../../../core/i18n/locale_controller.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/services/app_lock.dart';
import '../../auth/state/auth_controller.dart';

import '../state/subscription_providers.dart';
import '../ui/paywall_dialog.dart';

// ✅ 新增：云保存开关的 provider
import '../state/settings_providers.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lock = ref.watch(appLockProvider);
    final auth = ref.watch(authControllerProvider);

    final l10n = AppLocalizations.of(context);
    final locale = ref.watch(localeProvider);

    // ✅ 云保存开关（默认 false，已持久化到本机）
    final cloudEnabled = ref.watch(cloudEnabledProvider);

    return AppScaffold(
      title: l10n.settings_title,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ====== 账号信息（简版）======
          Card(
            child: ListTile(
              leading: const Icon(Icons.account_circle_outlined),
              title: Text(auth.user?.displayName ?? l10n.not_logged_in),
              subtitle: Text(auth.user?.email ?? ''),
            ),
          ),

          const SizedBox(height: 12),

          // ====== 云保存（收费）======
          Card(
            child: SwitchListTile(
              value: cloudEnabled,
              onChanged: (v) async {
                // 关闭：直接关
                if (!v) {
                  await ref
                      .read(cloudEnabledProvider.notifier)
                      .setEnabled(false);
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('云保存已关闭（仅本机保存）')),
                  );
                  return;
                }

                // 开启：先检查订阅
                final subState = ref.read(subscriptionProvider);
                if (subState.subscribed) {
                  await ref
                      .read(cloudEnabledProvider.notifier)
                      .setEnabled(true);
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('云保存已开启（将同步到服务器）')),
                  );
                  return;
                }

                // 未订阅：弹付费墙
                final ok = await showCloudPaywallDialog(context);
                if (!ok) {
                  // 用户取消 or 失败：保持关闭
                  await ref
                      .read(cloudEnabledProvider.notifier)
                      .setEnabled(false);
                  return;
                }

                // 购买/恢复成功：打开云保存
                await ref.read(cloudEnabledProvider.notifier).setEnabled(true);
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('订阅成功，云保存已开启')),
                );
              },
              title: const Text('云保存（收费）'),
              subtitle: Consumer(
                builder: (context, ref, _) {
                  final sub = ref.watch(subscriptionProvider);
                  final status = sub.subscribed ? '已订阅' : '未订阅';
                  return Text(
                    cloudEnabled
                        ? '已开启：确认保存时会调用云端 API（$status）'
                        : '默认关闭：数据仅保存在本机（$status）',
                  );
                },
              ),
              secondary: const Icon(Icons.cloud_outlined),
            ),
          ),

          const SizedBox(height: 12),

          // ====== DEBUG：重置订阅状态（仅开发调试时显示）======
          Card(
            child: ListTile(
              leading: const Icon(Icons.bug_report_outlined),
              title: const Text('DEBUG: 重置订阅为未订阅'),
              onTap: () async {
                await ref
                    .read(subscriptionProvider.notifier)
                    .debugSetSubscribed(false);
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('已重置为未订阅（DEBUG）')),
                );
              },
            ),
          ),

          const SizedBox(height: 12),

          // ====== 隐私：上传策略（示例占位）======
          // 建议：后续你可以把这个开关与“云保存”做联动，例如：
          // - 云保存关闭时，这个开关禁用/隐藏
          Card(
            child: SwitchListTile(
              value: true,
              onChanged: (v) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('已保存（示例：后续接入持久化）')),
                );
              },
              title: Text(l10n.upload_policy_title),
              subtitle: Text(l10n.upload_policy_subtitle),
              secondary: const Icon(Icons.privacy_tip_outlined),
            ),
          ),

          const SizedBox(height: 12),

          // ====== 安全：应用锁（生物识别占位）======
          Card(
            child: SwitchListTile(
              value: lock.enabled,
              onChanged: (v) =>
                  ref.read(appLockProvider.notifier).setEnabled(v),
              title: Text(l10n.app_lock_title),
              subtitle: Text(l10n.app_lock_subtitle),
              secondary: const Icon(Icons.lock_outline),
            ),
          ),

          const SizedBox(height: 12),

          // ====== 本地缓存（占位）======
          Card(
            child: ListTile(
              leading: const Icon(Icons.storage_outlined),
              title: Text(l10n.cache_title),
              subtitle: Text(l10n.cache_subtitle),
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
              title: Text(l10n.clear_data_title),
              subtitle: Text(l10n.clear_data_subtitle),
              onTap: () async {
                final ok = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('确认清除？'),
                    content: const Text('这将清除本地缓存数据（示例占位）。'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        child: Text(l10n.common_Cancel),
                      ),
                      FilledButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        child: const Text('清除'),
                      ),
                    ],
                  ),
                );

                if (ok == true) {
                  // TODO: 清除本地 DB / 缓存（建议同时提示：不会影响云端数据）
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('已清除（示例：后续接入真实清理逻辑）')),
                  );
                }
              },
            ),
          ),

          const SizedBox(height: 12),

          // ====== 语言设置 ======
          Card(
            child: ListTile(
              leading: const Icon(Icons.language_outlined),
              title: Text(l10n.language_title),
              subtitle: Text(l10n.language_subtitle),
              trailing: DropdownButtonHideUnderline(
                child: DropdownButton<Locale>(
                  value: locale,
                  items: const [
                    DropdownMenuItem(value: Locale('ja'), child: Text('日本語')),
                    DropdownMenuItem(value: Locale('zh'), child: Text('中文')),
                    DropdownMenuItem(
                        value: Locale('en'), child: Text('English')),
                  ],
                  onChanged: (v) {
                    if (v == null) return;
                    ref.read(localeProvider.notifier).setLocale(v);
                  },
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // ====== 退出登录 ======
          Card(
            child: ListTile(
              leading: const Icon(Icons.logout),
              title: Text(l10n.logout_title),
              onTap: () async {
                final ok = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: Text(l10n.logout_title),
                    content: Text(l10n.logout_QA),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        child: Text(l10n.common_Cancel),
                      ),
                      FilledButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        child: Text(l10n.logout_OK),
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

          // ====== 版本信息 ======
          Center(
            child: Text(
              l10n.version_text,
              style: const TextStyle(color: Colors.black45),
            ),
          ),
        ],
      ),
    );
  }
}
