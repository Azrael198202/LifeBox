import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lifebox/features/inbox/domain/cloud_models.dart';

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

  String keyFor(InboxItem item) {
    // ✅ client_id = localId 是第一优先级
    if (item.localId != null && item.localId!.isNotEmpty) {
      return 'local:${item.localId}';
    }
    if (item.cloudId != null && item.cloudId!.isNotEmpty) {
      return 'cloud:${item.cloudId}';
    }
    return 'id:${item.id}';
  }

  // 1) 本地优先
  for (final r in local) {
    final item = InboxItem.fromLocal(r);
    byKey[keyFor(item)] = item;
  }

  // 2) 云端补齐（命中本地则 merge）
  void mergeCloud(CloudListItem c) {
    final cloudItem = InboxItem.fromCloudList(c);
    final k = keyFor(cloudItem);

    final existed = byKey[k];
    if (existed == null) {
      byKey[k] = cloudItem;
      return;
    }
    
    byKey[k] = existed.copyWith(
      cloudId: existed.cloudId ?? cloudItem.cloudId,
      groupId: existed.groupId ?? cloudItem.groupId,
      createdAt: existed.createdAt,
      locale: existed.locale.isNotEmpty ? existed.locale : cloudItem.locale,
      title: existed.title.trim().isEmpty ? cloudItem.title : existed.title,
    );
  }

  for (final c in cloudMine) mergeCloud(c);
  for (final c in cloudGroups) mergeCloud(c);

  final merged = byKey.values.toList()
    ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

  return merged;
});
