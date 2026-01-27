import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lifebox/core/widgets/risk_badge.dart';
import 'package:lifebox/features/inbox/state/merged_inbox_provider.dart';
import 'package:lifebox/l10n/app_localizations.dart';

import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/empty_state.dart';
import 'inbox_speech_bar.dart';
import 'inbox_calendar_page.dart';

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
  // =============================
  // InboxItem
  // （只负责“展示层”，不做业务判断）
  // =============================
  InboxItem _toInboxItem(InboxItem r) {
    final l10n = AppLocalizations.of(context);

    final isDone = r.status == InboxStatus.done;
    final isHighRisk = r.risk == RiskLevel.high;

    final status = isDone
        ? InboxStatus.done
        : (isHighRisk ? InboxStatus.high : InboxStatus.pending);

    return InboxItem(
      id: r.id,               // UI key
      localId: r.id,          // ✅ 本地一定有
      cloudId: r.cloudId,     // ✅ 可能为 null
      title: r.title.isEmpty ? l10n.no_title : r.title,
      dueAt: r.dueAt,
      risk: r.risk,
      summary: r.summary,
      amount: r.amount,
      currency: r.currency,
      rawText: r.rawText,
      sourceHint: r.sourceHint.isEmpty ? l10n.another : r.sourceHint,
      status: status,
      locale: r.locale,
      sourceType: InboxSourceType.local,
      createdAt: r.createdAt, // ✅
    );
  }

  List<InboxItem> _sortNewestFirst(List<InboxItem> list) {
    final copied = [...list];
    copied.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return copied;
  }

  // =============================
  // List Builder
  // =============================
  Widget _buildList(
    BuildContext context,
    AppLocalizations l10n,
    List<InboxItem> records,
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
        );
      },
    );
  }

  // =============================
  // Build
  // =============================
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    final asyncList = ref.watch(mergedInboxProvider);

    return AppScaffold(
      title: l10n.inboxTitle,
      subtitle: l10n.inboxSubtitle,
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
            loading: () =>
                const Center(child: CircularProgressIndicator()),
            error: (e, _) =>
                Center(child: Text(l10n.error_loading(e.toString()))),
            data: (raw) {
              final list = _sortNewestFirst(raw);

              // Tab 1：高风险（high & not done）
              final highRisk = list
                  .where((e) => e.risk.name == 'high' && e.status.name != 'done')
                  .toList();

              // Tab 2：待办
              final todo =
                  list.where((e) => e.status.name == 'pending').toList();

              // Tab 3：已完成
              final done =
                  list.where((e) => e.status.name == 'done').toList();

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
                      physics:
                          const NeverScrollableScrollPhysics(),
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

          // =============================
          // Bottom Speech Bar
          // =============================
          Positioned(
            left: 16,
            right: 16,
            bottom: 12,
            child: SafeArea(
              top: false,
              child: SpeechFloatingBar(
                localeId: 'zh_CN',
                lastText: _lastSpeechText,
                onFinalText: (text) =>
                    setState(() => _lastSpeechText = text),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
