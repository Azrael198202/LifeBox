import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lifebox/l10n/app_localizations.dart';

import '../domain/inbox_item.dart';
import '../state/local_inbox_providers.dart';
import '../domain/local_inbox_record.dart';

import 'inbox_card.dart';
import 'inbox_speech_bar.dart';
import '../../../core/widgets/risk_badge.dart';

class InboxCalendarPage extends ConsumerStatefulWidget {
  const InboxCalendarPage({super.key});

  @override
  ConsumerState<InboxCalendarPage> createState() => _InboxCalendarPageState();
}

class _InboxCalendarPageState extends ConsumerState<InboxCalendarPage> {
  DateTime _month = DateTime(DateTime.now().year, DateTime.now().month, 1);
  DateTime _selectedDay =
      DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);

  String _lastSpeechText = '';

  RiskLevel _mapRisk(String v) {
    switch (v) {
      case 'high':
        return RiskLevel.high;
      case 'mid':
        return RiskLevel.mid;
      case 'low':
      default:
        return RiskLevel.low;
    }
  }

  DateTime? _parseDueAt(String? v) {
    if (v == null) return null;
    final s = v.trim();
    if (s.isEmpty) return null;
    try {
      return DateTime.parse(s); // yyyy-mm-dd
    } catch (_) {
      return null;
    }
  }

  /// ✅ LocalInboxRecord -> InboxItem
  /// - done => InboxStatus.done
  /// - risk=high 且未done => InboxStatus.highRisk
  /// - 其他未done => InboxStatus.pending
  InboxItem _toInboxItem(LocalInboxRecord r) {
    final status = (r.status == 'done')
        ? InboxStatus.done
        : (r.risk == 'high' ? InboxStatus.highRisk : InboxStatus.pending);

    return InboxItem(
      id: r.id,
      title: r.title,
      summary: r.summary,
      rawText: r.rawText,
      locale: r.locale,
      amount: r.amount,
      currency: r.currency,
      dueAt: _parseDueAt(r.dueAt),
      risk: _mapRisk(r.risk),
      source: r.sourceHint,
      status: status,
    );
  }

  bool _isActionable(InboxItem item) {
    // ✅ Calendar 只显示：高风险 + 待办
    return item.status == InboxStatus.highRisk ||
        item.status == InboxStatus.pending;
  }

  Future<void> _pickYearMonth() async {
    final picked = await showDialog<DateTime>(
      context: context,
      builder: (context) {
        final l10n = AppLocalizations.of(context);
        int year = _month.year;
        int month = _month.month;

        return AlertDialog(
          title: Text(l10n.pickYearMonthTitle),
          content: StatefulBuilder(
            builder: (context, setState) {
              return Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      value: year,
                      decoration: InputDecoration(labelText: l10n.yearLabel),
                      items:
                          List.generate(21, (i) => DateTime.now().year - 10 + i)
                              .map((y) =>
                                  DropdownMenuItem(value: y, child: Text('$y')))
                              .toList(),
                      onChanged: (v) => setState(() => year = v ?? year),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      value: month,
                      decoration: InputDecoration(labelText: l10n.monthLabel),
                      items: List.generate(12, (i) => i + 1)
                          .map((m) => DropdownMenuItem(
                                value: m,
                                child: Text(m.toString().padLeft(2, '0')),
                              ))
                          .toList(),
                      onChanged: (v) => setState(() => month = v ?? month),
                    ),
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.common_Cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, DateTime(year, month, 1)),
              child: Text(l10n.confirmAction),
            ),
          ],
        );
      },
    );

    if (picked != null) {
      setState(() {
        _month = DateTime(picked.year, picked.month, 1);
        _selectedDay = DateTime(picked.year, picked.month, 1);
      });
    }
  }

  void _showSpeechResultSheet(BuildContext context, String text) {
    setState(() => _lastSpeechText = text);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) {
        final controller = TextEditingController(text: text);
        final l10n = AppLocalizations.of(context);

        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 8,
            bottom: 16 + MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.speechSheetTitle,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: controller,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: l10n.speechHintEditable,
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        context.push('/import');
                      },
                      icon: const Icon(Icons.add_photo_alternate_outlined),
                      label: Text(l10n.goImport),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () {
                        final finalText = controller.text.trim();
                        if (finalText.isEmpty) return;
                        Navigator.pop(context);

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text(l10n.receivedSnack(finalText))),
                        );
                      },
                      icon: const Icon(Icons.check),
                      label: Text(l10n.confirmAction),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    final asyncList = ref.watch(localInboxListProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.calendarTitle)),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 96),
            child: asyncList.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('加载失败: $e')),
              data: (raw) {
                // ✅ 转换为 InboxItem
                final items = raw.map(_toInboxItem).toList();

                // ✅ 只显示“要处理”的：高风险 + 待办
                final actionable = items.where(_isActionable).toList();

                // ✅ 按日期聚合（只聚合有 dueAt 的）
                final Map<DateTime, List<InboxItem>> byDay = {};
                for (final it in actionable) {
                  final d = it.dueAt;
                  if (d == null) continue;
                  final key = DateTime(d.year, d.month, d.day);
                  byDay.putIfAbsent(key, () => []).add(it);
                }

                final selectedKey = DateTime(
                    _selectedDay.year, _selectedDay.month, _selectedDay.day);
                final selectedItems = byDay[selectedKey] ?? const <InboxItem>[];

                return Column(
                  children: [
                    _MonthHeader(
                      month: _month,
                      onPrev: () => setState(() =>
                          _month = DateTime(_month.year, _month.month - 1, 1)),
                      onNext: () => setState(() =>
                          _month = DateTime(_month.year, _month.month + 1, 1)),
                      onPick: _pickYearMonth,
                    ),
                    const _WeekHeader(),
                    Expanded(
                      flex: 6,
                      child: _MonthGrid(
                        month: _month,
                        selectedDay: _selectedDay,
                        itemsByDay: byDay,
                        onSelect: (d) => setState(() => _selectedDay = d),
                      ),
                    ),
                    const Divider(height: 1),
                    Expanded(
                      flex: 5,
                      child: _SelectedDayList(
                        day: _selectedDay,
                        items: selectedItems,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 12,
            child: SafeArea(
              top: false,
              child: SpeechFloatingBar(
                localeId: 'zh_CN',
                lastText: _lastSpeechText,
                onFinalText: (text) => _showSpeechResultSheet(context, text),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MonthHeader extends StatelessWidget {
  const _MonthHeader({
    required this.month,
    required this.onPrev,
    required this.onNext,
    required this.onPick,
  });

  final DateTime month;
  final VoidCallback onPrev;
  final VoidCallback onNext;
  final Future<void> Function() onPick;

  @override
  Widget build(BuildContext context) {
    final title = '${month.year} / ${month.month.toString().padLeft(2, '0')}';

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 6),
      child: Row(
        children: [
          IconButton(onPressed: onPrev, icon: const Icon(Icons.chevron_left)),
          Expanded(
            child: Center(
              child: InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: () => onPick(),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(width: 6),
                      Icon(Icons.expand_more,
                          size: 18, color: Colors.black.withOpacity(0.55)),
                    ],
                  ),
                ),
              ),
            ),
          ),
          IconButton(onPressed: onNext, icon: const Icon(Icons.chevron_right)),
        ],
      ),
    );
  }
}

class _WeekHeader extends StatelessWidget {
  const _WeekHeader();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final labels = [
      l10n.weekdaySun,
      l10n.weekdayMon,
      l10n.weekdayTue,
      l10n.weekdayWed,
      l10n.weekdayThu,
      l10n.weekdayFri,
      l10n.weekdaySat
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 2, 12, 0),
      child: Row(
        children: labels.asMap().entries.map((entry) {
          final i = entry.key;
          final label = entry.value;
          return Expanded(
            child: Center(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: i == 0
                      ? Colors.redAccent
                      : (i == 6
                          ? Colors.blueAccent
                          : Colors.black.withOpacity(0.6)),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _MonthGrid extends StatelessWidget {
  const _MonthGrid({
    required this.month,
    required this.selectedDay,
    required this.itemsByDay,
    required this.onSelect,
  });

  final DateTime month;
  final DateTime selectedDay;
  final Map<DateTime, List<InboxItem>> itemsByDay;
  final ValueChanged<DateTime> onSelect;

  @override
  Widget build(BuildContext context) {
    final first = DateTime(month.year, month.month, 1);

    // ✅ 周日开头：Sunday = 0
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
          if (dayNum < 1 || dayNum > daysInMonth)
            return const SizedBox.shrink();

          final d = DateTime(month.year, month.month, dayNum);
          final key = DateTime(d.year, d.month, d.day);

          final weekday = d.weekday;
          final isSunday = weekday == DateTime.sunday;
          final isSaturday = weekday == DateTime.saturday;

          final count = itemsByDay[key]?.length ?? 0;
          final isToday = key == todayKey;
          final isSelected = key == selectedKey;

          final bg = isSelected
              ? Theme.of(context).colorScheme.primary.withOpacity(0.12)
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
                        color: isSunday
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
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _SelectedDayList extends StatelessWidget {
  const _SelectedDayList({
    required this.day,
    required this.items,
  });

  final DateTime day;
  final List<InboxItem> items;

  @override
  Widget build(BuildContext context) {
    final title =
        '${day.year}/${day.month.toString().padLeft(2, '0')}/${day.day.toString().padLeft(2, '0')}';

    final l10n = AppLocalizations.of(context);

    if (items.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.dayItemsTitle(title),
                style: const TextStyle(fontWeight: FontWeight.w700)),
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
          // onDelete: () async {
          //   // TODO: 调用 db.delete(item.id) 然后 ref.invalidate(localInboxListProvider)
          // },
          // onMarkDone: () async {
          //   // TODO: db.upsert(status='done') 然后 invalidate
          // },
          // onMarkTodo: () async {
          //   // TODO: db.upsert(status='pending') 然后 invalidate
          // },
        );
      },
    );
  }
}
