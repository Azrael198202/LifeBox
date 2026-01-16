import '../../../core/widgets/risk_badge.dart';
import '../domain/local_inbox_record.dart';

/// Tab 用：高风险 / 待办 / 已完成
enum InboxStatus {
  highRisk,
  pending,
  done,
}

class InboxItem {
  final String id;

  final String title;
  final String summary;

  final DateTime? dueAt;
  final int? amount;
  final String? currency;

  final RiskLevel risk;
  final String source; // = LocalInboxRecord.sourceHint
  final InboxStatus status;

  // 原文证据（明细页用）
  final String rawText;
  final String locale;

  InboxItem({
    required this.id,
    required this.title,
    required this.summary,
    required this.dueAt,
    required this.amount,
    required this.currency,
    required this.risk,
    required this.source,
    required this.status,
    required this.rawText,
    required this.locale,
  });

  /// ✅ 从本地 DB 记录映射成 UI Item
  factory InboxItem.fromLocal(LocalInboxRecord r) {
    RiskLevel mapRisk(String v) {
      switch (v) {
        case 'high':
          return RiskLevel.high;
        case 'mid':
          return RiskLevel.mid;
        case 'low':
        default:
          return RiskLevel.low;
      }
    }

    DateTime? parseDueAt(String? v) {
      if (v == null) return null;
      final s = v.trim();
      if (s.isEmpty) return null;
      try {
        return DateTime.parse(s);
      } catch (_) {
        return null;
      }
    }

    InboxStatus mapStatus({
      required String dbStatus,
      required String dbRisk,
    }) {
      // 1) 已完成优先
      if (dbStatus == 'done') return InboxStatus.done;

      // 2) 未完成时：高风险单独 tab
      if (dbRisk == 'high') return InboxStatus.highRisk;

      // 3) 其他未完成 -> 待办
      return InboxStatus.pending;
    }

    return InboxItem(
      id: r.id,
      title: r.title,
      summary: r.summary,
      dueAt: parseDueAt(r.dueAt),
      amount: r.amount,
      currency: r.currency,
      risk: mapRisk(r.risk),
      source: r.sourceHint,
      status: mapStatus(dbStatus: r.status, dbRisk: r.risk),
      rawText: r.rawText,
      locale: r.locale,
    );
  }
}
