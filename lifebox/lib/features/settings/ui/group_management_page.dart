import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lifebox/l10n/app_localizations.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../auth/state/auth_providers.dart';

class GroupManagementPage extends ConsumerWidget {
  const GroupManagementPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authControllerProvider);
    final l10n = AppLocalizations.of(context);

    return AppScaffold(
      title: l10n.groupManage,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (auth.groups.isNotEmpty)
            Card(
              child: Column(
                children: [
                  for (final g in auth.groups)
                    Column(
                      children: [
                        ListTile(
                          title: Text(g.name),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () {
                            context.push('/settings/groups/${g.id}');
                          },
                        ),
                        if (g != auth.groups.last) const Divider(height: 1),
                      ],
                    ),
                ],
              ),
            )
          else
            Padding(
              padding: EdgeInsets.only(top: 12),
              child: Text(l10n.nogroup),
            ),

          const SizedBox(height: 12),

          Card(
            child: ListTile(
              title: Text(l10n.groupCreateTitle),
              onTap: () => context.push('/settings/groups/create'),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              title: Text(l10n.joinGroup),
              onTap: () => context.push('/settings/groups/join'),
            ),
          ),
        ],
      ),
    );
  }
}
