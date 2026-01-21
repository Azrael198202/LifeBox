import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../l10n/app_localizations.dart';

class AddMemberAppAccountResult {
  final String name;
  final String account; // 输入的账号/ID
  const AddMemberAppAccountResult({required this.name, required this.account});
}

class AddMemberAppAccountPage extends ConsumerStatefulWidget {
  const AddMemberAppAccountPage({super.key});

  @override
  ConsumerState<AddMemberAppAccountPage> createState() =>
      _AddMemberAppAccountPageState();
}

class _AddMemberAppAccountPageState
    extends ConsumerState<AddMemberAppAccountPage> {
  final _name = TextEditingController();
  final _account = TextEditingController();

  bool get _canSave =>
      _name.text.trim().isNotEmpty && _account.text.trim().isNotEmpty;

  @override
  void dispose() {
    _name.dispose();
    _account.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AppScaffold(
      title: l10n.addMember,
      // 如果你的 AppScaffold 不支持 actions，就用普通 Scaffold+AppBar
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 顶部右侧“保存”通常在 AppBar，这里用按钮模拟也可
          Row(
            children: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(l10n.cancel),
              ),
              const Spacer(),
              TextButton(
                onPressed: _canSave
                    ? () {
                        Navigator.pop(
                          context,
                          AddMemberAppAccountResult(
                            name: _name.text.trim(),
                            account: _account.text.trim(),
                          ),
                        );
                      }
                    : null,
                child: Text(l10n.save),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // 名前
          Card(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: TextField(
                controller: _name,
                decoration: InputDecoration(
                  labelText: l10n.displayname,
                  hintText: l10n.inputName,
                  border: InputBorder.none,
                ),
                onChanged: (_) => setState(() {}),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // アカウント（不要国家，所以只留账号输入）
          Card(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: TextField(
                controller: _account,
                decoration: InputDecoration(
                  labelText: l10n.account,
                  hintText: l10n.inputAccount,
                  border: InputBorder.none,
                ),
                onChanged: (_) => setState(() {}),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // 角色这一行你说不要也可以；第二张图有“普通メンバー”，我先按你之前要求：不要 role
          // 如果你将来想加 role，就在这里加一个 ListTile 即可
        ],
      ),
    );
  }
}
