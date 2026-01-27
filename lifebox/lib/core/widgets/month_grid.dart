import 'package:flutter/material.dart';
import 'package:lifebox/core/services/holiday_service.dart';
import 'package:lifebox/features/inbox/domain/inbox_item.dart';
import 'package:lifebox/l10n/app_localizations.dart';

class MonthGrid extends StatelessWidget {
  const MonthGrid({
    super.key,
    required this.month,
    required this.selectedDay,
    required this.itemsByDay,
    required this.holidaysByDay,
    required this.locale,
    required this.onSelect,
  });

  final DateTime month;
  final DateTime selectedDay;
  final Map<DateTime, List<InboxItem>> itemsByDay;
  final ValueChanged<DateTime> onSelect;

  final Map<DateTime, List<Holiday>> holidaysByDay; // ✅
  final Locale locale;

  @override
  Widget build(BuildContext context) {
    final first = DateTime(month.year, month.month, 1);
    final l10n = AppLocalizations.of(context);

    // Sunday as 0, Saturday as 6
    final firstWeekday = first.weekday % 7;

    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final totalCells = ((firstWeekday + daysInMonth) <= 35) ? 35 : 42;

    final now = DateTime.now();
    final todayKey = DateTime(now.year, now.month, now.day);
    final selectedKey =
        DateTime(selectedDay.year, selectedDay.month, selectedDay.day);

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 2, 12, 12),
      child: GridView.builder(
        padding: EdgeInsets.zero,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 7,
          mainAxisSpacing: 6,
          crossAxisSpacing: 8,
        ),
        itemCount: totalCells,
        itemBuilder: (context, index) {
          final dayNum = index - firstWeekday + 1;
          if (dayNum < 1 || dayNum > daysInMonth) {
            return const SizedBox.shrink();
          }

          final d = DateTime(month.year, month.month, dayNum);
          final key = DateTime(d.year, d.month, d.day);

          final holidays = holidaysByDay[key] ?? const <Holiday>[];
          final isHoliday = holidays.isNotEmpty;

          String holidayTooltip() {
            // e.g. "🇯🇵 元日 / 🇨🇳 元旦"
            return holidays.map((h) {
              final flag = h.countryCode == 'JP'
                  ? '🇯🇵'
                  : (h.countryCode == 'CN' ? '🇨🇳' : '');
              return '$flag ${h.displayName(locale)}';
            }).join(' / ');
          }

          final weekday = d.weekday;
          final isSunday = weekday == DateTime.sunday;
          final isSaturday = weekday == DateTime.saturday;

          final count = itemsByDay[key]?.length ?? 0;
          final isToday = key == todayKey;
          final isSelected = key == selectedKey;

          final bg = 
              isToday
              ? Colors.blue.withOpacity(0.62)
              : isSelected
              // ? Theme.of(context).colorScheme.primary.withOpacity(0.12)
              ? Colors.green.withOpacity(0.32)
              : isHoliday
                  ? Colors.red.withOpacity(0.06)
                  : isSunday
                      ? Colors.red.withOpacity(0.04)
                      : isSaturday
                          ? Colors.blue.withOpacity(0.04)
                          : Colors.black.withOpacity(0.03);

          return InkWell(
            onTap: () => onSelect(d),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isToday
                      ? Theme.of(context).colorScheme.primary
                      : Colors.transparent,
                  width: isToday ? 1.2 : 1,
                ),
              ),
              child: Stack(
                children: [
                  Positioned(
                    left: 8,
                    top: 8,
                    child: Text(
                      '$dayNum',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: isSunday || isHoliday
                            ? Colors.redAccent
                            : isSaturday
                                ? Colors.blueAccent
                                : (isSelected
                                    ? Theme.of(context).colorScheme.primary
                                    : Colors.black.withOpacity(0.85)),
                      ),
                    ),
                  ),
                  if (count > 0)
                    Positioned(
                      right: 6,
                      bottom: 6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .primary
                              .withOpacity(0.18),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          '$count',
                          style: const TextStyle(
                              fontSize: 11, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                  if (isHoliday)
                    Positioned(
                      right: 2,
                      top: 2,
                      child: Tooltip(
                        message: holidayTooltip(),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          // decoration: BoxDecoration(
                          //   color: Colors.red.withOpacity(0.18),
                          //   borderRadius: BorderRadius.circular(999),
                          // ),
                          child: Text(
                            l10n.holidayShort, // ✅ l10n
                            style: const TextStyle(
                                fontSize: 10, fontWeight: FontWeight.w800,color: Colors.redAccent),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}