import 'package:flutter/material.dart';
import '../../../../core/widgets/app_scaffold.dart';

class ActionPage extends StatelessWidget {
  final String actionType; // calendar / reply / open_link ...
  final String itemId;

  const ActionPage({super.key, required this.actionType, required this.itemId});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: '动作：$actionType',
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('ActionType: $actionType', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                Text('ItemId: $itemId'),
                const SizedBox(height: 16),
                const Text('TODO：这里按 actionType 动态渲染'),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: () {},
                  child: const Text('确认（TODO：调用原生日历/复制模板/外链跳转）'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
