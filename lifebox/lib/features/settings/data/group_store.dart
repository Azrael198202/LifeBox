import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// =============================
/// Models
/// =============================

class GroupMember {
  final String id;
  final String name;
  final String email;
  final String role; // owner | member

  const GroupMember({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
  });

  GroupMember copyWith({String? role}) => GroupMember(
        id: id,
        name: name,
        email: email,
        role: role ?? this.role,
      );
}

class Group {
  final String id;
  final String name;
  final List<GroupMember> members;

  const Group({
    required this.id,
    required this.name,
    this.members = const [],
  });

  Group copyWith({
    String? name,
    List<GroupMember>? members,
  }) {
    return Group(
      id: id,
      name: name ?? this.name,
      members: members ?? this.members,
    );
  }
}

/// =============================
/// Store (SharedPreferences)
/// =============================
class GroupStore {
  static const _kGroups = 'groups_json'; // List<Group> JSON
  static const _kActiveGroupId = 'active_group_id';

  // ---------- public ----------

  Future<List<Group>> getGroups() async {
    final sp = await SharedPreferences.getInstance();
    final raw = sp.getString(_kGroups);
    if (raw == null || raw.isEmpty) return const [];
    final decoded = jsonDecode(raw) as List;
    return decoded
        .map((e) => _groupFromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<Group?> getGroupById(String groupId) async {
    final groups = await getGroups();
    try {
      return groups.firstWhere((g) => g.id == groupId);
    } catch (_) {
      return null;
    }
  }

  Future<void> saveGroups(List<Group> groups) async {
    final sp = await SharedPreferences.getInstance();
    final raw = jsonEncode(groups.map(_groupToJson).toList());
    await sp.setString(_kGroups, raw);
  }

  Future<void> setActiveGroupId(String groupId) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString(_kActiveGroupId, groupId);
  }

  Future<String?> getActiveGroupId() async {
    final sp = await SharedPreferences.getInstance();
    return sp.getString(_kActiveGroupId);
  }

  // ---------- operations ----------

  /// 创建 group：owner 作为第一个成员
  Future<Group> createGroup({
    required String groupId,
    required String name,
    required GroupMember owner,
  }) async {
    final groups = await getGroups();

    final g = Group(
      id: groupId,
      name: name,
      members: [
        owner.role == 'owner' ? owner : owner.copyWith(role: 'owner'),
      ],
    );

    await saveGroups([g, ...groups]);
    await setActiveGroupId(groupId);
    return g;
  }

  /// 改名（权限建议 UI/Service 层控制）
  Future<void> renameGroup(String groupId, String newName) async {
    final groups = await getGroups();
    final updated = groups.map((g) {
      if (g.id != groupId) return g;
      return g.copyWith(name: newName);
    }).toList();
    await saveGroups(updated);
  }

  /// 添加成员（默认 member）
  Future<void> addMember(String groupId, GroupMember member) async {
    final groups = await getGroups();
    final updated = groups.map((g) {
      if (g.id != groupId) return g;

      final exists = g.members.any((m) => m.id == member.id);
      if (exists) return g;

      final m = member.role == 'member' ? member : member.copyWith(role: 'member');
      return g.copyWith(members: [...g.members, m]);
    }).toList();

    await saveGroups(updated);
  }

  /// 移除成员（这里做一层保护：owner 不允许移除）
  Future<void> removeMember(String groupId, String memberId) async {
    final groups = await getGroups();
    final updated = groups.map((g) {
      if (g.id != groupId) return g;

      final target = g.members.where((m) => m.id == memberId).toList();
      if (target.isEmpty) return g;
      if (target.first.role == 'owner') return g; // 防御：不删 owner

      return g.copyWith(
        members: g.members.where((m) => m.id != memberId).toList(),
      );
    }).toList();

    await saveGroups(updated);
  }

  /// owner 迁移（原 owner -> member，新 owner -> owner）
  Future<void> transferOwner(String groupId, String newOwnerId) async {
    final groups = await getGroups();
    final updated = groups.map((g) {
      if (g.id != groupId) return g;

      final hasTarget = g.members.any((m) => m.id == newOwnerId);
      if (!hasTarget) return g;

      final oldOwnerList = g.members.where((m) => m.role == 'owner').toList();
      if (oldOwnerList.isEmpty) return g;

      return g.copyWith(
        members: g.members.map((m) {
          if (m.role == 'owner') return m.copyWith(role: 'member');
          if (m.id == newOwnerId) return m.copyWith(role: 'owner');
          return m;
        }).toList(),
      );
    }).toList();

    await saveGroups(updated);
  }

  /// 删除 group
  Future<void> deleteGroup(String groupId) async {
    final groups = await getGroups();
    final updated = groups.where((g) => g.id != groupId).toList();
    await saveGroups(updated);

    final sp = await SharedPreferences.getInstance();
    final active = sp.getString(_kActiveGroupId);
    if (active == groupId) {
      await sp.remove(_kActiveGroupId);
    }
  }

  /// 调试用：清空
  Future<void> debugClearAll() async {
    final sp = await SharedPreferences.getInstance();
    await sp.remove(_kGroups);
    await sp.remove(_kActiveGroupId);
  }

  // ---------- json helpers (store-only) ----------
  Map<String, dynamic> _groupToJson(Group g) => {
        'id': g.id,
        'name': g.name,
        'members': g.members.map(_memberToJson).toList(),
      };

  Group _groupFromJson(Map<String, dynamic> j) {
    final membersRaw = (j['members'] as List?) ?? const [];
    return Group(
      id: (j['id'] ?? '').toString(),
      name: (j['name'] ?? '').toString(),
      members: membersRaw
          .map((e) => _memberFromJson(Map<String, dynamic>.from(e)))
          .toList(),
    );
  }

  Map<String, dynamic> _memberToJson(GroupMember m) => {
        'id': m.id,
        'name': m.name,
        'email': m.email,
        'role': m.role,
      };

  GroupMember _memberFromJson(Map<String, dynamic> j) => GroupMember(
        id: (j['id'] ?? '').toString(),
        name: (j['name'] ?? '').toString(),
        email: (j['email'] ?? '').toString(),
        role: (j['role'] ?? 'member').toString(),
      );
}
