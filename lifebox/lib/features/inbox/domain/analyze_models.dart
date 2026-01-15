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
  final String summary;
  final String? dueAt; // "YYYY-MM-DD" or null
  final int? amount;
  final String? currency; // "JPY" / "CNY" etc
  final String risk; // "high" "mid" "low"
  final String source;

  AnalyzeResponse({
    required this.title,
    required this.summary,
    required this.dueAt,
    required this.amount,
    required this.currency,
    required this.risk,
    required this.source,
  });

  Map<String, dynamic> toJson() => {
        "title": title,
        "summary": summary,
        "due_at": dueAt,
        "amount": amount,
        "currency": currency,
        "risk": risk,
        "source": source,
      };
}
