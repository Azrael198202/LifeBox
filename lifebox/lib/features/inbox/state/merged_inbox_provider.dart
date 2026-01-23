import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/inbox_item.dart';
import '../domain/local_inbox_record.dart';
import '../domain/cloud_models.dart';

import 'local_inbox_providers.dart';
import 'cloud_inbox_providers.dart';

/// =============================
/// 本地 + 云端（个人+群组）整合后的最终列表
/// UI 层只 watch 这个
/// =============================
final mergedInboxProvider = FutureProvider<List<InboxItem>>((ref) async {
  // 1) 本地数据
  final List<LocalInboxRecord> local =
      await ref.watch(localInboxListProvider.future);

  // 2) 云端个人
  final List<CloudListItem> cloudMine =
      await ref.watch(cloudMyInboxProvider.future);

  // 3) 云端所有群组
  final List<CloudListItem> cloudGroups =
      await ref.watch(cloudAllGroupsInboxProvider.future);

  // =============================
  // 合并：本地优先 + 云端补齐
  // =============================
  final Map<String, InboxItem> byKey = {};

  String _keyForItem(InboxItem item) {
    // InboxItem 里应该有 localId/cloudId（你前面已接受该设计）
    if (item.cloudId != null && item.cloudId!.isNotEmpty) return item.cloudId!;
    if (item.localId != null && item.localId!.isNotEmpty) return item.localId!;
    return item.id;
  }

  // A) 本地 -> InboxItem（优先写入）
  for (final r in local) {
    final item = InboxItem.fromLocal(r);
    byKey[_keyForItem(item)] = item;
  }

  // B) 云端个人 -> 如果本地没有，就补
  for (final c in cloudMine) {
    final item = InboxItem.fromCloudList(c);
    final key = _keyForItem(item);

    if (!byKey.containsKey(key)) {
      byKey[key] = item;
    }
  }

  // C) 云端群组 -> 如果本地没有，就补
  for (final c in cloudGroups) {
    final item = InboxItem.fromCloudList(c);
    final key = _keyForItem(item);

    if (!byKey.containsKey(key)) {
      byKey[key] = item;
    }
  }

  final merged = byKey.values.toList();

  // =============================
  // 排序： createdAt
  // =============================
  merged.sort((a, b) => b.createdAt.compareTo(a.createdAt));

  return merged;
});
