import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/state/auth_providers.dart';
import '../../settings/state/settings_providers.dart';
import '../domain/cloud_models.dart';
import 'cloud_inbox_service_provider.dart';

/// =============================
/// 云端：个人记录（owner_user_id & group_id is null）
/// GET /api/cloud/records
/// =============================
final cloudMyInboxProvider = FutureProvider<List<CloudListItem>>((ref) async {
  final cloudEnabled = ref.read(cloudEnabledProvider);
  if (!cloudEnabled) return const [];

  final auth = ref.read(authControllerProvider);
  final token = auth.accessToken;
  if (token == null || token.isEmpty) return const [];

  final svc = ref.read(cloudInboxServiceProvider);
  return svc.listMyRecords(accessToken: token, limit: 200);
});

/// =============================
/// 云端：某一个群组记录
/// GET /api/cloud/records?group_id=xxx
/// =============================
final cloudGroupInboxProvider =
    FutureProvider.family<List<CloudListItem>, String>((ref, groupId) async {
  final cloudEnabled = ref.read(cloudEnabledProvider);
  if (!cloudEnabled) return const [];

  final auth = ref.read(authControllerProvider);
  final token = auth.accessToken;
  if (token == null || token.isEmpty) return const [];

  final svc = ref.read(cloudInboxServiceProvider);
  return svc.listGroupRecords(
    accessToken: token,
    groupId: groupId,
    limit: 200,
  );
});

/// =============================
/// 云端：所有群组记录（把 auth.groups 全部拉一遍再合并）
/// - 用于“群组里别人创建的记录”
/// - 你不想在 UI 层循环调用，就放这里
/// =============================
final cloudAllGroupsInboxProvider =
    FutureProvider<List<CloudListItem>>((ref) async {
  final cloudEnabled = ref.read(cloudEnabledProvider);
  if (!cloudEnabled) return const [];

  final auth = ref.read(authControllerProvider);
  final token = auth.accessToken;
  if (token == null || token.isEmpty) return const [];

  // auth.groups: List<GroupBrief> （你项目里已有）
  final groups = auth.groups;
  if (groups.isEmpty) return const [];

  final svc = ref.read(cloudInboxServiceProvider);

  // 逐个 group 拉取并合并
  final List<CloudListItem> all = [];
  for (final g in groups) {
    final list = await svc.listGroupRecords(
      accessToken: token,
      groupId: g.id,
      limit: 200,
    );
    all.addAll(list);
  }

  // 去重：按 cloud record id
  final map = <String, CloudListItem>{};
  for (final x in all) {
    map[x.id] = x;
  }

  // 排序（云端 createdAt 新的在前）
  final result = map.values.toList()
    ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

  return result;
});
