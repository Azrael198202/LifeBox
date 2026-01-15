import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../state/subscription_providers.dart';

/// 返回 true = 已完成购买/恢复并具备订阅；false = 取消/失败
Future<bool> showCloudPaywallDialog(BuildContext context) async {
  final r = await showDialog<bool>(
    context: context,
    barrierDismissible: true,
    builder: (_) => const _CloudPaywallDialog(),
  );
  return r ?? false;
}

class _CloudPaywallDialog extends ConsumerWidget {
  const _CloudPaywallDialog();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sub = ref.watch(subscriptionProvider);
    final notifier = ref.read(subscriptionProvider.notifier);

    return AlertDialog(
      title: const Text('云保存（收费）'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('开启云保存需要订阅 Pro（Mock）。'),
          const SizedBox(height: 10),
          _FeatureRow(icon: Icons.cloud_upload_outlined, text: '保存到服务器数据库'),
          _FeatureRow(icon: Icons.devices_outlined, text: '多设备同步（后续）'),
          _FeatureRow(icon: Icons.lock_outline, text: '本机仍可离线使用'),
          const SizedBox(height: 12),
          Text(
            '价格：¥300/月（Mock）',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: Colors.black.withOpacity(0.75),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: sub.busy ? null : () => Navigator.pop(context, false),
          child: const Text('取消'),
        ),
        TextButton(
          onPressed: sub.busy
              ? null
              : () async {
                  final ok = await notifier.restore();
                  if (!context.mounted) return;
                  Navigator.pop(context, ok);
                },
          child: const Text('恢复购买'),
        ),
        FilledButton(
          onPressed: sub.busy
              ? null
              : () async {
                  final ok = await notifier.purchase();
                  if (!context.mounted) return;
                  Navigator.pop(context, ok);
                },
          child: sub.busy
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('订阅并开启'),
        ),
      ],
    );
  }
}

class _FeatureRow extends StatelessWidget {
  const _FeatureRow({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 8),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}
