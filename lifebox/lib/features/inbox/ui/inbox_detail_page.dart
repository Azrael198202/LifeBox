import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../app/theme/colors.dart';
import '../state/inbox_providers.dart';

class InboxDetailPage extends ConsumerWidget {
  final String id;
  const InboxDetailPage({super.key, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(inboxItemsProvider);
    final item = items.firstWhere((e) => e.id == id);

    return AppScaffold(
      title: '详情',
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.title, style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 10),
                  Text('来源：${item.source}', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.subtext)),
                  const SizedBox(height: 6),
                  Text('（这里未来放缩略图/来源图）', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.subtext)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('结构化字段', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 10),
                  const Text('截止日期：TODO'),
                  const Text('金额：TODO'),
                  const Text('电话/URL：TODO'),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: () => context.push('/action?type=calendar&id=$id'),
                    child: const Text('主动作：加入日历'),
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton(
                    onPressed: () {},
                    child: const Text('标记完成（TODO）'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          ExpansionTile(
            title: const Text('解析依据（OCR 片段）'),
            childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            children: const [
              Text('OCR: ...（后续接入本地 OCR 缓存并展示）'),
            ],
          ),
        ],
      ),
    );
  }
}
