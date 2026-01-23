import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lifebox/l10n/app_localizations.dart';

import '../../../core/widgets/app_scaffold.dart';
import '../state/group_provider.dart';

class GroupManagementPage extends ConsumerStatefulWidget {
  const GroupManagementPage({super.key});

  @override
  ConsumerState<GroupManagementPage> createState() => _GroupManagementPageState();
}

class _GroupManagementPageState extends ConsumerState<GroupManagementPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(groupControllerProvider.notifier).refreshGroups(); // ✅ 每次进来刷新
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final state = ref.watch(groupControllerProvider);
    final groups = state.groups;

    return AppScaffold(
      title: l10n.groupManage,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (state.loading)
            const Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: LinearProgressIndicator(minHeight: 2),
            ),
          if ((state.error ?? '').isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(state.error!, style: const TextStyle(color: Colors.red)),
            ),

          if (groups.isNotEmpty)
            Card(
              child: Column(
                children: [
                  for (int i = 0; i < groups.length; i++) ...[
                    ListTile(
                      title: Text(groups[i].name),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => context.push('/settings/groups/${groups[i].id}'),
                    ),
                    if (i != groups.length - 1) const Divider(height: 1),
                  ],
                ],
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(l10n.nogroup),
            ),

          const SizedBox(height: 12),

          Card(
            child: ListTile(
              title: Text(l10n.groupCreateTitle),
              onTap: () async {
                await context.push('/settings/groups/create');
                // ✅ 从创建页回来再刷新一次，保证立刻看到新 group
                if (!mounted) return;
                ref.read(groupControllerProvider.notifier).refreshGroups();
              },
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              title: Text(l10n.joinGroup),
              onTap: () async {
                await context.push('/settings/groups/join');
                if (!mounted) return;
                ref.read(groupControllerProvider.notifier).refreshGroups();
              },
            ),
          ),
        ],
      ),
    );
  }
}
