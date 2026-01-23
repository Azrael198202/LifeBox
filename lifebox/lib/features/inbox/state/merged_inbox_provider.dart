import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/inbox_item.dart';
import 'local_inbox_providers.dart';
import 'cloud_inbox_providers.dart';

/// =============================
/// 本地 + 云端（个人+群组）整合后的最终列表
/// UI 层只 watch 这个
/// =============================
final mergedInboxProvider = FutureProvider<List<InboxItem>>((ref) async {
  final local = await ref.watch(localInboxListProvider.future);
  final cloudMine = await ref.watch(cloudMyInboxProvider.future);
  final cloudGroups = await ref.watch(cloudAllGroupsInboxProvider.future);

  final byKey = <String, InboxItem>{};

  String keyFor(InboxItem item) =>
      (item.cloudId?.isNotEmpty == true) ? item.cloudId! : (item.localId ?? item.id);

  for (final r in local) {
    final item = InboxItem.fromLocal(r);
    byKey[keyFor(item)] = item;
  }
  for (final c in cloudMine) {
    final item = InboxItem.fromCloudList(c);
    byKey.putIfAbsent(keyFor(item), () => item);
  }
  for (final c in cloudGroups) {
    final item = InboxItem.fromCloudList(c);
    byKey.putIfAbsent(keyFor(item), () => item);
  }

  final merged = byKey.values.toList()
    ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

  return merged;
});


