import 'dart:convert';

class CloudDetail {
  final String id;
  final DateTime createdAt;        // ISO string
  final String rawText;          // 原始文本
  final String? locale;
  final String? sourceHint;
  final String? groupId;         // null = 个人记录
  final String normalized;       // ⚠️ JSON 字符串（权威数据）

  const CloudDetail({
    required this.id,
    required this.createdAt,
    required this.rawText,
    required this.normalized,
    this.locale,
    this.sourceHint,
    this.groupId,
  });

  factory CloudDetail.fromJson(Map<String, dynamic> json) {
    return CloudDetail(
      id: json['id'] as String,
      createdAt: json['created_at'] as DateTime,
      rawText: json['raw_text'] as String,
      normalized: json['normalized'] as String,
      locale: json['locale'] as String?,
      sourceHint: json['source_hint'] as String?,
      groupId: json['group_id'] as String?,
    );
  }

  /// =============================
  /// normalized 解析（核心）
  /// =============================

  Map<String, dynamic> get normalizedMap {
    try {
      return jsonDecode(normalized) as Map<String, dynamic>;
    } catch (_) {
      return {};
    }
  }

  /// ===== 以下是常用字段的便捷 getter =====

  String get title =>
      (normalizedMap['title'] ?? '').toString();

  String? get summary {
    final v = normalizedMap['notes'] ?? normalizedMap['summary'];
    return v?.toString();
  }

  String? get dueAt =>
      normalizedMap['due_at']?.toString();

  double? get amount {
    final v = normalizedMap['amount'];
    return v is num ? v.toDouble() : null;
  }

  String? get currency =>
      normalizedMap['currency']?.toString();

  String get risk =>
      (normalizedMap['risk'] ?? 'low').toString();

  String get status =>
      (normalizedMap['status'] ?? 'pending').toString();

  List<String> get phones =>
      (normalizedMap['phones'] as List?)
          ?.map((e) => e.toString())
          .toList() ??
      const [];

  List<String> get urls =>
      (normalizedMap['urls'] as List?)
          ?.map((e) => e.toString())
          .toList() ??
      const [];

  List<String> get suggestedActions =>
      (normalizedMap['suggested_actions'] as List?)
          ?.map((e) => e.toString())
          .toList() ??
      const [];
}
