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
                                ref: ref,
                                productId: SubscriptionNotifier.monthlyId,
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
                                ref: ref,
                                productId: SubscriptionNotifier.yearlyId,
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
                        subtitle: const Text('purchase_token=test_expired で verify'),
                        onTap: sub.busy
                            ? null
                            : () async {
                                await _devExpire(ref: ref);
                              },
                      ),
                    ),
                  ]

                  // =========================
                  // PROD MODE (real IAP)
                  // =========================
                  else ...[
                    _planCard(
                      title: l10n.planMonthly,
                      subtitle:
                          monthly.isNotEmpty ? monthly.first.price : l10n.loadingText,
                      onTap: monthly.isEmpty || sub.loading || sub.busy
                          ? null
                          : () => notifier.purchase(monthly.first),
                    ),
                    const SizedBox(height: 12),
                    _planCard(
                      title: l10n.planYearly,
                      subtitle:
                          yearly.isNotEmpty ? yearly.first.price : l10n.loadingText,
                      onTap: yearly.isEmpty || sub.loading || sub.busy
                          ? null
                          : () => notifier.purchase(yearly.first),
                    ),
                    const SizedBox(height: 12),
                    Card(
                      child: ListTile(
                        leading: const Icon(Icons.restore),
                        title: Text(l10n.restorePurchase),
                        onTap: sub.loading || sub.busy ? null : () => notifier.restore(),
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
                onPressed: sub.busy ? null : () => Navigator.pop(context, false),
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
    required WidgetRef ref,
    required String productId,
  }) async {
    // 让 UI 进入 busy（复用 Notifier 的 busy 管理）
    final notifier = ref.read(subscriptionProvider.notifier);
    final store = ref.read(subscriptionStoreProvider);

    // 这里不走 IAP，直接调用后端 mock verify
    // Android mock：purchase_token = test_ok
    // iOS mock 也可以走 receipt=test_ok（如果你后端支持）
    await notifier.devBusyRun(() async {
      await store.billing.verify(
        platform: 'android',
        productId: productId,
        purchaseToken: 'test_ok',
        clientPayload: {'dev': true},
      );
      await notifier.refresh();
    });
  }

  Future<void> _devExpire({required WidgetRef ref}) async {
    final notifier = ref.read(subscriptionProvider.notifier);
    final store = ref.read(subscriptionStoreProvider);

    await notifier.devBusyRun(() async {
      await store.billing.verify(
        platform: 'android',
        productId: SubscriptionNotifier.monthlyId,
        purchaseToken: 'test_expired',
        clientPayload: {'dev': true},
      );
      await notifier.refresh();
    });
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
