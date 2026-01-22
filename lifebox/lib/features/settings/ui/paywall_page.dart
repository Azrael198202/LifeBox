import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lifebox/l10n/app_localizations.dart';
import '../state/subscription_providers.dart';

class PaywallPage extends ConsumerWidget {
  const PaywallPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sub = ref.watch(subscriptionProvider);
    final store = ref.watch(subscriptionStoreProvider);
    final l10n = AppLocalizations.of(context);

    final products = sub.products;
    final monthly = products.where((p) => p.id == 'lifebox_premium_monthly').toList();
    final yearly = products.where((p) => p.id == 'lifebox_premium_yearly').toList();

    // 已订阅：直接允许返回 true
    if (sub.subscribed) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pop(context, true);
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.paywallTitle),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 8),
            Text(
              l10n.paywallDesc,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black54),
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
                  _planCard(
                    title: l10n.planMonthly,
                    subtitle: monthly.isNotEmpty
                        ? monthly.first.price
                        : l10n.loadingText,
                    onTap: monthly.isEmpty || sub.loading || sub.busy
                        ? null
                        : () => store.purchase(monthly.first),
                  ),
                  const SizedBox(height: 12),
                  _planCard(
                    title: l10n.planYearly,
                    subtitle: yearly.isNotEmpty
                        ? yearly.first.price
                        : l10n.loadingText,
                    onTap: yearly.isEmpty || sub.loading
                        ? null
                        : () => store.purchase(yearly.first),
                  ),
                  const SizedBox(height: 12),
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.restore),
                      title: Text(l10n.restorePurchase),
                      onTap: sub.loading ? null : () => store.restore(),
                    ),
                  ),

                  const SizedBox(height: 12),
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
                onPressed: () => Navigator.pop(context, false),
                child: Text(l10n.notNow),
              ),
            ),
          ],
        ),
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
