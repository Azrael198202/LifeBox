import 'package:flutter/material.dart';
import '../../app/theme/colors.dart';

enum RiskLevel { high, mid, low }

class RiskBadge extends StatelessWidget {
  final RiskLevel risk;
  const RiskBadge({super.key, required this.risk});

  @override
  Widget build(BuildContext context) {
    final (text, color) = switch (risk) {
      RiskLevel.high => ('高', AppColors.riskHigh),
      RiskLevel.mid => ('中', AppColors.riskMid),
      RiskLevel.low => ('低', AppColors.riskLow),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withOpacity(0.35)),
      ),
      child: Text(
        '风险 $text',
        style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }
}
