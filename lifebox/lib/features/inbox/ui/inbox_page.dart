import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lifebox/l10n/app_localizations.dart';

import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/risk_badge.dart'; // RiskLevel
import 'inbox_speech_bar.dart';

import '../state/local_inbox_providers.dart';
import '../domain/local_inbox_record.dart';
import 'inbox_calendar_page.dart';

// ✅ 你已有的卡片 & Item 模型
import '../domain/inbox_item.dart';
import 'inbox_card.dart';

class InboxPage extends ConsumerStatefulWidget {
  const InboxPage({super.key});

  @override
  ConsumerState<InboxPage> createState() => _InboxPageState();
}

class _InboxPageState extends ConsumerState<InboxPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tab;
  String _lastSpeechText = '';

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

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

    // LocalInboxRecord.dueAt = "yyyy-mm-dd"（或为空）
    try {
      return DateTime.parse(s);
    } catch (_) {
      return null;
    }
  }

  // ✅ 关键：LocalInboxRecord -> InboxItem（补上你缺的函数）
  InboxItem _toInboxItem(LocalInboxRecord r) {
    // 你现在 InboxItem 定义里有 InboxStatus { high, pending, done }
    // 这里把 record 的 status/risk 映射进去
    final isDone = r.status == 'done';
    final isHighRisk = r.risk == 'high';

    final status = isDone
        ? InboxStatus.done
        : (isHighRisk ? InboxStatus.highRisk : InboxStatus.pending);

    return InboxItem(
      id: r.id,
      title: r.title.isEmpty ? '(No title)' : r.title,
      dueAt: _parseDueAt(r.dueAt),
      risk: _mapRisk(r.risk),
      summary: r.summary,
      amount: r.amount,
      currency: r.currency,
      rawText: r.rawText,
      source: r.sourceHint.isEmpty ? '其他' : r.sourceHint,
      status: status,
      locale: r.locale,
    );
  }

  List<LocalInboxRecord> _sortNewestFirst(List<LocalInboxRecord> list) {
    final copied = [...list];
    copied.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return copied;
  }

  Widget _buildList(
    BuildContext context,
    AppLocalizations l10n,
    List<LocalInboxRecord> records,
  ) {
    if (records.isEmpty) {
      return EmptyState(
        title: l10n.inboxEmptyTitle,
        subtitle: l10n.inboxEmptySubtitle,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 96),
      itemCount: records.length,
      itemBuilder: (context, i) {
        final r = records[i];
        final item = _toInboxItem(r);

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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final asyncList = ref.watch(localInboxListProvider);

    return AppScaffold(
      title: l10n.inboxTitle,
      actions: [
        IconButton(
          tooltip: l10n.tooltipCalendarView,
          icon: const Icon(Icons.calendar_month_outlined),
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const InboxCalendarPage()),
            );
          },
        ),
        IconButton(
          tooltip: l10n.tooltipImport,
          onPressed: () => context.push('/import'),
          icon: const Icon(Icons.add_photo_alternate_outlined),
        ),
        IconButton(
          tooltip: l10n.tooltipSettings,
          onPressed: () => context.push('/settings'),
          icon: const Icon(Icons.settings_outlined),
        ),
      ],
      body: Stack(
        children: [
          asyncList.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text(l10n.error_loading(e.toString()))),
            data: (raw) {
              final list = _sortNewestFirst(raw);

              // ✅ Tab 1：高风险（risk=high 且未 done）
              final highRisk = list
                  .where((e) => e.risk == 'high' && e.status != 'done')
                  .toList();

              // ✅ Tab 2：待办（pending）
              final todo = list.where((e) => e.status == 'pending').toList();

              // ✅ Tab 3：已完成（done）
              final done = list.where((e) => e.status == 'done').toList();

              return Column(
                children: [
                  Material(
                    color: Theme.of(context).colorScheme.surface,
                    child: TabBar(
                      controller: _tab,
                      tabs: [
                        Tab(text: l10n.tabHigh(highRisk.length)),
                        Tab(text: l10n.tabPending(todo.length)),
                        Tab(text: l10n.tabDone(done.length)),
                      ],
                    ),
                  ),
                  Expanded(
                    child: TabBarView(
                      controller: _tab,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        _buildList(context, l10n, highRisk),
                        _buildList(context, l10n, todo),
                        _buildList(context, l10n, done),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),

          // ✅ 底部语音条：保留你现在的行为（仅显示最后文字）
          Positioned(
            left: 16,
            right: 16,
            bottom: 12,
            child: SafeArea(
              top: false,
              child: SpeechFloatingBar(
                localeId: 'zh_CN',
                lastText: _lastSpeechText,
                onFinalText: (text) => setState(() => _lastSpeechText = text),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
