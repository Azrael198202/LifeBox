import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lifebox/l10n/app_localizations.dart';

import '../../../app/theme/colors.dart';
import '../../../core/widgets/risk_badge.dart';
import '../domain/inbox_item.dart';

class InboxCard extends StatelessWidget {
  final InboxItem item;
  final VoidCallback onTap;
  final VoidCallback onPrimaryAction;

  const InboxCard({
    super.key,
    required this.item,
    required this.onTap,
    required this.onPrimaryAction,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final dueText = item.dueAt == null ? l10n.noDueDate : DateFormat('MM/dd').format(item.dueAt!);

    return Card(
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
                  Text(l10n.duePrefix(dueText), style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.subtext)),
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
                    child: Text(item.source, style: const TextStyle(fontSize: 12, color: AppColors.subtext)),
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
  }
}
