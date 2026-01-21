import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lifebox/l10n/app_localizations.dart';

import '../../../core/widgets/hold_to_talk_button.dart';
import '../../inbox/domain/analyze_models.dart';
import '../../inbox/state/local_inbox_providers.dart';
import '../../inbox/ui/analyze_confirm_page.dart';

// ✅ Mock 语音文本
import '../../inbox/data/mock_speech_texts.dart';

class SpeechFloatingBar extends ConsumerStatefulWidget {
  const SpeechFloatingBar({
    super.key,
    required this.lastText,
    required this.onFinalText,
    this.localeId = 'zh_CN',
    this.localeForAnalyze = 'ja',
    this.sourceHint = '音声',
    this.enableMock = true, // ✅ 开关
  });

  final String lastText;
  final void Function(String text) onFinalText;
  final String localeId;
  final String localeForAnalyze;
  final String sourceHint;

  final bool enableMock; // ✅

  @override
  ConsumerState<SpeechFloatingBar> createState() => _SpeechFloatingBarState();
}

class _SpeechFloatingBarState extends ConsumerState<SpeechFloatingBar> {
  bool _busy = false;

  Future<void> _handleFinalText(BuildContext context, String text) async {
    final trimmed = text.trim();
    final l10n = AppLocalizations.of(context);

    widget.onFinalText(trimmed);

    if (trimmed.isEmpty) return;
    if (_busy) return;

    setState(() => _busy = true);

    try {
      final svc = ref.read(analyzeServiceProvider);
      final req = AnalyzeRequest(
        text: trimmed,
        locale: widget.localeForAnalyze,
        sourceHint: widget.sourceHint,
      );

      // 可选：预请求（ConfirmPage 里也会请求一次）
      await svc.analyze(req);

      if (!mounted) return;

      final ok = await Navigator.of(context).push<bool>(
        MaterialPageRoute(builder: (_) => AnalyzeConfirmPage(request: req)),
      );

      if (ok == true && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.speechSavedToLocalInbox)),
        );
        ref.invalidate(localInboxListProvider);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.speechAnalyzeFailed(e))),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  // ✅ 模拟语音：选择/输入
  Future<void> _openMockDialog(BuildContext context) async {
    final controller = TextEditingController();
    final l10n = AppLocalizations.of(context);  

    final picked = await showDialog<String>(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: Text(l10n.speechMockTitle),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: controller,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: l10n.speechMockCustomInputLabel,
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
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
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.cancel),
            ),
            FilledButton(
              onPressed: () {
                final t = controller.text.trim();
                Navigator.pop(context, t.isEmpty ? null : t);
              },
              child: Text(l10n.speechMockUseInput),
            ),
          ],
        );
      },
    );

    if (picked != null && picked.trim().isNotEmpty) {
      await _handleFinalText(context, picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Material(
      elevation: 8,
      borderRadius: BorderRadius.circular(18),
      color: Theme.of(context).colorScheme.surface,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.black.withOpacity(0.06)),
        ),
        child: Row(
          children: [
            IgnorePointer(
              ignoring: _busy,
              child: HoldToTalkButton(
                localeId: widget.localeId,
                onFinalText: (t) => _handleFinalText(context, t),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                _busy
                    ? l10n.speechParsing
                    : (widget.lastText.isEmpty
                        ? l10n.speechBarHintHoldToTalk
                        : l10n.speechBarRecentPrefix(widget.lastText)),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.black.withOpacity(0.72),
                ),
              ),
            ),

            // ✅ 模拟按钮（只在 enableMock=true 时显示）
            if (widget.enableMock) ...[
              const SizedBox(width: 8),
              IconButton(
                tooltip: l10n.speechMockTooltip,
                onPressed: _busy ? null : () => _openMockDialog(context),
                icon: const Icon(Icons.bug_report_outlined, size: 20),
              ),
            ],

            if (_busy) ...[
              const SizedBox(width: 6),
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
