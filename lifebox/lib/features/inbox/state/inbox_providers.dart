import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lifebox/core/services/holiday_service.dart';

import '../domain/inbox_item.dart';
import '../../inbox/state/local_inbox_providers.dart';

/// ✅ UI 用 InboxItem 列表（来源：本地 DB）
final inboxItemsProvider = FutureProvider<List<InboxItem>>((ref) async {
  final records = await ref.watch(localInboxListProvider.future);

  return records
      .map((r) => InboxItem.fromLocal(r))
      .toList()
    ..sort((a, b) {
      // 可选：按创建时间/到期日排序（先到期的在前）
      if (a.dueAt == null && b.dueAt == null) return 0;
      if (a.dueAt == null) return 1;
      if (b.dueAt == null) return -1;
      return a.dueAt!.compareTo(b.dueAt!);
    });
});

final holidayServiceProvider = Provider<HolidayService>((ref) {
  return HolidayService();
});

final cnJpHolidaysByYearProvider =
    FutureProvider.family<Map<DateTime, List<Holiday>>, int>((ref, year) async {
  final svc = ref.read(holidayServiceProvider);
  return svc.getCnJpHolidaysByDay(year: year);
});