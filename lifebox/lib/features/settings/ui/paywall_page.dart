import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lifebox/core/network/app_config.dart';
import 'package:lifebox/l10n/app_localizations.dart';
import '../state/subscription_providers.dart';
import '../state/subscription_providers.dart' show subscriptionStoreProvider;

class PaywallPage extends ConsumerWidget {
  const PaywallPage({super.key});

  bool get _isDev => AppConfig.env == AppEnv.dev;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sub = ref.watch(subscriptionProvider);
    final notifier = ref.read(subscriptionProvider.notifier);
    final l10n = AppLocalizations.of(context);

    // ✅ 已订阅：直接关闭
    if (sub.subscribed) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pop(context, true);
      });
    }

    final products = sub.products;
    final monthly =
        products.where((p) => p.id == SubscriptionNotifier.monthlyId).toList();
    final yearly =
        products.where((p) => p.id == SubscriptionNotifier.yearlyId).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.paywallTitle),
        actions: [
          IconButton(
            onPressed: sub.busy ? null : () => notifier.refresh(),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 8),
            Text(
              l10n.paywallDesc,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 16),
            if (sub.error != null) ...[
              Text(sub.error!, style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 12),
            ],
            if (sub.loading) const LinearProgressIndicator(),
            const SizedBox(height: 12),
            Expanded(
              child: ListView(
                children: [
                  // =========================
                  // DEV MODE (Route A)
                  // =========================
                  if (_isDev) ...[
                    _devBanner(),
                    const SizedBox(height: 12),
                    _planCard(
                      title: '${l10n.planMonthly} (DEV)',
                      subtitle: '¥300 / 月（モック）',
                      onTap: sub.busy
                          ? null
                          : () async {
                              await _devActivate(
                                context: context,
                                ref: ref,
                                productId: SubscriptionNotifier.monthlyId,
                                planLabel: l10n.planMonthly,
                              );
                            },
                    ),
                    const SizedBox(height: 12),
                    _planCard(
                      title: '${l10n.planYearly} (DEV)',
                      subtitle: '¥3,000 / 年（モック）',
                      onTap: sub.busy
                          ? null
                          : () async {
                              await _devActivate(
                                context: context,
                                ref: ref,
                                productId: SubscriptionNotifier.yearlyId,
                                planLabel: l10n.planMonthly,
                              );
                            },
                    ),
                    const SizedBox(height: 12),
                    Card(
                      child: ListTile(
                        leading: const Icon(Icons.restore),
                        title: Text('${l10n.restorePurchase} (DEV)'),
                        subtitle: const Text('サーバー状態を再取得します'),
                        onTap: sub.busy ? null : () => notifier.refresh(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Card(
                      child: ListTile(
                        leading: const Icon(Icons.bug_report_outlined),
                        title: const Text('DEV: 解約/期限切れをシミュレーション'),
                        subtitle:
                            const Text('purchase_token=test_expired で verify'),
                        onTap:
                            sub.busy ? null : () async => _devExpire(ref: ref),
                      ),
                    ),
                  ]

                  // =========================
                  // PROD MODE (real IAP)
                  // =========================
                  else ...[
                    _planCard(
                      title: l10n.planMonthly,
                      subtitle: monthly.isNotEmpty
                          ? monthly.first.price
                          : l10n.loadingText,
                      onTap: monthly.isEmpty || sub.loading || sub.busy
                          ? null
                          : () => notifier.purchase(monthly.first),
                    ),
                    const SizedBox(height: 12),
                    _planCard(
                      title: l10n.planYearly,
                      subtitle: yearly.isNotEmpty
                          ? yearly.first.price
                          : l10n.loadingText,
                      onTap: yearly.isEmpty || sub.loading || sub.busy
                          ? null
                          : () => notifier.purchase(yearly.first),
                    ),
                    const SizedBox(height: 12),
                    Card(
                      child: ListTile(
                        leading: const Icon(Icons.restore),
                        title: Text(l10n.restorePurchase),
                        onTap: sub.loading || sub.busy
                            ? null
                            : () => notifier.restore(),
                      ),
                    ),
                  ],

                  const SizedBox(height: 12),

                  // cancel guide
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.help_outline),
                      title: Text(l10n.cancelGuideTitle),
                      subtitle: Text(l10n.cancelGuideSubtitle),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed:
                    sub.busy ? null : () => Navigator.pop(context, false),
                child: Text(l10n.notNow),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // -------------------
  // DEV helper actions
  // -------------------
  Future<void> _devActivate({
    required BuildContext context,
    required WidgetRef ref,
    required String productId,
    required String planLabel, // 月付/年付，用于显示
  }) async {
    final notifier = ref.read(subscriptionProvider.notifier);
    final l10n = AppLocalizations.of(context);

    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('$planLabel（DEV）'),
        content: const Text('DEV モード：モックで購入を実行します。よろしいですか？'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(l10n.cancel)),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.continueText),
          ),
        ],
      ),
    );

    if (ok != true) return;

    final success = await notifier.devActivate(productId);

    if (!context.mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('購入完了（DEV）')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('購入に失敗しました（DEV）')),
      );
    }
  }

  Future<void> _devExpire({required WidgetRef ref}) async {
    final notifier = ref.read(subscriptionProvider.notifier);

    await notifier.devExpire();

    // 提示
    // ignore: use_build_context_synchronously
    ScaffoldMessenger.of(ref.context).showSnackBar(
      const SnackBar(content: Text('サブスクリプションを期限切れにしました（DEV）')),
    );
  }

  Widget _devBanner() {
    return Card(
      color: Colors.orange.withOpacity(0.12),
      child: const ListTile(
        leading: Icon(Icons.developer_mode),
        title: Text('DEV モード：IAP を使わずにモックで開通します'),
        subtitle: Text('AppConfig.env == AppEnv.dev のときのみ表示'),
      ),
    );
  }

  Widget _planCard({
    required String title,
    required String subtitle,
    required VoidCallback? onTap,
  }) {
    return Card(
      child: ListTile(
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
