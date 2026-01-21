class LocalInboxRecord {
  final String id;
  final String rawText;
  final String locale;
  final String sourceHint;

  final String title;
  final String summary;
  final String? dueAt;
  final int? amount;
  final String? currency;
  final String risk; // high/mid/low

  final String? groupId; // null = 個人
  final int colorValue; // ARGB int, e.g. 0xFF2196F3

  final String status; // pending/done etc
  final DateTime createdAt;

  LocalInboxRecord({
    required this.id,
    required this.rawText,
    required this.locale,
    required this.sourceHint,
    required this.title,
    required this.summary,
    required this.dueAt,
    required this.amount,
    required this.currency,
    required this.risk,
    required this.status,
    required this.createdAt,
    required this.groupId,
    required this.colorValue,
  });

  Map<String, dynamic> toMap() => {
        "id": id,
        "raw_text": rawText,
        "locale": locale,
        "source_hint": sourceHint,
        "title": title,
        "summary": summary,
        "due_at": dueAt,
        "amount": amount,
        "currency": currency,
        "risk": risk,
        "status": status,
        "created_at": createdAt.toIso8601String(),
        "group_id": groupId,
        "color_value": colorValue,
      };

  static LocalInboxRecord fromMap(Map<String, dynamic> m) => LocalInboxRecord(
        id: m["id"] as String,
        rawText: (m["raw_text"] as String?) ?? "",
        locale: (m["locale"] as String?) ?? "ja",
        sourceHint: (m["source_hint"] as String?) ?? "",
        title: (m["title"] as String?) ?? "",
        summary: (m["summary"] as String?) ?? "",
        dueAt: m["due_at"] as String?,
        amount: m["amount"] as int?,
        currency: m["currency"] as String?,
        risk: (m["risk"] as String?) ?? "low",
        status: (m["status"] as String?) ?? "pending",
        createdAt: DateTime.tryParse((m["created_at"] as String?) ?? "") ??
            DateTime.now(),
        groupId: m["group_id"] as String?,
        colorValue: (m["color_value"] as int?) ?? 0xFF2196F3
      );
}
