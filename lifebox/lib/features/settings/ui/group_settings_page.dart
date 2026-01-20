import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lifebox/features/auth/domain/app_user.dart';
import 'package:lifebox/features/settings/data/group_store.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/app_scaffold.dart';
import '../../auth/state/auth_controller.dart';
import '../state/settings_providers.dart';
import 'add_member_sheet.dart';
import 'avatar_picker.dart';

/// =============================
/// Page
/// =============================
class GroupSettingsPage extends ConsumerStatefulWidget {
  const GroupSettingsPage({super.key, this.groupId});
  final String? groupId;

  @override
  ConsumerState<GroupSettingsPage> createState() => _GroupSettingsPageState();
}

class _GroupSettingsPageState extends ConsumerState<GroupSettingsPage> {
  /// mock members（后续由 API 替换）
  late List<GroupMember> _members;

  String? _familyName;

  bool get _isCreateMode => widget.groupId == null;

  /// ⚠️ TODO：后续替换成 auth.user!.id
  String get _currentUserId => 'me';

  String get _viewerRole =>
      _members.firstWhere((m) => m.id == _currentUserId).role;

  bool get _isOwner => _viewerRole == 'owner';

  @override
  void initState() {
    super.initState();
    _members = [];
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authControllerProvider);
    final profile = ref.watch(userProfileProvider);

    GroupBrief? group;
    if (_isCreateMode) {
      group = null;
    } else {
      group = auth.groups
          .where((g) => g.id == widget.groupId)
          .cast<GroupBrief?>()
          .firstOrNull;
    }

    /// mock 初始化
    if (_members.isEmpty) {
      if (_isCreateMode) {
        // 新建：只有自己，owner
        _members = [
          GroupMember(
            id: _currentUserId,
            name: profile.nickname.isNotEmpty
                ? profile.nickname
                : (auth.user?.displayName ?? '---'),
            email: auth.user?.email ?? '',
            role: 'owner',
          ),
        ];
      } else {
        // 编辑：读取已有 group（现在仍然 mock，后续换成 store）
        _members = [
          GroupMember(
            id: _currentUserId,
            name: profile.nickname.isNotEmpty
                ? profile.nickname
                : (auth.user?.displayName ?? '---'),
            email: auth.user?.email ?? '',
            role: 'owner',
          ),
          const GroupMember(
              id: 'mama', name: 'MAMA', email: '', role: 'member'),
        ];
      }
    }

    return AppScaffold(
      title: _isCreateMode ? 'グループ作成' : 'グループ設定',
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildFamilyInfoCard(context, group),
          const SizedBox(height: 12),
          _buildMembersSection(context, auth, profile),
          const SizedBox(height: 12),
          _buildAddMember(context),
          const SizedBox(height: 16),
          _isCreateMode
              ? _buildCreateGroup(context)
              : _buildDeleteGroup(context),
        ],
      ),
    );
  }

  /// =============================
  /// UI Blocks
  /// =============================

  Widget _buildFamilyInfoCard(BuildContext context, dynamic group) {
    return Card(
      child: Column(
        children: [
          ListTile(
            title: Text(_isCreateMode ? 'グループ作成' : 'グループ設定'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _familyName ?? (_isCreateMode ? '' : (group?.name ?? '---')),
                  style: const TextStyle(color: Colors.black54),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.chevron_right),
              ],
            ),
            onTap: () async {
              if (!_isOwner) {
                _toast(context, 'オーナーのみ変更できます');
                return;
              }

              final name = await _showEditTextDialog(
                context,
                title: _isCreateMode ? 'グループ名を入力' : 'グループ名称',
                initialValue: group?.name ?? '',
              );
              if (name == null || name.trim().isEmpty) return;

              // TODO: API rename
              setState(() => _familyName = name.trim());

              if (!_isCreateMode) {
                // TODO: 编辑模式：PATCH group name
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMembersSection(
    BuildContext context,
    dynamic auth,
    dynamic profile,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 8),
          child: Text('グループメンバー', style: TextStyle(color: Colors.black54)),
        ),
        Card(
          child: Column(
            children: [
              for (int i = 0; i < _members.length; i++) ...[
                ListTile(
                  leading: _members[i].id == _currentUserId
                      ? AvatarCircle(
                          avatarId: profile.avatarId,
                          imageUrl: auth.user?.avatarUrl,
                          radius: 18,
                        )
                      : const CircleAvatar(
                          radius: 18,
                          child: Icon(Icons.person_outline),
                        ),
                  title: Text(_members[i].name),
                  subtitle: _members[i].email.isNotEmpty
                      ? Text(_members[i].email)
                      : null,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _members[i].role == 'owner' ? 'グループの所有者' : '普通メンバー',
                        style: const TextStyle(
                            fontSize: 12, color: Colors.black54),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.chevron_right),
                    ],
                  ),
                  onTap: () => _onTapMember(context, _members[i]),
                ),
                if (i != _members.length - 1) const Divider(height: 1),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAddMember(BuildContext context) {
    return Card(
      child: ListTile(
        title: const Text('メンバーを追加', style: TextStyle(color: Colors.blue)),
        onTap: () async {
          if (!_isOwner) {
            _toast(context, 'オーナーのみ追加できます');
            return;
          }

          // TODO: 这里用真实邀请码（后端返回 or 本地生成）
          final inviteCode = 'ABCD-1234';

          final r = await showAddMemberSheet(
            context,
            inviteCode: inviteCode, // ✅ 必须传
          );
          if (r == null) return;

          switch (r.channel) {
            case 'account':
              if (!context.mounted) return;
              context.push('/settings/groups/join');
              return;

            case 'copy':
              // 已在 sheet 里复制并提示，这里不需要再做
              return;

            case 'sms':
              // TODO: 后续用 url_launcher 打开系统短信并带上 inviteCode
              _toast(context, 'SMSで招待（未実装）');
              return;

            case 'email':
              // TODO: 后续用 url_launcher 打开系统邮件并带上 inviteCode
              _toast(context, 'メールで招待（未実装）');
              return;

            default:
              return;
          }
        },
      ),
    );
  }

  Widget _buildCreateGroup(BuildContext context) {
    return Card(
      child: ListTile(
        title: const Center(
          child: Text('グループを作成', style: TextStyle(color: Colors.blue)),
        ),
        onTap: () async {
          if ((_familyName ?? '').isEmpty) {
            _toast(context, 'グループ名を入力してください');
            return;
          }

          // TODO: 调用 GroupStore / API 创建
          // final groupId = uuid.v4();
          // await groupStore.createGroup(...)

          _toast(context, 'グループを作成しました（仮）');
          Navigator.pop(context); // 或 push 到详情
        },
      ),
    );
  }

  Widget _buildDeleteGroup(BuildContext context) {
    return Card(
      child: ListTile(
        title: const Center(
          child: Text('グループの削除', style: TextStyle(color: Colors.red)),
        ),
        onTap: () async {
          if (!_isOwner) {
            _toast(context, 'オーナーのみ削除できます');
            return;
          }

          final ok = await showDialog<bool>(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('グループの削除'),
              content: const Text('本当に削除しますか？'),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(ctx, false),
                    child: const Text('キャンセル')),
                FilledButton(
                    onPressed: () => Navigator.pop(ctx, true),
                    child: const Text('削除')),
              ],
            ),
          );

          if (ok == true) {
            _toast(context, '削除API未接続');
          }
        },
      ),
    );
  }

  /// =============================
  /// Member Actions
  /// =============================

  void _onTapMember(BuildContext context, GroupMember target) async {
    final action = await _showMemberActionSheet(context, target);
    if (action == null) return;

    switch (action) {
      case 'remove':
        _removeMember(context, target);
        break;
      case 'transfer_owner':
        _transferOwner(context, target);
        break;
    }
  }

  Future<String?> _showMemberActionSheet(
      BuildContext context, GroupMember target) async {
    final isMe = target.id == _currentUserId;

    // 非 owner：不能操作
    if (!_isOwner) {
      return showModalBottomSheet<String>(
        context: context,
        showDragHandle: true,
        builder: (_) => SafeArea(
          child: ListTile(
            title: Text(target.name),
            subtitle: const Text('権限がありません'),
          ),
        ),
      );
    }

    return showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(title: Text(target.name)),
            const Divider(height: 1),
            if (!isMe && target.role == 'member')
              ListTile(
                leading: const Icon(Icons.swap_horiz),
                title: const Text('オーナーに移管'),
                onTap: () => Navigator.pop(context, 'transfer_owner'),
              ),
            if (!isMe && target.role == 'member')
              ListTile(
                leading: const Icon(Icons.delete_outline),
                title:
                    const Text('メンバーを削除', style: TextStyle(color: Colors.red)),
                onTap: () => Navigator.pop(context, 'remove'),
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _removeMember(BuildContext context, GroupMember target) {
    setState(() {
      _members.removeWhere((m) => m.id == target.id);
    });
    _toast(context, '削除しました（仮）');
  }

  void _transferOwner(BuildContext context, GroupMember target) {
    setState(() {
      _members = _members.map((m) {
        if (m.id == target.id) {
          return m.copyWith(role: 'owner');
        }
        if (m.id == _currentUserId) {
          return m.copyWith(role: 'member');
        }
        return m;
      }).toList();
    });
    _toast(context, 'オーナーを移管しました（仮）');
  }

  /// =============================
  /// Utils
  /// =============================

  Future<String?> _showEditTextDialog(
    BuildContext context, {
    required String title,
    required String initialValue,
  }) async {
    final c = TextEditingController(text: initialValue);
    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: c,
          style: const TextStyle(
            color: Colors.black87,
          ),
          decoration: const InputDecoration(border: OutlineInputBorder()),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('キャンセル')),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, c.text),
              child: const Text('保存')),
        ],
      ),
    );
  }

  void _toast(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }
}
