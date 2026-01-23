import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lifebox/core/services/holiday_service.dart';
import 'package:lifebox/core/widgets/risk_badge.dart';
import 'package:lifebox/features/inbox/state/inbox_providers.dart';
import 'package:lifebox/l10n/app_localizations.dart';

import '../domain/inbox_item.dart';
import '../domain/local_inbox_record.dart';
import '../state/local_inbox_providers.dart';

import '../../../core/widgets/month_grid.dart';
import '../../../core/widgets/month_header.dart';
import '../../../core/widgets/week_header.dart';
import '../../../core/widgets/selected_day_list.dart';

import 'inbox_card.dart';
import 'inbox_speech_bar.dart';

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

  InboxItem _toInboxItem(LocalInboxRecord r) {
    final l10n = AppLocalizations.of(context);

    final isDone = r.status == 'done';
    final isHighRisk = r.risk == 'high';

    final status = isDone
        ? InboxStatus.done
        : (isHighRisk ? InboxStatus.highRisk : InboxStatus.pending);

    return InboxItem(
      id: r.id,               // UI key
      localId: r.id,          // ✅ 本地一定有
      cloudId: r.cloudId,     // ✅ 可能为 null
      title: r.title.isEmpty ? l10n.no_title : r.title,
      dueAt: _parseDueAt(r.dueAt),
      risk: _mapRisk(r.risk),
      summary: r.summary,
      amount: r.amount,
      currency: r.currency,
      rawText: r.rawText,
      sourceHint: r.sourceHint.isEmpty ? l10n.another : r.sourceHint,
      status: status,
      locale: r.locale,
      sourceType: InboxSourceType.local,
      createdAt: r.createdAt,
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
              child: Text(l10n.cancel),
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

    final locale = Localizations.localeOf(context);
    final holidayAsync = ref.watch(cnJpHolidaysByYearProvider(_month.year));

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

                final holidaysByDay = holidayAsync.maybeWhen(
                  data: (m) => m,
                  orElse: () => const <DateTime, List<Holiday>>{},
                );

                return Column(
                  children: [
                    if (holidayAsync.isLoading)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Text(
                          l10n.holidaysLoading,
                          style: TextStyle(
                              fontSize: 12,
                              color: Colors.black.withOpacity(0.5)),
                        ),
                      ),
                    MonthHeader(
                      month: _month,
                      onPrev: () => setState(() =>
                          _month = DateTime(_month.year, _month.month - 1, 1)),
                      onNext: () => setState(() =>
                          _month = DateTime(_month.year, _month.month + 1, 1)),
                      onPick: _pickYearMonth,
                    ),
                    const WeekHeader(),
                    Expanded(
                      flex: 6,
                      child: MonthGrid(
                        month: _month,
                        selectedDay: _selectedDay,
                        itemsByDay: byDay,
                        holidaysByDay: holidaysByDay,
                        locale: locale,
                        onSelect: (d) => setState(() => _selectedDay = d),
                      ),
                    ),
                    const Divider(height: 1),
                    Expanded(
                      flex: 5,
                      child: SelectedDayList(
                        day: _selectedDay,
                        items: selectedItems,
                        holidays: holidaysByDay[selectedKey] ?? const [],
                        locale: locale,
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
