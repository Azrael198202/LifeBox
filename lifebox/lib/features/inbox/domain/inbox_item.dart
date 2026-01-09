import '../../../core/widgets/risk_badge.dart';

enum InboxStatus { high, pending, done }

class InboxItem {
  final String id;
  final String title;
  final DateTime? dueAt;
  final RiskLevel risk;
  final String source; // 学校/银行/医院/公司/其他
  final InboxStatus status;

  InboxItem({
    required this.id,
    required this.title,
    required this.dueAt,
    required this.risk,
    required this.source,
    required this.status,
  });
}
