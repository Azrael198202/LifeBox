import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lifebox/features/settings/state/group_provider.dart';
import 'package:lifebox/l10n/app_localizations.dart';
import '../../../core/widgets/app_scaffold.dart';

class JoinGroupPage extends ConsumerStatefulWidget {
  const JoinGroupPage({super.key});

  @override
  ConsumerState<JoinGroupPage> createState() => _JoinGroupPageState();
}

class _JoinGroupPageState extends ConsumerState<JoinGroupPage> {
  final _code = TextEditingController();
  bool _joining = false;

  @override
  void dispose() {
    _code.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return AppScaffold(
      title: l10n.joinGroupTitle,
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 24),
            const Icon(Icons.home, size: 72, color: Colors.orange),
            const SizedBox(height: 16),
            Text(
              l10n.joinGroupHelp,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black54, height: 1.4),
            ),
            const SizedBox(height: 26),
            TextField(
              controller: _code,
              textInputAction: TextInputAction.done,
              decoration: InputDecoration(
                hintText: l10n.joinGroupHint,
                filled: true,
                fillColor: Colors.black12.withOpacity(0.05),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: _joining ? null : _join,
                ),
              ),
              onSubmitted: (_) => _joining ? null : _join(),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _join() async {
    final code = _code.text.trim();
    final l10n = AppLocalizations.of(context);

    if (code.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.joinGroupCodeEmpty)),
      );
      return;
    }

    final token = code;
    setState(() => _joining = true);

    try {
      final c = ref.read(groupControllerProvider.notifier);

      // ✅ 1) 调后端 accept invite
      final resp = await c.acceptInvite(token: token);

      if (!mounted) return;

      if (resp == null) {
      // controller 内部会把 error 写到 state.error，这里给用户一个友好提示
        final groupState = ref.read(groupControllerProvider);
        final msg = (groupState.error ?? '').isNotEmpty
            ? groupState.error!
            : l10n.joinGroupFailed;
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(msg)));
        return;
      }

      // ✅ 2) acceptInvite 内部已经 refreshGroups() 了，但我们要确保 activeGroup 切换到新加入的组
      // AcceptInviteRespDto 通常会带 groupId（如果你的 DTO 字段不同，改这里即可）
            final joinedGroupId = resp.groupId; // <-- 若编译报错，告诉我你 DTO 字段名
      if ((joinedGroupId ?? '').isNotEmpty) {
        await c.setActiveGroup(joinedGroupId!);
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.joinGroupJoined)),
      );

      Navigator.pop(context, true);
    } finally {
      if (mounted) setState(() => _joining = false);
    }
  }
}
