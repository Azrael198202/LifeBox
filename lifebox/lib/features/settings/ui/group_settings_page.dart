import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lifebox/core/utils/invite_share_utils.dart';
import 'package:lifebox/features/auth/domain/app_user.dart';
import 'package:lifebox/features/settings/data/group_store.dart';
import 'package:go_router/go_router.dart';
import 'package:lifebox/l10n/app_localizations.dart';

import 'package:flutter/services.dart'; // Clipboard
import 'package:url_launcher/url_launcher.dart'; // mailto/sms
import 'package:share_plus/share_plus.dart'; // fallback share sheet

import '../../../core/widgets/app_scaffold.dart';
import '../../auth/state/auth_providers.dart';
import '../state/settings_providers.dart';
import '../state/group_provider.dart';
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
  late List<GroupMember> _members;
  String? _familyName;

  bool get _isCreateMode => widget.groupId == null;

  @override
  void initState() {
    super.initState();
    _members = [];

    // ✅ 编辑模式：进来就拉 detail
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      if (!_isCreateMode && widget.groupId != null) {
        await ref
            .read(groupControllerProvider.notifier)
            .loadDetail(widget.groupId!, force: true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authControllerProvider);
    final profile = ref.watch(userProfileProvider);
    final l10n = AppLocalizations.of(context);

    final groupState = ref.watch(groupControllerProvider);

    final currentUserId = auth.user?.id ?? '';

    GroupBrief? group;
    if (_isCreateMode) {
      group = null;
    } else {
      group = auth.groups
          .where((g) => g.id == widget.groupId)
          .cast<GroupBrief?>()
          .firstOrNull;
    }

    // ✅ viewerRole：create=owner；edit=auth.me.groups 内的 role（若无则 member）
    final viewerRole = _isCreateMode ? 'owner' : (group?.role ?? 'member');
    final isOwner = viewerRole == 'owner';

    // ✅ members：create=自己；edit=后端 detail.members
    if (_isCreateMode) {
      if (_members.isEmpty) {
        _members = [
          GroupMember(
            id: currentUserId.isEmpty ? 'me' : currentUserId,
            name: profile.nickname.isNotEmpty
                ? profile.nickname
                : (auth.user?.displayName ?? '---'),
            email: auth.user?.email ?? '',
            role: 'owner',
          ),
        ];
      }
    } else {
      final gid = widget.groupId!;
      final detail = groupState.details[gid];

      // detail 还没回来时：显示 loading，但保留 UI 结构
      if (detail == null) {
        // 不要清空 _members，避免 build 抖动；如果第一次进来为空，就先给一条自己占位
        if (_members.isEmpty) {
          _members = [
            GroupMember(
              id: currentUserId.isEmpty ? 'me' : currentUserId,
              name: profile.nickname.isNotEmpty
                  ? profile.nickname
                  : (auth.user?.displayName ?? '---'),
              email: auth.user?.email ?? '',
              role: viewerRole, // 先用 me 的 role
            ),
          ];
        }
      } else {
        // ✅ 用后端 members 重建
        _members = detail.members.map((m) {
          final uid = m.userId;

          final isMe = uid == currentUserId;
          if (isMe) {
            return GroupMember(
              id: uid,
              name: profile.nickname.isNotEmpty
                  ? profile.nickname
                  : (auth.user?.displayName ?? '---'),
              email: auth.user?.email ?? '',
              role: m.role,
            );
          }

          // 其他人：后端暂时没有 name/email，只能用占位
          final shortId = uid.length > 8 ? uid.substring(0, 8) : uid;
          return GroupMember(
            id: uid,
            name: 'Member $shortId',
            email: '',
            role: m.role,
          );
        }).toList();
      }
    }

    // ✅ 组名显示：优先 _familyName（编辑后本地更新），否则来自 auth.groups
    final shownGroupName =
        _familyName ?? (_isCreateMode ? '' : (group?.name ?? '---'));

    return AppScaffold(
      title: _isCreateMode ? l10n.groupCreateTitle : l10n.groupSettingsTitle,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 顶部 loading / error 提示（可选但很实用）
          if (groupState.loading)
            const Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: LinearProgressIndicator(minHeight: 2),
            ),
          if ((groupState.error ?? '').isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                groupState.error!,
                style: const TextStyle(color: Colors.red),
              ),
            ),

          _buildFamilyInfoCard(context, shownGroupName, isOwner),
          const SizedBox(height: 12),
          _buildMembersSection(context, auth, profile, currentUserId),
          const SizedBox(height: 12),
          _buildAddMember(context, isOwner),
          const SizedBox(height: 16),
          _isCreateMode
              ? _buildCreateGroup(context)
              : _buildDeleteGroup(context, isOwner),
        ],
      ),
    );
  }

  /// =============================
  /// UI Blocks
  /// =============================

  Widget _buildFamilyInfoCard(
    BuildContext context,
    String shownGroupName,
    bool isOwner,
  ) {
    final l10n = AppLocalizations.of(context);

    return Card(
      child: Column(
        children: [
          ListTile(
            title: Text(l10n.groupName),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  shownGroupName,
                  style: const TextStyle(color: Colors.black54),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.chevron_right),
              ],
            ),
            onTap: () async {
              if (!isOwner) {
                _toast(context, l10n.ownerOnlyCanChange);
                return;
              }

              final name = await _showEditTextDialog(
                context,
                title: _isCreateMode
                    ? l10n.groupNameInputTitleCreate
                    : l10n.groupNameInputTitleEdit,
                initialValue: shownGroupName,
              );
              if (name == null || name.trim().isEmpty) return;

              setState(() => _familyName = name.trim());

              if (!_isCreateMode && widget.groupId != null) {
                // TODO: 后端有 PATCH /api/groups/{id} 后，在这里调用：
                // await ref.read(groupControllerProvider.notifier).renameGroup(widget.groupId!, name.trim());
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
    String currentUserId,
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
                  leading: _members[i].id == currentUserId
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
                        _members[i].role == 'owner'
                            ? 'グループの所有者'
                            : (_members[i].role == 'admin' ? '管理者' : '普通メンバー'),
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

  Widget _buildAddMember(BuildContext context, bool isOwner) {
    final l10n = AppLocalizations.of(context);

    return Card(
      child: ListTile(
        title: Text(l10n.addMember, style: const TextStyle(color: Colors.blue)),
        onTap: () async {
          if (!isOwner) {
            _toast(context, l10n.ownerOnlyCanAdd);
            return;
          }

          // ✅ 编辑模式：groupId 必须存在；创建模式：还没创建 group，不允许邀请
          if (_isCreateMode || widget.groupId == null) {
            _toast(context, l10n.groupCreateTitle); // 也可以换成更明确的文案
            return;
          }

          final gid = widget.groupId!;

          // ✅ 调用 API 生成真实 invite token
          final resp = await ref
              .read(groupControllerProvider.notifier)
              .createInvite(groupId: gid, expiresHours: 24);

          if (resp == null) {
            _toast(context, 'create invite failed');
            return;
          }

          final inviteCode = resp.token;

          final r = await showAddMemberSheet(
            context,
            inviteCode: inviteCode,
          );
          if (r == null) return;

          switch (r.channel) {
            case 'account':
              if (!context.mounted) return;
              context.push('/settings/groups/join');
              return;

            case 'copy':
              await copyInviteCode(context, inviteCode);
              return;

            case 'sms':
              {
                final text = buildInviteText(l10n, inviteCode);
                final ok = await launchInviteSms(text);

                if (!ok) {
                  await shareInviteFallback(text: text);
                }
                return;
              }

            case 'email':
              {
                final text = buildInviteText(l10n, inviteCode);
                final subject = l10n.groupInviteEmailSubject;

                final ok = await launchInviteEmail(
                  subject: subject,
                  body: text,
                );

                if (!ok) {
                  await shareInviteFallback(
                    text: text,
                    subject: subject,
                  );
                }
                return;
              }

            default:
              return;
          }
        },
      ),
    );
  }

  Widget _buildCreateGroup(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Card(
      child: ListTile(
        title: Center(
          child: Text(
            l10n.groupCreateTitle,
            style: const TextStyle(color: Colors.blue),
          ),
        ),
        onTap: () async {
          if ((_familyName ?? '').trim().isEmpty) {
            _toast(context, l10n.groupNameEmpty);
            return;
          }

          final g =
              await ref.read(groupControllerProvider.notifier).createGroup(
                    name: _familyName!.trim(),
                    groupType: 'family',
                  );

          if (g == null) {
            _toast(context, 'create group failed');
            return;
          }

          _toast(context, l10n.groupCreated);
          if (!context.mounted) return;
          Navigator.pop(context);
        },
      ),
    );
  }

  Widget _buildDeleteGroup(BuildContext context, bool isOwner) {
    final l10n = AppLocalizations.of(context);

    return Card(
      child: ListTile(
        title: Center(
          child: Text(
            l10n.deleteGroupTitle,
            style: const TextStyle(color: Colors.red),
          ),
        ),
        onTap: () async {
          if (!isOwner) {
            _toast(context, l10n.ownerOnlyCanDelete);
            return;
          }

          final ok = await showDialog<bool>(
            context: context,
            builder: (ctx) => AlertDialog(
              title: Text(l10n.deleteGroupTitle),
              content: Text(l10n.deleteConfirm),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: Text(l10n.cancel),
                ),
                FilledButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  child: Text(l10n.delete),
                ),
              ],
            ),
          );

          if (ok == true) {
            // TODO: 后端有 DELETE /api/groups/{id} 后，在这里调用
            _toast(context, l10n.deleteApiNotConnected);
          }
        },
      ),
    );
  }

  /// =============================
  /// Member Actions
  /// =============================

  void _onTapMember(BuildContext context, GroupMember target) async {
    final auth = ref.read(authControllerProvider);
    final currentUserId = auth.user?.id ?? '';

    final action = await _showMemberActionSheet(context, target, currentUserId);
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
    BuildContext context,
    GroupMember target,
    String currentUserId,
  ) async {
    final l10n = AppLocalizations.of(context);

    // ✅ owner 判断：优先用 auth.groups 的 role
    final auth = ref.read(authControllerProvider);
    final group = (!_isCreateMode && widget.groupId != null)
        ? auth.groups
            .where((g) => g.id == widget.groupId)
            .cast<GroupBrief?>()
            .firstOrNull
        : null;

    final isOwner = _isCreateMode ? true : (group?.role == 'owner');
    final isMe = target.id == currentUserId;

    if (!isOwner) {
      return showModalBottomSheet<String>(
        context: context,
        showDragHandle: true,
        builder: (_) => SafeArea(
          child: ListTile(
            title: Text(target.name),
            subtitle: Text(l10n.noPermission),
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
                title: Text(l10n.memberTransferOwner),
                onTap: () => Navigator.pop(context, 'transfer_owner'),
              ),
            if (!isMe && target.role == 'member')
              ListTile(
                leading: const Icon(Icons.delete_outline),
                title: Text(
                  l10n.memberRemove,
                  style: const TextStyle(color: Colors.red),
                ),
                onTap: () => Navigator.pop(context, 'remove'),
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _removeMember(BuildContext context, GroupMember target) {
    final l10n = AppLocalizations.of(context);

    // TODO: 后端有 remove member API 后，在这里调用 provider
    setState(() {
      _members.removeWhere((m) => m.id == target.id);
    });
    _toast(context, l10n.memberRemoved);
  }

  void _transferOwner(BuildContext context, GroupMember target) {
    final l10n = AppLocalizations.of(context);

    // TODO: 后端有 transfer owner API 后，在这里调用 provider
    final auth = ref.read(authControllerProvider);
    final currentUserId = auth.user?.id ?? '';

    setState(() {
      _members = _members.map((m) {
        if (m.id == target.id) return m.copyWith(role: 'owner');
        if (m.id == currentUserId) return m.copyWith(role: 'member');
        return m;
      }).toList();
    });
    _toast(context, l10n.ownerTransferred);
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
    final l10n = AppLocalizations.of(context);

    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: c,
          style: const TextStyle(color: Colors.black87),
          decoration: const InputDecoration(border: OutlineInputBorder()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, c.text),
            child: Text(l10n.save),
          ),
        ],
      ),
    );
  }

  void _toast(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }
}
