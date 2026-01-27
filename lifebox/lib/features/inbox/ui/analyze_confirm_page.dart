import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lifebox/core/network/api_error_l10n.dart';
import 'package:lifebox/core/network/api_exception.dart';
import 'package:lifebox/core/utils/date_tools.dart';
import 'package:lifebox/features/auth/state/auth_providers.dart';
import 'package:lifebox/features/inbox/data/mock_speech_texts.dart';
import 'package:lifebox/features/inbox/state/cloud_inbox_service_provider.dart';
import 'package:lifebox/features/inbox/state/inbox_refresh.dart';
import 'package:lifebox/features/settings/state/subscription_providers.dart';
import 'package:uuid/uuid.dart';
import 'package:lifebox/l10n/app_localizations.dart';

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

  String _groupId = 'personal'; // personal or real group id
  int _colorValue = 0xFF607D8B; // 默认颜色（蓝灰）
  String _risk = 'low';

  AnalyzeResponse? _resp;

  late AnalyzeRequest _req;

  bool _analyzing = false;

  static const List<int> _colorOptions = [
    0xFF607D8B, // blueGrey
    0xFF2196F3, // blue
    0xFF4CAF50, // green
    0xFFFF9800, // orange
    0xFFE91E63, // pink
    0xFF9C27B0, // purple
    0xFFF44336, // red
  ];

  String _colorName(BuildContext context, int c) {
    final l10n = AppLocalizations.of(context);

    switch (c) {
      case 0xFF607D8B:
        return l10n.colorBlueGrey;
      case 0xFF2196F3:
        return l10n.colorBlue;
      case 0xFF4CAF50:
        return l10n.colorGreen;
      case 0xFFFF9800:
        return l10n.colorOrange;
      case 0xFFE91E63:
        return l10n.colorPink;
      case 0xFF9C27B0:
        return l10n.colorPurple;
      case 0xFFF44336:
        return l10n.colorRed;
      default:
        return l10n.colorGeneric;
    }
  }

  /// groupId
  /// personal も含めて deterministic にする
  int _defaultColorForGroup(String groupId) {
    final base = groupId.hashCode.abs() % _colorOptions.length;
    return _colorOptions[base];
  }

  @override
  void initState() {
    super.initState();
    _title = TextEditingController();
    _summary = TextEditingController();
    _dueAt = TextEditingController();
    _amount = TextEditingController();
    _currency = TextEditingController();

    _req = widget.request;
    _bootstrap(_req);
  }

  Future<void> _bootstrap(AnalyzeRequest req) async {
    if (_analyzing) return;
    setState(() {
      _analyzing = true;
      _resp = null;
    });

    try {
      final svc = ref.read(analyzeServiceProvider);
      final resp = await svc.analyze(req);

      if (!mounted) return;
      setState(() {
        _resp = resp;
        _risk = resp.risk;
        _title.text = resp.title;
        _summary.text = resp.notes ?? '';
        _dueAt.text = DateTools.normalizeDateToYMD(resp.dueAt) ?? '';
        _amount.text = resp.amount?.toString() ?? '';
        _currency.text = resp.currency ?? '';
      });
    } catch (e) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.speechAnalyzeFailed(e))),
      );
    } finally {
      if (mounted) setState(() => _analyzing = false);
    }
  }

  Future<void> _openMockSamplesInConfirm() async {
    final l10n = AppLocalizations.of(context);

    final picked = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(l10n.speechMockTitle),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.separated(
            shrinkWrap: true,
            itemCount: MockSpeechTexts.samples.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (_, i) {
              final t = MockSpeechTexts.samples[i];
              return ListTile(
                title: Text(t, maxLines: 2, overflow: TextOverflow.ellipsis),
                onTap: () => Navigator.pop(context, t),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
        ],
      ),
    );

    final trimmed = picked?.trim();
    if (trimmed == null || trimmed.isEmpty) return;

    // ✅ 用选中的 mock 文本替换当前 request，并重新分析
    final next = AnalyzeRequest(
      text: trimmed,
      locale: _req.locale,
      sourceHint: _req.sourceHint,
    );

    setState(() => _req = next);
    await _bootstrap(_req);
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

  Future<void> _pickDueDate() async {
    // 现有值如果是 yyyy-MM-dd，就用它做初始日期
    DateTime initial = DateTime.now();
    final current = _dueAt.text.trim();
    if (current.isNotEmpty) {
      try {
        final normalized = DateTools.normalizeDateToYMD(current);
        if (normalized != null) initial = DateTime.parse(normalized);
      } catch (_) {}
    }

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2000, 1, 1),
      lastDate: DateTime(2100, 12, 31),
      // ✅ 如果你希望 DatePicker 跟随 app 语言，可以用 AppLocalizations 的 locale
      // locale: Localizations.localeOf(context),
    );

    if (picked == null) return;

    final y = picked.year.toString().padLeft(4, '0');
    final m = picked.month.toString().padLeft(2, '0');
    final d = picked.day.toString().padLeft(2, '0');

    setState(() {
      _dueAt.text = '$y-$m-$d';
    });
  }

  Future<void> _onSave() async {
    if (_saving) return;
    setState(() => _saving = true);

    final l10n = AppLocalizations.of(context);

    final auth = ref.read(authControllerProvider);
    final sub = ref.read(subscriptionProvider);

    final due = _dueAt.text.trim();
    if (due.isNotEmpty && !_isValidDate(due)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.analysis_confirm_invalid_date)),
      );
      if (mounted) setState(() => _saving = false);
      return;
    }

    try {
      final id = const Uuid().v4();
      final record = LocalInboxRecord(
        id: id,
        ownerUserId: auth.user!.id,
        rawText: _req.text,
        locale: _req.locale,
        sourceHint: _req.sourceHint,
        title: _title.text.trim().isEmpty ? 'Untitled' : _title.text.trim(),
        summary: _summary.text.trim(),
        dueAt: DateTools.normalizeDateToYMD(_dueAt.text),
        amount: int.tryParse(_amount.text.trim()),
        currency: _currency.text.trim().isEmpty ? null : _currency.text.trim(),
        risk: _risk,
        status: 'pending',
        createdAt: DateTime.now(),
        groupId:
            (sub.subscribed && auth.groups.isNotEmpty && _groupId != 'personal')
                ? _groupId
                : null,
        colorValue: _colorValue,
      );

      // ✅ 保存到本地 DB
      final db = ref.read(localInboxDbProvider);
      await db.upsert(record);

      // ✅ 若开启云保存，则调用云保存 API
      final cloudEnabled = ref.read(cloudEnabledProvider);

      if (cloudEnabled) {

        final cloud = ref.read(cloudInboxServiceProvider);
        final accessToken = auth.accessToken;

        if (accessToken != null && accessToken.isNotEmpty) {
          await cloud.saveToCloud(
            record,
            accessToken: accessToken,
          );
        }
      }

      // ✅ 刷新 inbox 列表
      refreshInboxProviders(ref); 

      if (!mounted) return;
      Navigator.of(context).popUntil((route) => route.isFirst);
    } catch (e) {
      String message;

      if (e is ApiException) {
        message = e.errorKey.message(l10n);
      } else {
        message = l10n.serverError; // 兜底
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Colors.red,
          ),
        );
      }
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
    final l10n = AppLocalizations.of(context);

    final auth = ref.watch(authControllerProvider);
    final sub = ref.watch(subscriptionProvider);

    final groups = auth.groups;
    final canSelectGroup = sub.subscribed && groups.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.analysis_confirm_title),
        actions: [
          IconButton(
            tooltip: l10n.speechMockTooltip,
            onPressed: _analyzing ? null : _openMockSamplesInConfirm,
            icon: const Icon(Icons.bug_report_outlined),
          ),
        ],
      ),
      body: resp == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _Section(
                  title: l10n.analysis_confirm_section_editable,
                  child: Column(
                    children: [
                      TextField(
                        controller: _title,
                        style: TextStyle(fontSize: 14, color: onSurface),
                        cursorColor: Theme.of(context).colorScheme.primary,
                        decoration: InputDecoration(
                          labelText: l10n.analysis_confirm_field_title,
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _summary,
                        style: TextStyle(fontSize: 12, color: onSurface),
                        cursorColor: Theme.of(context).colorScheme.primary,
                        maxLines: 5,
                        decoration: InputDecoration(
                          labelText: l10n.analysis_confirm_field_summary,
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          // ===== 日期（占 2 份宽度）======
                          Flexible(
                            flex: 2, // 👈 更宽
                            child: TextField(
                              controller: _dueAt,
                              readOnly: true,
                              onTap: _analyzing ? null : _pickDueDate,
                              style: TextStyle(fontSize: 14, color: onSurface),
                              decoration: InputDecoration(
                                labelText: l10n.analysis_confirm_field_due,
                                border: const OutlineInputBorder(),
                                suffixIcon: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (_dueAt.text.trim().isNotEmpty)
                                      IconButton(
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(),
                                        icon: const Icon(Icons.close, size: 18),
                                        tooltip: l10n.clear,
                                        onPressed: () =>
                                            setState(() => _dueAt.clear()),
                                      ),
                                    IconButton(
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                      icon: const Icon(
                                          Icons.calendar_today_outlined,
                                          size: 18),
                                      tooltip: l10n.select,
                                      onPressed:
                                          _analyzing ? null : _pickDueDate,
                                    ),
                                    const SizedBox(width: 6),
                                  ],
                                ),
                                suffixIconConstraints: const BoxConstraints(
                                  minWidth: 72,
                                  minHeight: 48,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(width: 12),

                          // ===== Risk（占 1 份宽度）======
                          Flexible(
                            flex: 1, // 👈 更短
                            child: DropdownButtonFormField<String>(
                              value: _risk,
                              dropdownColor: cs.surface,
                              style: TextStyle(color: onSurface),
                              isDense: true, // 👈 更紧凑
                              decoration: InputDecoration(
                                labelText: l10n.analysis_confirm_field_risk,
                                border: const OutlineInputBorder(),
                                labelStyle: TextStyle(color: onSurfaceHint),
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 12),
                              ),
                              items: [
                                DropdownMenuItem(
                                    value: 'high', child: Text(l10n.riskHigh)),
                                DropdownMenuItem(
                                    value: 'mid', child: Text(l10n.riskMid)),
                                DropdownMenuItem(
                                    value: 'low', child: Text(l10n.riskLow)),
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
                              decoration: InputDecoration(
                                labelText: l10n.analysis_confirm_field_amount,
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: _currency,
                              style: TextStyle(fontSize: 14, color: onSurface),
                              decoration: InputDecoration(
                                labelText: l10n.analysis_confirm_field_currency,
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // ====== Group 選択（有料 / groupなしなら個人固定）======
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: canSelectGroup ? _groupId : 'personal',
                              decoration: InputDecoration(
                                labelText: l10n.group,
                                border: const OutlineInputBorder(),
                              ),
                              items: [
                                DropdownMenuItem(
                                  value: 'personal',
                                  child: Text(l10n.personal),
                                ),
                                if (canSelectGroup)
                                  ...groups.map((g) {
                                    return DropdownMenuItem(
                                      value: g.id,
                                      child: Text(g.name),
                                    );
                                  }),
                              ],
                              onChanged: canSelectGroup
                                  ? (v) {
                                      if (v == null) return;
                                      setState(() {
                                        _groupId = v;
                                        // ✅ group 选择变化时：自动给一个默认颜色（也可不自动）
                                        _colorValue = _defaultColorForGroup(v);
                                      });
                                    }
                                  : null, // ✅ 禁用
                            ),
                          ),
                          const SizedBox(width: 12),

                          // ====== Color（Calendar 用）======
                          Expanded(
                            child: DropdownButtonFormField<int>(
                              value: _colorValue,
                              decoration: InputDecoration(
                                labelText: l10n.colorTitle,
                                border: OutlineInputBorder(),
                              ),
                              items: _colorOptions.map((c) {
                                return DropdownMenuItem(
                                  value: c,
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 14,
                                        height: 14,
                                        decoration: BoxDecoration(
                                          color: Color(c),
                                          borderRadius:
                                              BorderRadius.circular(3),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(_colorName(context, c),
                                          style: TextStyle(fontSize: 12)),
                                    ],
                                  ),
                                );
                              }).toList(),
                              onChanged: (v) {
                                if (v == null) return;
                                setState(() => _colorValue = v);
                              },
                            ),
                          ),
                        ],
                      ),

                      if (!canSelectGroup) ...[
                        const SizedBox(height: 8),
                        Text(
                          l10n.group_desc,
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.6),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _Section(
                  title: l10n.analysis_confirm_section_request,
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
                  label: Text(_saving
                      ? l10n.analysis_confirm_saving
                      : l10n.analysis_confirm_save),
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
