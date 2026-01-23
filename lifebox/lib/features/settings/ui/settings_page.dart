import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lifebox/features/inbox/state/inbox_refresh.dart';
import 'package:lifebox/l10n/app_localizations.dart';
import 'avatar_picker.dart';
import 'package:go_router/go_router.dart';

import '../../../core/i18n/locale_controller.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/services/app_lock.dart';
import '../../auth/state/auth_providers.dart';

import '../state/subscription_providers.dart';

import '../state/settings_providers.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  Future<bool> requireSubscribed(BuildContext context, WidgetRef ref) async {
    await ref.read(subscriptionProvider.notifier).refresh();

    final sub = ref.read(subscriptionProvider);
    if (sub.subscribed) return true;

    final ok = await context.push<bool>('/paywall') ?? false;
    return ok;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lock = ref.watch(appLockProvider);
    final auth = ref.watch(authControllerProvider);

    final l10n = AppLocalizations.of(context);
    final locale = ref.watch(localeProvider);

    // ✅ 云保存开关（默认 false，已持久化到本机）
    final cloudEnabled = ref.watch(cloudEnabledProvider);

    final profile = ref.watch(userProfileProvider);

    final titleName = profile.nickname.isNotEmpty
        ? profile.nickname
        : (auth.user?.displayName ?? l10n.not_logged_in);

    return AppScaffold(
      title: l10n.settings_title,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ====== 账号信息（简版）======
          Card(
            child: ListTile(
              leading: AvatarCircle(
                avatarId: profile.avatarId,
                imageUrl: auth.user?.avatarUrl,
                radius: 20,
              ),
              title: Text(titleName),
              subtitle: Text(auth.user?.email ?? ''),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push('/settings/profile'),
            ),
          ),

          const SizedBox(height: 12),

          Card(
            child: ListTile(
              leading: const Icon(Icons.home_outlined),
              title: Text(l10n.setting_group),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Consumer(builder: (_, ref, __) {
                    final sub = ref.watch(subscriptionProvider);
                    return sub.subscribed
                        ? const SizedBox.shrink()
                        : const Icon(Icons.lock_outline,
                            size: 18, color: Colors.black45);
                  }),
                  const SizedBox(width: 6),
                  const Icon(Icons.chevron_right),
                ],
              ),
              onTap: () async {
                final ok = await requireSubscribed(context, ref);
                if (!ok) return;
                if (!context.mounted) return;
                context.push('/settings/groups');
              },
            ),
          ),

          const SizedBox(height: 12),

          // ====== 云保存======
          Card(
            child: SwitchListTile(
              value: cloudEnabled? ref.watch(subscriptionProvider).subscribed ? cloudEnabled : false :false,
              onChanged: (v) async {
                // 关闭：直接关
                if (!v) {
                  await ref
                      .read(cloudEnabledProvider.notifier)
                      .setEnabled(false);
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l10n.setting_cloud_off)),
                  );
                  return;
                }

                // 开启：先检查订阅
                final subState = ref.read(subscriptionProvider);
                if (subState.subscribed) {
                  await ref
                      .read(cloudEnabledProvider.notifier)
                      .setEnabled(true);
                  refreshInboxProviders(ref); 
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l10n.setting_cloud_on)),
                  );
                  return;
                }

                // 未订阅：弹付费墙
                final ok = await requireSubscribed(context, ref);
                if (!ok) {
                  await ref
                      .read(cloudEnabledProvider.notifier)
                      .setEnabled(false);
                  return;
                }

                // 购买/恢复成功：打开云保存
                await ref.read(cloudEnabledProvider.notifier).setEnabled(true);
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l10n.setting_cloud_sub_success)),
                );
              },
              title: Row(
                children: [
                  Text(l10n.setting_cloud_title),
                  const SizedBox(width: 8),
                  Consumer(builder: (_, ref, __) {
                    final sub = ref.watch(subscriptionProvider);
                    return sub.subscribed
                        ? const SizedBox.shrink()
                        : const Icon(Icons.lock_outline,
                            size: 16, color: Colors.black45);
                  }),
                ],
              ),

              secondary: const Icon(Icons.cloud_outlined),
            ),
          ),

          const SizedBox(height: 12),

          // ====== DEBUG：重置订阅状态（仅开发调试时显示）======
          Card(
            child: ListTile(
              leading: const Icon(Icons.bug_report_outlined),
              title: Text(l10n.setting_debug_reset_sub),
              onTap: () async {
                await ref
                    .read(subscriptionProvider.notifier)
                    .debugSetSubscribed(false);
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l10n.setting_debug_reset_done)),
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
                  SnackBar(content: Text(l10n.setting_privacy_saved_demo)),
                );
              },
              title: Text(l10n.upload_policy_title, style: const TextStyle(fontSize: 14)),
              subtitle: Text(l10n.upload_policy_subtitle, style: const TextStyle(fontSize: 12)),
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
              title: Text(l10n.app_lock_title, style: const TextStyle(fontSize: 14)),
              subtitle: Text(l10n.app_lock_subtitle, style: const TextStyle(fontSize: 12)),
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
                  SnackBar(content: Text(l10n.setting_cache_todo)),
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
                    title: Text(l10n.setting_clear_confirm_title),
                    content: Text(l10n.setting_clear_confirm_desc),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        child: Text(l10n.cancel),
                      ),
                      FilledButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        child: Text(l10n.setting_clear_ok),
                      ),
                    ],
                  ),
                );

                if (ok == true) {
                  // TODO: 清除本地 DB / 缓存（建议同时提示：不会影响云端数据）
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l10n.setting_clear_done)),
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
                  items: [
                    DropdownMenuItem(value: Locale('ja'), child: Text(l10n.language_jp)),
                    DropdownMenuItem(value: Locale('zh'), child: Text(l10n.language_zh)),
                    DropdownMenuItem(
                        value: Locale('en'), child: Text(l10n.language_en)),
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
                        child: Text(l10n.cancel),
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
