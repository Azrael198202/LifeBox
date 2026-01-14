import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lifebox/features/inbox/ui/inbox_calendar_page.dart';
import 'package:lifebox/l10n/app_localizations.dart';

import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/empty_state.dart';
import '../domain/inbox_item.dart';
import '../state/inbox_providers.dart';
import 'inbox_card.dart';
import 'inbox_speech_bar.dart';

class InboxPage extends ConsumerStatefulWidget {
  const InboxPage({super.key});

  @override
  ConsumerState<InboxPage> createState() => _InboxPageState();
}

class _InboxPageState extends ConsumerState<InboxPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tab;

  // ✅ 保存最近一次识别文本（用于 UI 显示）
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

  void _showSpeechResultSheet(BuildContext context, String text) {
    setState(() => _lastSpeechText = text);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) {

        final l10n = AppLocalizations.of(context);
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
              Text(
                l10n.speechSheetTitle,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: controller,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: l10n.speechHintEditable,
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
                          SnackBar(content: Text(l10n.receivedSnack(finalText)),
                        ));
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
    final items = ref.watch(inboxItemsProvider);
    final l10n = AppLocalizations.of(context);

    List<InboxItem> by(InboxStatus s) =>
        items.where((e) => e.status == s).toList();

    Widget listOf(List<InboxItem> list) {
      if (list.isEmpty) {
        return EmptyState(
          title: l10n.inboxEmptyTitle,
          subtitle: l10n.inboxEmptySubtitle,
        );
      }
      return ListView.builder(
        padding: const EdgeInsets.only(bottom: 96), // ✅ 给底部悬浮按钮留空间
        itemCount: list.length,
        itemBuilder: (context, i) {
          final item = list[i];
          return InboxCard(
            item: item,
            onTap: () => context.push('/inbox/detail/${item.id}'),
            onPrimaryAction: () =>
                context.push('/action?type=calendar&id=${item.id}'),
          );
        },
      );
    }

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
          // 主体内容
          Column(
            children: [
              Material(
                color: Theme.of(context).colorScheme.surface,
                child: TabBar(
                  controller: _tab,
                  tabs: [
                    Tab(text: l10n.tabHigh(by(InboxStatus.high).length)),
                    Tab(text: l10n.tabPending(by(InboxStatus.pending).length)),
                    Tab(text: l10n.tabDone(by(InboxStatus.done).length)),
                  ],
                ),
              ),
              Expanded(
                child: TabBarView(
                  controller: _tab,
                  children: [
                    listOf(by(InboxStatus.high)),
                    listOf(by(InboxStatus.pending)),
                    listOf(by(InboxStatus.done)),
                  ],
                ),
              ),
            ],
          ),

          // ✅ 底部悬浮语音按钮（组件来自 inbox_calendar_page.dart）
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
