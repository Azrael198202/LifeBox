import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lifebox/features/inbox/ui/inbox_calendar_page.dart';
import 'package:lifebox/l10n/app_localizations.dart';

import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/empty_state.dart';
import 'inbox_speech_bar.dart';

// ✅ 新增
import '../domain/analyze_models.dart';
import '../state/local_inbox_providers.dart';
import 'analyze_confirm_page.dart';

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

  Future<void> _goAnalyzeAndConfirm(BuildContext context, String text) async {
    // ✅ 这里模拟 request（你要求的格式）
    final req = AnalyzeRequest(
      text: text,
      locale: "ja",
      sourceHint: "銀行",
    );

    final ok = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => AnalyzeConfirmPage(request: req)),
    );

    if (ok == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('已保存到本机 Inbox')),
      );
    }
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
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
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
                      onPressed: () async {
                        final finalText = controller.text.trim();
                        if (finalText.isEmpty) return;

                        Navigator.pop(context);
                        await _goAnalyzeAndConfirm(context, finalText);
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

    // ✅ 改为从本地 DB 读取
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
            error: (e, _) => Center(child: Text('加载失败: $e')),
            data: (list) {
              if (list.isEmpty) {
                return EmptyState(
                  title: l10n.inboxEmptyTitle,
                  subtitle: l10n.inboxEmptySubtitle,
                );
              }

              // ✅ 简化：按 risk 分 tab
              List<dynamic> byRisk(String r) =>
                  list.where((e) => e.risk == r).toList();

              Widget listOf(List<dynamic> l) {
                if (l.isEmpty) {
                  return EmptyState(
                    title: l10n.inboxEmptyTitle,
                    subtitle: l10n.inboxEmptySubtitle,
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.only(bottom: 96),
                  itemCount: l.length,
                  itemBuilder: (context, i) {
                    final item = l[i];
                    return ListTile(
                      title: Text(item.title),
                      subtitle: Text(
                        item.summary,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(item.risk, style: const TextStyle(fontWeight: FontWeight.w700)),
                          if (item.dueAt != null) Text(item.dueAt!, style: const TextStyle(fontSize: 12)),
                        ],
                      ),
                    );
                  },
                );
              }

              return Column(
                children: [
                  Material(
                    color: Theme.of(context).colorScheme.surface,
                    child: TabBar(
                      controller: _tab,
                      tabs: [
                        Tab(text: 'High (${byRisk("high").length})'),
                        Tab(text: 'Mid (${byRisk("mid").length})'),
                        Tab(text: 'Low (${byRisk("low").length})'),
                      ],
                    ),
                  ),
                  Expanded(
                    child: TabBarView(
                      controller: _tab,
                      children: [
                        listOf(byRisk("high")),
                        listOf(byRisk("mid")),
                        listOf(byRisk("low")),
                      ],
                    ),
                  ),
                ],
              );
            },
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
