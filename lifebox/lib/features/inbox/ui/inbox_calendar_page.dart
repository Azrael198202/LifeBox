import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../domain/inbox_item.dart';
import '../state/inbox_providers.dart';
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

  // ✅ 语音最近文本（用于浮条显示）
  String _lastSpeechText = '';

  Future<void> _pickYearMonth() async {
    final picked = await showDialog<DateTime>(
      context: context,
      builder: (context) {
        int year = _month.year;
        int month = _month.month;

        return AlertDialog(
          title: const Text('选择年月'),
          content: StatefulBuilder(
            builder: (context, setState) {
              return Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      value: year,
                      decoration: const InputDecoration(labelText: '年'),
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
                      decoration: const InputDecoration(labelText: '月'),
                      items: List.generate(12, (i) => i + 1)
                          .map((m) => DropdownMenuItem(
                              value: m,
                              child: Text(m.toString().padLeft(2, '0'))))
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
              child: const Text('取消'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, DateTime(year, month, 1)),
              child: const Text('确定'),
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
              const Text(
                '语音识别内容',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: controller,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: '识别结果会显示在这里，可编辑',
                  border: OutlineInputBorder(),
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
                      label: const Text('去导入'),
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
                          SnackBar(content: Text('已收到：$finalText')),
                        );
                      },
                      icon: const Icon(Icons.check),
                      label: const Text('确认'),
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
    final List<InboxItem> items = ref.watch(inboxItemsProvider);

    // ✅ 只显示“要处理”的：高优先 + 待处理
    final actionable = items.where(_isActionable).toList();

    // 按日期聚合（只聚合有 dueAt 的）
    final Map<DateTime, List<InboxItem>> byDay = {};
    for (final it in actionable) {
      final d = it.dueAt;
      if (d == null) continue;
      final key = DateTime(d.year, d.month, d.day);
      byDay.putIfAbsent(key, () => []).add(it);
    }

    final selectedKey =
        DateTime(_selectedDay.year, _selectedDay.month, _selectedDay.day);
    final selectedItems = byDay[selectedKey] ?? const <InboxItem>[];

    return Scaffold(
      appBar: AppBar(title: const Text('日历')),
      body: Stack(
        children: [
          // ✅ 主体内容（给底部浮条预留空间）
          Padding(
            padding: const EdgeInsets.only(bottom: 96),
            child: Column(
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
            ),
          ),

          // ✅ 底部悬浮语音按钮（组件就在本文件底部）
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

  bool _isActionable(InboxItem item) {
    return item.status == InboxStatus.pending || item.status == InboxStatus.high;
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
    final labels = ['日', '一', '二', '三', '四', '五', '六'];
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
        padding: EdgeInsets.zero, // ✅ 让标题和第一行更贴近
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

          final weekday = d.weekday; // Mon=1 ... Sun=7
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

    if (items.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('当天事项：$title',
                style: const TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text('这一天没有设置截止日期的事项。',
                style: TextStyle(color: Colors.black.withOpacity(0.6))),
            const SizedBox(height: 8),
            Text('提示：给事项设置截止日期后会显示在日历里。',
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
