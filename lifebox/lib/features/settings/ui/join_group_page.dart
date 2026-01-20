import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
    return AppScaffold(
      title: 'グループに入る',
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 24),
            const Icon(Icons.home, size: 72, color: Colors.orange),
            const SizedBox(height: 16),
            const Text(
              'グループのオーナーに連絡して誘いを出してください\n（グループの設定＞メンバーを追加）',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black54, height: 1.4),
            ),
            const SizedBox(height: 26),

            TextField(
              controller: _code,
              textInputAction: TextInputAction.done,
              decoration: InputDecoration(
                hintText: '誘いコードを入力してください',
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
    if (code.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('招待コードを入力してください')),
      );
      return;
    }

    setState(() => _joining = true);

    try {
      // TODO: 这里接入你的 API / GroupStore
      // await ref.read(groupServiceProvider).joinByInviteCode(code);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('参加しました（仮）')),
      );
      Navigator.pop(context);
    } finally {
      if (mounted) setState(() => _joining = false);
    }
  }
}
