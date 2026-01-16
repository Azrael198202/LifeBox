import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:lifebox/l10n/app_localizations.dart';

import '../../../app/theme/colors.dart';
import '../../../core/widgets/risk_badge.dart';
import '../domain/inbox_item.dart';

class InboxCard extends StatelessWidget {
  final InboxItem item;

  /// 点卡片进入详情
  final VoidCallback onTap;

  /// “下一步”按钮
  final VoidCallback onPrimaryAction;

  /// ✅ 追加：滑动操作（可选）
  final VoidCallback? onDelete;
  final VoidCallback? onMarkDone;
  final VoidCallback? onMarkTodo;

  /// ✅ 是否启用滑动（默认 true）
  final bool slidableEnabled;

  const InboxCard({
    super.key,
    required this.item,
    required this.onTap,
    required this.onPrimaryAction,
    this.onDelete,
    this.onMarkDone,
    this.onMarkTodo,
    this.slidableEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final dueText =
        item.dueAt == null ? l10n.noDueDate : DateFormat('MM/dd').format(item.dueAt!);

    final card = Card(
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
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.04),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      item.source,
                      style: const TextStyle(fontSize: 12, color: AppColors.subtext),
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
    );

    // ✅ 没启用滑动 or 没提供任何操作 -> 直接返回卡片
    final hasAnyAction = (onDelete != null) || (onMarkDone != null) || (onMarkTodo != null);
    if (!slidableEnabled || !hasAnyAction) {
      return card;
    }

    // ✅ 右侧动作（最常用：删除 / 完成）
    final endActions = <Widget>[
      if (onMarkDone != null)
        SlidableAction(
          onPressed: (_) => onMarkDone!(),
          icon: Icons.check_circle_outline,
          label: l10n.inboxDetailMarkDoneTodo, // 你已有的文言就用它；没有就换成 '完成'
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
          borderRadius: BorderRadius.circular(14),
        ),
      if (onDelete != null)
        SlidableAction(
          onPressed: (_) => onDelete!(),
          icon: Icons.delete_outline,
          label: MaterialLocalizations.of(context).deleteButtonTooltip,
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
          borderRadius: BorderRadius.circular(14),
        ),
    ];

    // ✅ 左侧动作（可选：恢复为待办）
    final startActions = <Widget>[
      if (onMarkTodo != null)
        SlidableAction(
          onPressed: (_) => onMarkTodo!(),
          icon: Icons.undo,
          label: '待办',
          backgroundColor: Colors.blueGrey,
          foregroundColor: Colors.white,
          borderRadius: BorderRadius.circular(14),
        ),
    ];

    return Slidable(
      key: ValueKey(item.id),
      // 左侧动作（向右滑）
      startActionPane: startActions.isEmpty
          ? null
          : ActionPane(
              motion: const DrawerMotion(),
              extentRatio: 0.28,
              children: startActions,
            ),
      // 右侧动作（向左滑）
      endActionPane: endActions.isEmpty
          ? null
          : ActionPane(
              motion: const DrawerMotion(),
              extentRatio: endActions.length == 1 ? 0.28 : 0.52,
              children: endActions,
            ),
      child: card,
    );
  }
}
