import 'package:flutter_riverpod/flutter_riverpod.dart';
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

// =============================
// Personal info (local)
// =============================

final userProfileStoreProvider = Provider((ref) => UserProfileStore());

final userProfileProvider =
    StateNotifierProvider<UserProfileNotifier, UserProfile>((ref) {
  return UserProfileNotifier(ref);
});

class UserProfileNotifier extends StateNotifier<UserProfile> {
  UserProfileNotifier(this.ref) : super(const UserProfile()) {
    _load();
  }

  final Ref ref;

  Future<void> _load() async {
    final store = ref.read(userProfileStoreProvider);
    state = await store.getProfile();
  }

  Future<void> setNickname(String v) async {
    state = state.copyWith(nickname: v);
    await ref.read(userProfileStoreProvider).setNickname(v);
  }

  Future<void> setAvatarId(String v) async {
    state = state.copyWith(avatarId: v);
    await ref.read(userProfileStoreProvider).setAvatarId(v);
  }
}
