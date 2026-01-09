import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/hold_to_talk_button.dart';
import '../domain/inbox_item.dart';
import '../state/inbox_providers.dart';
import 'inbox_card.dart';

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
                        // 你也可以做成“把文本带去 import 页作为搜索/备注”
                        Navigator.pop(context);
                        context.push('/import'); // 先简单跳导入
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

                        // ✅ 如果你想把语音作为 inbox item 新增：
                        // 这里我不强行写入（因为你 providers 的写入 API 我没看到）
                        // 你可以在 inbox_providers.dart 里提供 addSpeechItem(finalText)
                        // 然后在这里调用。
                        //
                        // 示例（你实现后打开这行）：
                        // ref.read(inboxActionsProvider).addSpeech(finalText);

                        Navigator.pop(context);

                        // 临时：只做一个 SnackBar
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
            onPrimaryAction: () => context.push('/action?type=calendar&id=${item.id}'),
          );
        },
      );
    }

    return AppScaffold(
      title: 'Life Inbox',
      actions: [
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

          // ✅ 底部悬浮语音按钮
          Positioned(
            left: 16,
            right: 16,
            bottom: 12,
            child: SafeArea(
              top: false,
              child: _SpeechFloatingBar(
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

class _SpeechFloatingBar extends StatelessWidget {
  const _SpeechFloatingBar({
    required this.lastText,
    required this.onFinalText,
  });

  final String lastText;
  final void Function(String text) onFinalText;

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 8,
      borderRadius: BorderRadius.circular(18),
      color: Theme.of(context).colorScheme.surface,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.black.withOpacity(0.06)),
        ),
        child: Row(
          children: [
            // 按住说话按钮（你已有组件）
            HoldToTalkButton(
              // 需要日语：'ja_JP'，中文：'zh_CN'
              localeId: 'zh_CN',
              onFinalText: onFinalText,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                lastText.isEmpty ? '按住语音，说完松开即可生成文字' : '最近：$lastText',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.black.withOpacity(0.72),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
