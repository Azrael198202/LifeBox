import 'package:flutter/material.dart';
import '../../app/theme/colors.dart';
import 'package:lifebox/l10n/app_localizations.dart';

/// 原来的风险等级（三档）——保留
enum RiskLevel { high, mid, low }

/// 新增：通用信息徽章类型（用于提示/成功/警告/错误/信息）
enum BadgeTone { info, success, warning, danger }

class RiskBadge extends StatelessWidget {
  /// 兼容旧用法：RiskBadge(risk: RiskLevel.high)
  final RiskLevel? risk;

  /// 新用法：RiskBadge.text(...)
  final String? label;
  final BadgeTone? tone;

  /// 是否显示前缀（旧版是 “风险 高”）
  final bool showPrefix;

  const RiskBadge({
    super.key,
    required this.risk,
    this.label,
    this.tone,
    this.showPrefix = true,
  });

  /// ✅ 新增工厂：用于通用提示徽章
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
      showPrefix: false, // 通用徽章不加“风险”
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
        style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }

  (String, Color) _resolveTextAndColor(AppLocalizations l10n) {
    // 1) 旧模式：风险等级
    if (risk != null) {
      final (t, c) = switch (risk!) {
        RiskLevel.high => (l10n.riskHigh, AppColors.riskHigh),
        RiskLevel.mid => (l10n.riskMid, AppColors.riskMid),
        RiskLevel.low => (l10n.riskLow, AppColors.riskLow),
      };
      final prefix = showPrefix ? l10n.riskPrefix : '';
      return ('$prefix$t', c);
    }

    // 2) 新模式：通用文本徽章
    final toneColor = switch (tone ?? BadgeTone.info) {
      BadgeTone.info => AppColors.riskMid,     // 没有 info 色就先用 mid
      BadgeTone.success => Colors.green,
      BadgeTone.warning => Colors.orange,
      BadgeTone.danger => Colors.red,
    };

    return (label ?? '', toneColor);
  }
}
