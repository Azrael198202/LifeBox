class CloudListItem {
  final String id;
  final DateTime createdAt;
  final String locale;          // ✅ 新增
  final String title;
  final String risk;
  final String status;
  final String? dueAt;
  final String? sourceHint;
  final String? groupId;

  CloudListItem({
    required this.id,
    required this.createdAt,
    required this.locale,
    required this.title,
    required this.risk,
    required this.status,
    required this.dueAt,
    required this.sourceHint,
    required this.groupId,
  });

  factory CloudListItem.fromJson(Map<String, dynamic> json) {
    return CloudListItem(
      id: json['id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      locale: (json['locale'] as String?) ?? 'ja', // ✅ 兜底
      title: (json['title'] as String?) ?? '',
      risk: (json['risk'] as String?) ?? 'low',
      status: (json['status'] as String?) ?? 'pending',
      dueAt: json['due_at'] as String?,
      sourceHint: json['source_hint'] as String?,
      groupId: json['group_id'] as String?,
    );
  }
}
