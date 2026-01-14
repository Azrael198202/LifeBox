import '../../../core/widgets/hold_to_talk_button.dart';
import 'package:flutter/material.dart';
import 'package:lifebox/l10n/app_localizations.dart';

/// ✅ 公开组件：抽走 InboxPage 里的 _SpeechFloatingBar
class SpeechFloatingBar extends StatelessWidget {
  const SpeechFloatingBar({
    super.key,
    required this.lastText,
    required this.onFinalText,
    this.localeId = 'zh_CN',
  });

  final String lastText;
  final void Function(String text) onFinalText;
  final String localeId;

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
            HoldToTalkButton(
              localeId: localeId,
              onFinalText: onFinalText,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                lastText.isEmpty ? l10n.speechBarHintHoldToTalk : l10n.speechBarRecentPrefix(lastText),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.black.withOpacity(0.72),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}