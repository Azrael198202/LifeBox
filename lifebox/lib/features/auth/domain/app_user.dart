class AppUser {
  final String id;
  final String? email;
  final String? displayName;
  final String? avatarUrl;

  const AppUser({
    required this.id,
    this.email,
    this.displayName,
    this.avatarUrl,
  });

  factory AppUser.fromJson(Map<String, dynamic> j) => AppUser(
        id: j['id'] as String,
        email: j['email'] as String?,
        displayName: j['display_name'] as String? ?? j['displayName'] as String?,
        avatarUrl: j['avatar_url'] as String? ?? j['avatarUrl'] as String?,
      );
}

class GroupBrief {
  final String id;
  final String name;
  final String groupType;
  final String role;

  const GroupBrief({
    required this.id,
    required this.name,
    required this.groupType,
    required this.role,
  });

  factory GroupBrief.fromJson(Map<String, dynamic> j) => GroupBrief(
        id: j['id'] as String,
        name: j['name'] as String,
        groupType: j['group_type'] as String? ?? j['groupType'] as String? ?? 'family',
        role: j['role'] as String? ?? 'member',
      );
}

class AuthSession {
  final String accessToken;
  final AppUser user;
  final List<GroupBrief> groups;

  const AuthSession({
    required this.accessToken,
    required this.user,
    required this.groups,
  });

  factory AuthSession.fromJson(Map<String, dynamic> j) => AuthSession(
        accessToken: j['access_token'] as String,
        user: AppUser.fromJson(j['user'] as Map<String, dynamic>),
        groups: (j['groups'] as List<dynamic>? ?? const [])
            .map((e) => GroupBrief.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}
