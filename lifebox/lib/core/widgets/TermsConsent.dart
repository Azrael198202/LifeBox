import 'package:flutter/material.dart';
import 'package:lifebox/core/services/legal_api.dart';
import 'package:lifebox/features/settings/ui/legal_page.dart';
import 'package:lifebox/l10n/app_localizations.dart';

class TermsConsent extends StatelessWidget {
  const TermsConsent({
    super.key,
    required this.checked,
    this.onDark = true,
    this.compact = false,
  });

  /// Passed in from the outside
  /// (Each Login / Register page owns its own ValueNotifier)
  final ValueNotifier<bool> checked;

  final bool onDark;

  /// More compact layout
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final baseColor = onDark
        ? const Color.fromARGB(255, 252, 253, 255)
        : const Color(0xFF6B7280);
    final linkColor = onDark ? Colors.white : const Color(0xFF111827);

    final style = TextStyle(color: baseColor, fontSize: 11, height: 1.35);
    final linkStyle =
        style.copyWith(color: linkColor, fontWeight: FontWeight.w700);

    final l10n = AppLocalizations.of(context);

    return ValueListenableBuilder<bool>(
      valueListenable: checked,
      builder: (_, v, __) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: compact ? 18 : 20,
              width: compact ? 18 : 20,
              child: Checkbox(
                value: v,
                onChanged: (nv) => checked.value = nv ?? false,
                visualDensity: VisualDensity.compact,
                side: BorderSide(color: baseColor.withOpacity(0.9)),
                activeColor: onDark ? Colors.white : const Color(0xFF111827),
                checkColor: onDark ? const Color(0xFF16264D) : Colors.white,
              ),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Wrap(
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(l10n.terms_agree_prefix, style: style),
                  GestureDetector(
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const LegalPage(type: LegalType.terms),
                      ),
                    ),
                    child: Text(l10n.terms_title, style: linkStyle),
                  ),
                  Text(l10n.terms_and, style: style),
                  GestureDetector(
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) =>
                            const LegalPage(type: LegalType.privacy),
                      ),
                    ),
                    child: Text(l10n.privacy_title, style: linkStyle),
                  ),
                  Text('。', style: style),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
