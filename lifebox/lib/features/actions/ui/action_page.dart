import 'package:flutter/material.dart';
import 'package:lifebox/l10n/app_localizations.dart';
import '../../../../core/widgets/app_scaffold.dart';

class ActionPage extends StatelessWidget {
  final String actionType; // calendar / reply / open_link ...
  final String itemId;

  const ActionPage({super.key, required this.actionType, required this.itemId});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return AppScaffold(
      title: l10n.actionPageTitle(actionType),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.actionTypeLabel(actionType), style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                Text(l10n.actionItemIdLabel(itemId)),
                const SizedBox(height: 16),
                Text(l10n.actionTodoDynamicRender),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: () {},
                  child: Text(l10n.actionConfirmTodo),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
