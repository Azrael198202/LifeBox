import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/inbox_item.dart';
import '../../../core/widgets/risk_badge.dart';

final inboxItemsProvider = StateProvider<List<InboxItem>>((ref) {
  final now = DateTime.now();
  return [
    InboxItem(
      id: '1',
      title: '学校：来週の保護者会の確認',
      dueAt: now.add(const Duration(days: 2)),
      risk: RiskLevel.mid,
      source: '学校',
      status: InboxStatus.high,
    ),
    InboxItem(
      id: '2',
      title: '銀行：クレジットカードの支払い通知',
      dueAt: now.add(const Duration(days: 5)),
      risk: RiskLevel.high,
      source: '銀行',
      status: InboxStatus.pending,
    ),
    InboxItem(
      id: '3',
      title: '病院：再診の予約',
      dueAt: null,
      risk: RiskLevel.low,
      source: '病院',
      status: InboxStatus.done,
    ),
  ];
});
