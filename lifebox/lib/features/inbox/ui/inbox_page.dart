import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/empty_state.dart';
import '../domain/inbox_item.dart';
import '../state/inbox_providers.dart';
import 'inbox_card.dart';

class InboxPage extends ConsumerStatefulWidget {
  const InboxPage({super.key});

  @override
  ConsumerState<InboxPage> createState() => _InboxPageState();
}

class _InboxPageState extends ConsumerState<InboxPage> with SingleTickerProviderStateMixin {
  late final TabController _tab;

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

  @override
  Widget build(BuildContext context) {
    final items = ref.watch(inboxItemsProvider);

    List<InboxItem> by(InboxStatus s) => items.where((e) => e.status == s).toList();

    Widget listOf(List<InboxItem> list) {
      if (list.isEmpty) return const EmptyState(title: '这里还没有内容', subtitle: '去导入截图开始吧');
      return ListView.builder(
        itemCount: list.length,
        itemBuilder: (context, i) {
          final item = list[i];
          return InboxCard(
            item: item,
            onTap: () => context.go('/inbox/detail/${item.id}'),
            onPrimaryAction: () => context.go('/action?type=calendar&id=${item.id}'),
          );
        },
      );
    }

    return AppScaffold(
      title: 'Life Inbox',
      actions: [
        IconButton(
          tooltip: '导入',
          onPressed: () => context.go('/import'),
          icon: const Icon(Icons.add_photo_alternate_outlined),
        ),
        IconButton(
          tooltip: '设置',
          onPressed: () => context.go('/settings'),
          icon: const Icon(Icons.settings_outlined),
        ),
      ],
      body: Column(
        children: [
          Material(
            color: Colors.white,
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
    );
  }
}
