import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lifebox/l10n/app_localizations.dart';

import '../../../core/widgets/app_scaffold.dart';
import '../../../app/theme/colors.dart';
import '../state/inbox_providers.dart';

class InboxDetailPage extends ConsumerWidget {
  final String id;
  const InboxDetailPage({super.key, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(inboxItemsProvider);
    final item = items.firstWhere((e) => e.id == id);
    final l10n = AppLocalizations.of(context);

    return AppScaffold(
      title: l10n.inboxDetailTitle,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.title, style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 10),
                  Text(l10n.inboxDetailSource(item.source), style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.subtext)),
                  const SizedBox(height: 6),
                  Text(l10n.inboxDetailThumbnailPlaceholder, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.subtext)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.inboxDetailStructuredFields, style: Theme.of(context).textTheme.titleMedium),
                  SizedBox(height: 10),
                  Text(l10n.inboxDetailDueTodo),
                  Text(l10n.inboxDetailAmountTodo),
                  Text(l10n.inboxDetailPhoneUrlTodo),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: () => context.push('/action?type=calendar&id=$id'),
                    child: Text(l10n.inboxDetailPrimaryActionAddCalendar),
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton(
                    onPressed: () {},
                    child: Text(l10n.inboxDetailMarkDoneTodo),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          ExpansionTile(
            title: Text(l10n.inboxDetailEvidenceTitle),
            childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            children: [
              Text(l10n.inboxDetailOcrPlaceholder),
            ],
          ),
        ],
      ),
    );
  }
}
