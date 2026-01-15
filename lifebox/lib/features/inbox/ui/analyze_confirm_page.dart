import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../domain/analyze_models.dart';
import '../domain/local_inbox_record.dart';
import '../state/local_inbox_providers.dart';
import '../../settings/state/settings_providers.dart';

class AnalyzeConfirmPage extends ConsumerStatefulWidget {
  const AnalyzeConfirmPage({
    super.key,
    required this.request,
  });

  final AnalyzeRequest request;

  @override
  ConsumerState<AnalyzeConfirmPage> createState() => _AnalyzeConfirmPageState();
}

class _AnalyzeConfirmPageState extends ConsumerState<AnalyzeConfirmPage> {
  bool _saving = false;

  late final TextEditingController _title;
  late final TextEditingController _summary;
  late final TextEditingController _dueAt;
  late final TextEditingController _amount;
  late final TextEditingController _currency;
  String _risk = 'low';

  AnalyzeResponse? _resp;

  @override
  void initState() {
    super.initState();
    _title = TextEditingController();
    _summary = TextEditingController();
    _dueAt = TextEditingController();
    _amount = TextEditingController();
    _currency = TextEditingController();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    final svc = ref.read(analyzeServiceProvider);
    final resp = await svc.analyze(widget.request);

    if (!mounted) return;

    setState(() {
      _resp = resp;
      _risk = resp.risk;
      _title.text = resp.title;
      _summary.text = resp.summary;
      _dueAt.text = resp.dueAt ?? '';
      _amount.text = resp.amount?.toString() ?? '';
      _currency.text = resp.currency ?? '';
    });
  }

  @override
  void dispose() {
    _title.dispose();
    _summary.dispose();
    _dueAt.dispose();
    _amount.dispose();
    _currency.dispose();
    super.dispose();
  }

  Future<void> _onSave() async {
    if (_saving) return;
    setState(() => _saving = true);

    try {
      final id = const Uuid().v4();
      final record = LocalInboxRecord(
        id: id,
        rawText: widget.request.text,
        locale: widget.request.locale,
        sourceHint: widget.request.sourceHint,
        title: _title.text.trim().isEmpty ? 'Untitled' : _title.text.trim(),
        summary: _summary.text.trim(),
        dueAt: _dueAt.text.trim().isEmpty ? null : _dueAt.text.trim(),
        amount: int.tryParse(_amount.text.trim()),
        currency: _currency.text.trim().isEmpty ? null : _currency.text.trim(),
        risk: _risk,
        status: 'pending',
        createdAt: DateTime.now(),
      );

      // ✅ 保存到本地 DB
      final db = ref.read(localInboxDbProvider);
      await db.upsert(record);

      // ✅ 若开启云保存，则模拟调用云保存 API（收费功能）
      final cloudEnabled = ref.read(cloudEnabledProvider);
      if (cloudEnabled) {
        final svc = ref.read(analyzeServiceProvider);
        await svc.saveToCloud(record);
      }

      // ✅ 刷新 inbox 列表
      ref.invalidate(localInboxListProvider);

      if (!mounted) return;
      Navigator.pop(context, true);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final resp = _resp;

    return Scaffold(
      appBar: AppBar(
        title: const Text('确认并保存'),
      ),
      body: resp == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _Section(
                  title: '解析结果（可编辑）',
                  child: Column(
                    children: [
                      TextField(
                        controller: _title,
                        style: TextStyle(
                            fontSize: 14,
                            color: Colors.black),
                        cursorColor: Theme.of(context).colorScheme.primary,
                        decoration: const InputDecoration(
                          labelText: '标题',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _summary,
                        style: TextStyle(
                            fontSize: 12,
                            color: Colors.black),
                        cursorColor: Theme.of(context).colorScheme.primary,
                        maxLines: 5,
                        decoration: const InputDecoration(
                          labelText: '内容/摘要',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _dueAt,
                              decoration: const InputDecoration(
                                labelText: '期限 (YYYY-MM-DD)',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _risk,
                              decoration: const InputDecoration(
                                labelText: '风险',
                                border: OutlineInputBorder(),
                              ),
                              items: const [
                                DropdownMenuItem(
                                    value: 'high', child: Text('high')),
                                DropdownMenuItem(
                                    value: 'mid', child: Text('mid')),
                                DropdownMenuItem(
                                    value: 'low', child: Text('low')),
                              ],
                              onChanged: (v) =>
                                  setState(() => _risk = v ?? 'low'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _amount,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: '金额',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: _currency,
                              decoration: const InputDecoration(
                                labelText: '币种 (JPY/CNY)',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _Section(
                  title: '模拟请求（参考）',
                  child: SelectableText(
                    widget.request.toJson().toString(),
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
                const SizedBox(height: 22),
                FilledButton.icon(
                  onPressed: _saving ? null : _onSave,
                  icon: _saving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.save),
                  label: Text(_saving ? '保存中...' : '确认无误，保存'),
                ),
              ],
            ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.black.withOpacity(0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style:
                  const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}
