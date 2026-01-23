import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lifebox/features/auth/state/auth_providers.dart';
import 'package:lifebox/features/inbox/state/cloud_inbox_service_provider.dart';
import 'package:lifebox/l10n/app_localizations.dart';

import '../../../app/theme/colors.dart';
import '../../../core/widgets/risk_badge.dart';
import '../domain/inbox_item.dart';
import '../state/local_inbox_providers.dart';

class InboxCard extends ConsumerWidget {
  final InboxItem item;
  final VoidCallback onTap;
  final VoidCallback onPrimaryAction;

  const InboxCard({
    super.key,
    required this.item,
    required this.onTap,
    required this.onPrimaryAction,
  });

  bool get _isDone => item.status == InboxStatus.done;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final dueText =
        item.dueAt == null ? l10n.noDueDate : DateFormat('MM/dd').format(item.dueAt!);

    final db = ref.read(localInboxDbProvider);

    Future<void> _markDone() async {
      await db.updateStatus(item.id, 'done');
      ref.invalidate(localInboxListProvider);
    }

    Future<void> _markTodo() async {
      await db.updateStatus(item.id, 'pending');
      ref.invalidate(localInboxListProvider);
    }

    Future<void> _delete() async {
      await db.deleteById(item.id);

      // Delete Cloud Record if exists
      final cloudId = item.id;
      if (cloudId != null) {
        final cloud = ref.read(cloudInboxServiceProvider);
        final auth = ref.read(authControllerProvider);
        final accessToken = auth.accessToken;
        await cloud.deleteRecordCloud(cloudId, accessToken: accessToken!);
      }

      ref.invalidate(localInboxListProvider);
    }

    Future<bool> _confirmDelete() async {
      final ok = await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          title: Text(l10n.deleteConfirmTitle),
          content: Text(l10n.deleteConfirm),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(l10n.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(l10n.delete),
            ),
          ],
        ),
      );
      return ok == true;
    }

    Future<bool> _onDismiss(DismissDirection dir) async {
      if (dir == DismissDirection.startToEnd) {
        if (_isDone) {
          await _markTodo();
        } else {
          await _markDone();
        }
        return false; // 不让 Dismissible 真正移除
      }

      if (dir == DismissDirection.endToStart) {
        final ok = await _confirmDelete();
        if (ok) await _delete();
        return false;
      }

      return false;
    }

    return Dismissible(
      key: ValueKey('inbox_${item.id}'),
      confirmDismiss: _onDismiss,

      background: _SwipeBackground(
        left: true,
        label: _isDone ? l10n.swipeRestore : l10n.swipeMarkDone,
        icon: _isDone ? Icons.undo : Icons.check_circle_outline,
        color: Colors.green,
      ),

      secondaryBackground: _SwipeBackground(
        left: false,
        label: l10n.delete,
        icon: Icons.delete_outline,
        color: Colors.red,
      ),

      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.title, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Text(
                      l10n.duePrefix(dueText),
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: AppColors.subtext),
                    ),
                    const Spacer(),
                    RiskBadge(risk: item.risk),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.04),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        item.source,
                        style: const TextStyle(
                            fontSize: 12, color: AppColors.subtext),
                      ),
                    ),
                    const Spacer(),
                    SizedBox(
                      height: 34,
                      child: FilledButton.tonal(
                        onPressed: onPrimaryAction,
                        child: Text(l10n.nextStep),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SwipeBackground extends StatelessWidget {
  final bool left;
  final String label;
  final IconData icon;
  final Color color;

  const _SwipeBackground({
    required this.left,
    required this.label,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: left ? Alignment.centerLeft : Alignment.centerRight,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment:
            left ? MainAxisAlignment.start : MainAxisAlignment.end,
        children: [
          if (!left) Text(label,
              style: TextStyle(color: color, fontWeight: FontWeight.w700)),
          if (!left) const SizedBox(width: 8),
          Icon(icon, color: color),
          if (left) const SizedBox(width: 8),
          if (left)
            Text(label,
                style:
                    TextStyle(color: color, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}
