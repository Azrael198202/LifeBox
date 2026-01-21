import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/subscription_providers.dart';

class PaywallPage extends ConsumerWidget {
  const PaywallPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sub = ref.watch(subscriptionProvider);
    final store = ref.watch(subscriptionStoreProvider);

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
        title: const Text('プレミアム（有料）'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 8),
            const Text(
              'グループ管理・クラウド保存などの機能を利用するには\nプレミアム登録が必要です。',
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
                    title: '月額プラン',
                    subtitle: monthly.isNotEmpty
                        ? monthly.first.price
                        : '読み込み中...',
                    onTap: monthly.isEmpty || sub.loading
                        ? null
                        : () => store.purchase(monthly.first),
                  ),
                  const SizedBox(height: 12),
                  _planCard(
                    title: '年額プラン',
                    subtitle: yearly.isNotEmpty
                        ? yearly.first.price
                        : '読み込み中...',
                    onTap: yearly.isEmpty || sub.loading
                        ? null
                        : () => store.purchase(yearly.first),
                  ),
                  const SizedBox(height: 12),
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.restore),
                      title: const Text('購入を復元（Restore）'),
                      onTap: sub.loading ? null : () => store.restore(),
                    ),
                  ),

                  const SizedBox(height: 12),
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.help_outline),
                      title: const Text('解約はApp Store / Google Playのサブスク管理から'),
                      subtitle: const Text('アプリ内では解約できません'),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('今はしない'),
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
