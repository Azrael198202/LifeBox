import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lifebox/features/inbox/state/cloud_inbox_service_provider.dart';
import 'package:uuid/uuid.dart';

import '../domain/analyze_models.dart';
import '../domain/local_inbox_record.dart';
import '../state/local_inbox_providers.dart';
import '../../settings/state/settings_providers.dart';
import '../../../core/input_formatters/date_input_formatter.dart';

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

    // 1) 组装请求（AnalyzeRequest）
    // final req = AnalyzeRequest(
    //   text: widget.request.text,
    //   locale: widget.request.locale,
    //   sourceHint: widget.request.sourceHint,
    // );

    final req = AnalyzeRequest(
      text: "銀行より：クレジットカードのお支払い期限は1/20です。金額3万円。",
      locale: "ja",
      sourceHint: "銀行"
    );

    // 2) 调用接口，拿到返回（AnalyzeResponse）
    final resp = await svc.analyze(req);

    if (!mounted) return;

    setState(() {
      _resp = resp; // ✅ _resp 应该是 AnalyzeResponse 类型
      _risk = resp.risk;
      _title.text = resp.title;
      _summary.text = resp.notes ?? '';
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

  bool _isValidDate(String v) {
    final reg = RegExp(r'^\d{4}-\d{2}-\d{2}$');
    if (!reg.hasMatch(v)) return false;

    try {
      final dt = DateTime.parse(v);
      return dt.year >= 1900 && dt.year <= 2100;
    } catch (_) {
      return false;
    }
  }

  Future<void> _onSave() async {
    if (_saving) return;
    setState(() => _saving = true);

    final due = _dueAt.text.trim();
    if (due.isNotEmpty && !_isValidDate(due)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('日期格式不正确，请使用 YYYY-MM-DD')),
      );
      return;
    }

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
        final cloud = ref.read(cloudInboxServiceProvider);
        await cloud.saveToCloud(record);
      }

      // ✅ 刷新 inbox 列表
      ref.invalidate(localInboxListProvider);

      if (!mounted) return;
      Navigator.of(context).popUntil((route) => route.isFirst);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final resp = _resp;
    final cs = Theme.of(context).colorScheme;
    final onSurface = cs.onSurface;
    final onSurfaceHint = cs.onSurface.withOpacity(0.7);

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
                        style: TextStyle(fontSize: 14, color: onSurface),
                        cursorColor: Theme.of(context).colorScheme.primary,
                        decoration: const InputDecoration(
                          labelText: '标题',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _summary,
                        style: TextStyle(fontSize: 12, color: onSurface),
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
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter
                                    .digitsOnly, // ① 只允许数字
                                DateInputFormatter(), // ② 自动格式 yyyy-mm-dd
                              ],
                              style: TextStyle(fontSize: 14, color: onSurface),
                              decoration: const InputDecoration(
                                labelText: '期限 (YYYYMMDD)',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _risk,
                              dropdownColor: cs.surface,
                              style: TextStyle(color: onSurface),
                              decoration: InputDecoration(
                                labelText: '风险',
                                border: OutlineInputBorder(),
                                labelStyle: TextStyle(color: onSurfaceHint),
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
                              style: TextStyle(fontSize: 14, color: onSurface),
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
                              style: TextStyle(fontSize: 14, color: onSurface),
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
                    style: TextStyle(fontSize: 12, color: onSurface),
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
        color: Theme.of(context).colorScheme.surface,
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
