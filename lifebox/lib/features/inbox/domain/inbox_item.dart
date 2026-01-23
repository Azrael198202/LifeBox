import 'package:lifebox/features/inbox/domain/cloud_detail.dart';

import '../../../core/widgets/risk_badge.dart';
import '../domain/local_inbox_record.dart';
import '../domain/cloud_models.dart';

/// 数据来源（用于区分本地/云端）
enum InboxSourceType {
  local,
  cloud,
}

/// Tab 用：高风险 / 待办 / 已完成
enum InboxStatus {
  highRisk,
  pending,
  done,
}

class InboxItem {
  /// UI 唯一标识（用于 List key / 跳转参数）
  /// 建议：优先用 cloudId；否则用 localId
  final String id;

  /// 本地记录 id（本地存在才有）
  final String? localId;

  /// 云端记录 id（云端存在才有）
  final String? cloudId;

  /// 群组记录的 groupId（个人记录为 null）
  final String? groupId;

  /// 来源类型（本地 or 云端）
  final InboxSourceType sourceType;

  /// ✅ 创建时间（用于排序，必须）
  final DateTime createdAt;

  final String title;
  final String summary;

  final DateTime? dueAt;
  final int? amount;
  final String? currency;

  final RiskLevel risk;
  final String sourceHint; // sourceHint
  final InboxStatus status;

  /// 原文证据（明细页用）
  final String rawText;
  final String locale;

  const InboxItem({
    required this.id,
    required this.createdAt,
    required this.title,
    required this.summary,
    required this.dueAt,
    required this.amount,
    required this.currency,
    required this.risk,
    required this.sourceHint,
    required this.status,
    required this.rawText,
    required this.locale,
    required this.sourceType,
    this.localId,
    this.cloudId,
    this.groupId,
  });

  // =============================
  // Shared mapping helpers
  // =============================

  static RiskLevel mapRisk(String v) {
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

  static DateTime? parseDueAt(String? v) {
    if (v == null) return null;
    final s = v.trim();
    if (s.isEmpty) return null;
    try {
      return DateTime.parse(s);
    } catch (_) {
      return null;
    }
  }

  static InboxStatus mapStatus({
    required String dbStatus,
    required String dbRisk,
  }) {
    if (dbStatus == 'done') return InboxStatus.done;
    if (dbRisk == 'high') return InboxStatus.highRisk;
    return InboxStatus.pending;
  }

  // =============================
  // 本地 -> InboxItem
  // =============================
  factory InboxItem.fromLocal(LocalInboxRecord r) {
    final title = r.title.trim().isEmpty ? '---' : r.title.trim();

    return InboxItem(
      id: r.cloudId?.isNotEmpty == true ? r.cloudId! : r.id,
      localId: r.id,
      cloudId: (r.cloudId?.isNotEmpty == true) ? r.cloudId : null,
      groupId: r.groupId,
      sourceType: InboxSourceType.local,
      createdAt: r.createdAt, // ✅
      title: title,
      summary: r.summary,
      dueAt: parseDueAt(r.dueAt),
      amount: r.amount,
      currency: r.currency,
      risk: mapRisk(r.risk),
      sourceHint: r.sourceHint,
      status: mapStatus(dbStatus: r.status, dbRisk: r.risk),
      rawText: r.rawText,
      locale: r.locale,
    );
  }

  // =============================
  // 云端 list -> InboxItem
  // =============================
  factory InboxItem.fromCloudList(CloudListItem c) {
    final title = c.title.trim().isEmpty ? '---' : c.title.trim();

    return InboxItem(
      id: c.id,
      localId: null,
      cloudId: c.id,
      groupId: c.groupId,
      sourceType: InboxSourceType.cloud,
      createdAt: c.createdAt, // ✅
      title: title,
      summary: '',
      dueAt: parseDueAt(c.dueAt),
      amount: null,
      currency: null,
      risk: mapRisk(c.risk),
      sourceHint: (c.sourceHint ?? '').trim(),
      status: mapStatus(dbStatus: c.status, dbRisk: c.risk),
      rawText: '',
      locale: c.locale ?? '',
    );
  }

  // =============================
  // 云端 detail -> InboxItem
  // =============================
  factory InboxItem.fromCloudDetail(CloudDetail d) {
    final n = d.normalizedMap;

    final title = (n['title'] ?? '').toString().trim();
    final summary = (n['notes'] ?? n['summary'] ?? '').toString();

    final riskStr = (n['risk'] ?? 'low').toString();
    final statusStr = (n['status'] ?? 'pending').toString();
    final dueAtStr = (n['due_at'] ?? '').toString();

    final amountVal = n['amount'];
    final amount = amountVal is num ? amountVal.round() : null;

    final currency = (n['currency'] ?? '').toString();

    return InboxItem(
      id: d.id,
      localId: null,
      cloudId: d.id,
      groupId: d.groupId,
      sourceType: InboxSourceType.cloud,
      createdAt: d.createdAt, // ✅
      title: title.isEmpty ? '---' : title,
      summary: summary,
      dueAt: parseDueAt(dueAtStr.isNotEmpty ? dueAtStr : d.dueAt),
      amount: amount,
      currency: currency.isEmpty ? null : currency,
      risk: mapRisk(riskStr),
      sourceHint: d.sourceHint ?? '',
      status: mapStatus(dbStatus: statusStr, dbRisk: riskStr),
      rawText: d.rawText,
      locale: d.locale ?? '',
    );
  }

  InboxItem copyWith({
    String? id,
    String? localId,
    String? cloudId,
    String? groupId,
    InboxSourceType? sourceType,
    DateTime? createdAt,
    String? title,
    String? summary,
    DateTime? dueAt,
    int? amount,
    String? currency,
    RiskLevel? risk,
    String? source,
    InboxStatus? status,
    String? rawText,
    String? locale,
  }) {
    return InboxItem(
      id: id ?? this.id,
      localId: localId ?? this.localId,
      cloudId: cloudId ?? this.cloudId,
      groupId: groupId ?? this.groupId,
      sourceType: sourceType ?? this.sourceType,
      createdAt: createdAt ?? this.createdAt,
      title: title ?? this.title,
      summary: summary ?? this.summary,
      dueAt: dueAt ?? this.dueAt,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      risk: risk ?? this.risk,
      sourceHint: source ?? this.sourceHint,
      status: status ?? this.status,
      rawText: rawText ?? this.rawText,
      locale: locale ?? this.locale,
    );
  }
}
