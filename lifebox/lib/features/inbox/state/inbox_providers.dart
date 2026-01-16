import 'package:flutter_riverpod/flutter_riverpod.dart';

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
