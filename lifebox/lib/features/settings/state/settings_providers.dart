import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lifebox/core/services/user_profile_cloud_service.dart';
import 'package:lifebox/features/auth/state/auth_providers.dart';
import '../../inbox/data/cloud_settings_store.dart';
import '../data/user_profile_store.dart';

final cloudSettingsStoreProvider = Provider((ref) => CloudSettingsStore());

final cloudEnabledProvider = StateNotifierProvider<CloudEnabledNotifier, bool>(
  (ref) => CloudEnabledNotifier(ref),
);

class CloudEnabledNotifier extends StateNotifier<bool> {
  CloudEnabledNotifier(this.ref) : super(false) {
    _load();
  }

  final Ref ref;

  Future<void> _load() async {
    final store = ref.read(cloudSettingsStoreProvider);
    state = await store.getCloudEnabled();
  }

  Future<void> setEnabled(bool v) async {
    state = v;
    final store = ref.read(cloudSettingsStoreProvider);
    await store.setCloudEnabled(v);
  }
}

// Personal user profile
String avatarUrlFromId(String avatarId) => 'default:$avatarId';
String? avatarIdFromAvatarUrl(String? avatarUrl) {
  if (avatarUrl == null || avatarUrl.isEmpty) return null;
  if (avatarUrl.startsWith('default:')){
    return avatarUrl.substring('default:'.length);
  }
  return null;
}

final userProfileCloudServiceProvider =
    Provider<UserProfileCloudService>((ref) {
  return UserProfileCloudService(
    getAccessToken: () async => ref.read(authControllerProvider).accessToken,
  );
});

/// ✅ UI 只 watch 这个
final userProfileProvider =
    StateNotifierProvider<UserProfileNotifier, UserProfile>((ref) {
  return UserProfileNotifier(ref);
});

class UserProfileNotifier extends StateNotifier<UserProfile> {
  UserProfileNotifier(this.ref) : super(const UserProfile()) {
    _syncFromAuth();
  }

  final Ref ref;

  /// 从 auth.user 同步（云端权威）
  void _syncFromAuth() {
    // 监听 auth 变化（登录/refreshMe 后会变）
    ref.listen(authControllerProvider, (prev, next) {
      final u = next.user;
      final nick = (u?.displayName ?? '').trim();
      final avatarId = avatarIdFromAvatarUrl(u?.avatarUrl) ?? state.avatarId;

      state = state.copyWith(
        nickname: nick, // 让 UI 的初始值来自云端
        avatarId: avatarId, // picker 选中态
      );
    });
  }

  Future<void> setNickname(String v) async {
    final name = v.trim();
    if (name.isEmpty) return;

    // 未登录：只改本地 state（或你也可以直接 return）
    final auth = ref.read(authControllerProvider);
    final token = auth.accessToken; // String?

    if (token == null || token.isEmpty) {
      state = state.copyWith(nickname: name);
      return;
    }

    // 乐观更新
    state = state.copyWith(nickname: name);

    // 写云端
    await ref.read(userProfileCloudServiceProvider).patchMe(displayName: name);

    // ✅ refreshMe 后 auth.user 会更新 -> listen 会再同步一次
    await ref.read(authControllerProvider.notifier).refreshMe();
  }

  Future<void> setAvatarId(String avatarId) async {
    state = state.copyWith(avatarId: avatarId);

    final auth = ref.read(authControllerProvider);
    final token = auth.accessToken; // String?

    if (token == null || token.isEmpty) {
      return;
    }

    final avatarUrl = avatarUrlFromId(avatarId);

    await ref
        .read(userProfileCloudServiceProvider)
        .patchMe(avatarUrl: avatarUrl);

    await ref.read(authControllerProvider.notifier).refreshMe();
  }
}
