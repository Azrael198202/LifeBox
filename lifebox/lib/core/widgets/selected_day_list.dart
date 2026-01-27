import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lifebox/core/services/holiday_service.dart';
import 'package:lifebox/features/inbox/domain/inbox_item.dart';
import 'package:lifebox/features/inbox/ui/inbox_card.dart';
import 'package:lifebox/l10n/app_localizations.dart';

class SelectedDayList extends StatelessWidget {
  const SelectedDayList({
    super.key,
    required this.day,
    required this.items,
    required this.holidays,
    required this.locale,
  });

  final DateTime day;
  final List<InboxItem> items;

  final List<Holiday> holidays;
  final Locale locale;

  @override
  Widget build(BuildContext context) {
    final title =
        '${day.year}/${day.month.toString().padLeft(2, '0')}/${day.day.toString().padLeft(2, '0')}';

    Widget holidayHeader(AppLocalizations l10n) {
      if (holidays.isEmpty) return const SizedBox.shrink();

      final names = holidays.map((h) {
        final flag = h.countryCode == 'JP'
            ? '🇯🇵'
            : (h.countryCode == 'CN' ? '🇨🇳' : '');
        return '$flag ${h.displayName(locale)}';
      }).join(' / ');

      return Container(
        margin: const EdgeInsets.only(top: 8, bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.06),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.red.withOpacity(0.12)),
        ),
        child: Row(
          children: [
            Text(l10n.holidayLabel,
                style: const TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                names,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      );
    }

    final l10n = AppLocalizations.of(context);

    if (items.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.dayItemsTitle(title),
                style: const TextStyle(fontWeight: FontWeight.w700)),
            holidayHeader(l10n),
            const SizedBox(height: 8),
            Text(l10n.noDueItemsForDay,
                style: TextStyle(color: Colors.black.withOpacity(0.6))),
            const SizedBox(height: 8),
            Text(l10n.setDueHint,
                style: TextStyle(
                    color: Colors.black.withOpacity(0.45), fontSize: 12)),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(12),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, i) {
        final item = items[i];
        return InboxCard(
          item: item,
          onTap: () => context.push('/inbox/detail/${item.id}'),
          onPrimaryAction: () =>
              context.push('/action?type=calendar&id=${item.id}'),
        );
      },
    );
  }
}