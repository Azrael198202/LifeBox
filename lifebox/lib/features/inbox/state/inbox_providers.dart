import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/inbox_item.dart';
import '../../../core/widgets/risk_badge.dart';

final inboxItemsProvider = StateProvider<List<InboxItem>>((ref) {
  final now = DateTime.now();
  return [
    InboxItem(
      id: '1',
      title: '学校：下周家长会确认',
      dueAt: now.add(const Duration(days: 2)),
      risk: RiskLevel.mid,
      source: '学校',
      status: InboxStatus.high,
    ),
    InboxItem(
      id: '2',
      title: '银行：信用卡还款提醒',
      dueAt: now.add(const Duration(days: 5)),
      risk: RiskLevel.high,
      source: '银行',
      status: InboxStatus.pending,
    ),
    InboxItem(
      id: '3',
      title: '医院：复诊预约',
      dueAt: null,
      risk: RiskLevel.low,
      source: '医院',
      status: InboxStatus.done,
    ),
  ];
});
