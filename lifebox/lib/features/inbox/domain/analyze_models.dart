class AnalyzeRequest {
  final String text;
  final String locale; // "ja" / "zh" / "en"
  final String sourceHint;

  AnalyzeRequest({
    required this.text,
    required this.locale,
    required this.sourceHint,
  });

  Map<String, dynamic> toJson() => {
        "text": text,
        "locale": locale,
        "source_hint": sourceHint,
      };
}

class AnalyzeResponse {
  final String title;
  final String? source;
  final String? dueAt;
  final double? amount;
  final String? currency;
  final String risk;
  final String status;
  final String? notes;

  AnalyzeResponse({
    required this.title,
    this.source,
    this.dueAt,
    this.amount,
    this.currency,
    required this.risk,
    required this.status,
    this.notes,
  });

  factory AnalyzeResponse.fromJson(Map<String, dynamic> json) {
    return AnalyzeResponse(
      title: (json['title'] ?? '') as String,
      source: json['source'] as String?,
      dueAt: json['due_at'] as String?,
      amount: (json['amount'] as num?)?.toDouble(),
      currency: json['currency'] as String?,
      risk: (json['risk'] ?? 'low') as String,
      status: (json['status'] ?? 'pending') as String,
      notes: json['notes'] as String?,
    );
  }

  // 兼容你 UI 里用 summary 的写法（可选）
  String get summary => notes ?? '';
}
