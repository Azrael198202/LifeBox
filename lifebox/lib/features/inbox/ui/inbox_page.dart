import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lifebox/features/inbox/ui/inbox_calendar_page.dart';

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
    final items = ref.watch(inboxItemsProvider);

    List<InboxItem> by(InboxStatus s) =>
        items.where((e) => e.status == s).toList();

    Widget listOf(List<InboxItem> list) {
      if (list.isEmpty) {
        return const EmptyState(
          title: '这里还没有内容',
          subtitle: '去导入截图或按住语音开始吧',
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
      title: 'Life Inbox',
      actions: [
        IconButton(
          tooltip: '日历视图',
          icon: const Icon(Icons.calendar_month_outlined),
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const InboxCalendarPage()),
            );
          },
        ),
        IconButton(
          tooltip: '导入',
          onPressed: () => context.push('/import'),
          icon: const Icon(Icons.add_photo_alternate_outlined),
        ),
        IconButton(
          tooltip: '设置',
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
                    Tab(text: '高优先 (${by(InboxStatus.high).length})'),
                    Tab(text: '待处理 (${by(InboxStatus.pending).length})'),
                    Tab(text: '已完成 (${by(InboxStatus.done).length})'),
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
