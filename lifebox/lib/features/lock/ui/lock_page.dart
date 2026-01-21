import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lifebox/l10n/app_localizations.dart';

import '../../../core/services/app_lock.dart';

class LockPage extends ConsumerWidget {
  const LockPage({super.key, this.from});

  /// router 传入的回跳地址（Uri.encodeComponent 过）
  final String? from;

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.lockPageTitle)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.lock_outline, size: 56),
              const SizedBox(height: 10),
              Text(l10n.lockPageNeedUnlock, style: TextStyle(fontSize: 16)),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: () async {
                  ref.read(appLockProvider.notifier).unlock();

                  final target =
                      from != null ? Uri.decodeComponent(from!) : '/inbox';

                  context.go(target);
                },
                icon: const Icon(Icons.lock_open),
                label: Text(l10n.unlock),
              ),
              if (from != null) ...[
                const SizedBox(height: 12),
                Text(
                  l10n.unlockReturnTo(Uri.decodeComponent(from!)),
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
