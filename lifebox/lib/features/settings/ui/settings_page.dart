import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lifebox/l10n/app_localizations.dart';

import '../../../core/i18n/locale_controller.dart';

import '../../../core/widgets/app_scaffold.dart';
import '../../../core/services/app_lock.dart';
import '../../auth/state/auth_controller.dart';


class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lock = ref.watch(appLockProvider);
    final auth = ref.watch(authControllerProvider);

    final l10n = AppLocalizations.of(context);
    final locale = ref.watch(localeProvider);

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
              title: Text(l10n.upload_policy_title),
              subtitle: Text(l10n.upload_policy_subtitle),
            ),
          ),

          const SizedBox(height: 12),

          // ====== 安全：应用锁（生物识别占位）======
          Card(
            child: SwitchListTile(
              value: lock.enabled,
              onChanged: (v) => ref.read(appLockProvider.notifier).setEnabled(v),
              title: Text(l10n.app_lock_title),
              subtitle: Text(l10n.app_lock_subtitle),
            ),
          ),

          const SizedBox(height: 12),

          // ====== 本地缓存（占位）======
          Card(
            child: ListTile(
              leading: const Icon(Icons.storage_outlined),
              title: Text(l10n.cache_title),
              subtitle:  Text(l10n.cache_subtitle),
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
                  // TODO: 清除本地 DB / 缓存
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('已清除（示例：后续接入真实清理逻辑）')),
                  );
                }
              },
            ),
          ),
          
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
                    DropdownMenuItem(value: Locale('en'), child: Text('English')),
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

          // ====== 版本信息（占位）======
          Center(
            child: Text(
              l10n.version_text,
              style: TextStyle(color: Colors.black45),
            ),
          ),
        ],
      ),
    );
  }
}
