import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lifebox/features/inbox/domain/cloud_models.dart';

import '../domain/inbox_item.dart';
import 'local_inbox_providers.dart';
import 'cloud_inbox_providers.dart';

final inboxRefreshTokenProvider = StateProvider<int>((_) => 0);

/// =============================
/// local + Cloud（personal + groups）to get merged list
/// UI use this provider
/// =============================
final mergedInboxProvider = FutureProvider<List<InboxItem>>((ref) async {

  // refresh Token
  ref.watch(inboxRefreshTokenProvider);

  final local = await ref.watch(localInboxListProvider.future);
  final cloudMine = await ref.watch(cloudMyInboxProvider.future);
  final cloudGroups = await ref.watch(cloudAllGroupsInboxProvider.future);

  final byKey = <String, InboxItem>{};

  String keyFor(InboxItem item) {
    // Cloud：clientId (= local id) optimized
    if (item.clientId != null && item.clientId!.isNotEmpty) {
      return item.clientId!;
    }

    // local
    if (item.id.isNotEmpty) return item.id;

    // last ：cloudId
    if (item.cloudId != null && item.cloudId!.isNotEmpty) {
      return item.cloudId!;
    }

    return item.id;
  }

  // 1) local first
  for (final r in local) {
    final item = InboxItem.fromLocal(r);
    byKey[keyFor(item)] = item;
  }

  // 2) Cloud next  
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

  for (final c in cloudMine) {
    mergeCloud(c);
  }

  for (final c in cloudGroups) {
    mergeCloud(c);
  }
  final merged = byKey.values.toList()
    ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

  return merged;
});
