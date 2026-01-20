import 'package:shared_preferences/shared_preferences.dart';

class UserProfile {
  final String nickname;
  final String avatarId; // default avatar key

  const UserProfile({
    this.nickname = '',
    this.avatarId = 'a1',
  });

  UserProfile copyWith({
    String? nickname,
    String? avatarId,
  }) {
    return UserProfile(
      nickname: nickname ?? this.nickname,
      avatarId: avatarId ?? this.avatarId,
    );
  }
}

class UserProfileStore {
  static const _kNickname = 'profile_nickname';
  static const _kTimezone = 'profile_timezone';
  static const _kAvatarId = 'profile_avatar_id';

  Future<UserProfile> getProfile() async {
    final sp = await SharedPreferences.getInstance();
    return UserProfile(
      nickname: sp.getString(_kNickname) ?? '',
      avatarId: sp.getString(_kAvatarId) ?? 'a1',
    );
  }

  Future<void> setNickname(String v) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString(_kNickname, v);
  }

  Future<void> setTimezone(String v) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString(_kTimezone, v);
  }

  Future<void> setAvatarId(String v) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString(_kAvatarId, v);
  }
}
