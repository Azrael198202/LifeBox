import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'local_inbox_providers.dart';
import 'cloud_inbox_providers.dart';
import 'merged_inbox_provider.dart';

/// ✅ 统一刷新 Inbox（本地 + 云端 + 合并）
void refreshInboxProviders(WidgetRef ref) {
  // 先让数据源失效
  ref.invalidate(localInboxListProvider);
  ref.invalidate(cloudMyInboxProvider);
  ref.invalidate(cloudAllGroupsInboxProvider);

  // 再让聚合结果失效
  ref.invalidate(mergedInboxProvider);
}
