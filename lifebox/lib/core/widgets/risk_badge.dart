import 'package:flutter/material.dart';
import '../../app/theme/colors.dart';
import 'package:lifebox/l10n/app_localizations.dart';

/// Original risk level (three-tier) — preserved
enum RiskLevel { high, mid, low }

/// Generic badge type for info / success / warning / error / informational states
enum BadgeTone { info, success, warning, danger }

class RiskBadge extends StatelessWidget {
  final RiskLevel? risk;

  /// RiskBadge.text(...)
  final String? label;
  final BadgeTone? tone;

  /// Whether to display a prefix (legacy behavior was "Risk: High")
  final bool showPrefix;

  const RiskBadge({
    super.key,
    required this.risk,
    this.label,
    this.tone,
    this.showPrefix = true,
  });

  /// New factory added:
  /// Used for generic message badges
  /// - Generic badges do NOT include the "Risk" prefix
  factory RiskBadge.text(
    String label, {
    Key? key,
    BadgeTone tone = BadgeTone.info,
  }) {
    return RiskBadge(
      key: key,
      risk: null,
      label: label,
      tone: tone,
      showPrefix: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final (text, color) = _resolveTextAndColor(l10n);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withOpacity(0.35)),
      ),
      child: Text(
        text,
        style:
            TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }

  (String, Color) _resolveTextAndColor(AppLocalizations l10n) {
    /// Modes:
    /// 1) Legacy mode: risk level badge
    /// 2) New mode: generic text badge
    if (risk != null) {
      final (t, c) = switch (risk!) {
        RiskLevel.high => (l10n.riskHigh, AppColors.riskHigh),
        RiskLevel.mid => (l10n.riskMid, AppColors.riskMid),
        RiskLevel.low => (l10n.riskLow, AppColors.riskLow),
      };
      final prefix = showPrefix ? l10n.riskPrefix : '';
      return ('$prefix$t', c);
    }

    final toneColor = switch (tone ?? BadgeTone.info) {
      BadgeTone.info => AppColors.riskMid,
      BadgeTone.success => Colors.green,
      BadgeTone.warning => Colors.orange,
      BadgeTone.danger => Colors.red,
    };

    return (label ?? '', toneColor);
  }
}
