import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lifebox/l10n/app_localizations.dart';

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
    final l10n = AppLocalizations.of(context);

    return AlertDialog(
      title: Text(l10n.cloud_paywall_title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.cloud_paywall_desc),
          const SizedBox(height: 10),
          _FeatureRow(icon: Icons.cloud_upload_outlined, text: l10n.cloud_feature_backup),
          _FeatureRow(icon: Icons.devices_outlined, text: l10n.cloud_feature_sync),
          _FeatureRow(icon: Icons.lock_outline, text: l10n.cloud_feature_offline),
          const SizedBox(height: 12),
          Text(
            l10n.cloud_price_monthly,
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
          child: Text(l10n.common_Cancel),
        ),
        TextButton(
          onPressed: sub.busy
              ? null
              : () async {
                  final ok = await notifier.restore();
                  if (!context.mounted) return;
                  Navigator.pop(context, ok);
                },
          child: Text(l10n.subscription_restore),
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
              : Text(l10n.subscription_subscribe),
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
