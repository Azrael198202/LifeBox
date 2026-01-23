import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lifebox/core/services/group_service.dart';

import '../../auth/state/auth_providers.dart';
import '../data/group_store.dart';

/// Provider: GroupStore（你已有 group_store.dart）
final groupStoreProvider = Provider<GroupStore>((ref) => GroupStore());

/// Provider: GroupService（只依赖 token）
final groupServiceProvider = Provider<GroupService>((ref) {
  return GroupService(
    getAccessToken: () async => ref.read(authControllerProvider).accessToken,
  );
});

class GroupState {
  final bool loading;
  final String? error;
  final List<GroupOutDto> groups;
  final String? activeGroupId;
  final Map<String, GroupDetailDto> details;

  const GroupState({
    this.loading = false,
    this.error,
    this.groups = const [],
    this.activeGroupId,
    this.details = const {},
  });

  GroupState copyWith({
    bool? loading,
    String? error,
    bool clearError = false,
    List<GroupOutDto>? groups,
    String? activeGroupId,
    Map<String, GroupDetailDto>? details,
  }) {
    return GroupState(
      loading: loading ?? this.loading,
      error: clearError ? null : (error ?? this.error),
      groups: groups ?? this.groups,
      activeGroupId: activeGroupId ?? this.activeGroupId,
      details: details ?? this.details,
    );
  }
}

class GroupController extends StateNotifier<GroupState> {
  GroupController(this.ref) : super(const GroupState()) {
    _loadActiveGroupId();
  }

  final Ref ref;

  Future<void> _loadActiveGroupId() async {
    final store = ref.read(groupStoreProvider);
    final id = await store.getActiveGroupId();
    state = state.copyWith(activeGroupId: id);
  }

  Future<void> setActiveGroup(String groupId) async {
    final store = ref.read(groupStoreProvider);
    await store.setActiveGroupId(groupId);
    state = state.copyWith(activeGroupId: groupId);
  }

  Future<void> refreshGroups() async {
    state = state.copyWith(loading: true, clearError: true);
    try {
      final svc = ref.read(groupServiceProvider);
      final list = await svc.listGroups();
      state = state.copyWith(loading: false, groups: list);

      if ((state.activeGroupId ?? '').isEmpty && list.isNotEmpty) {
        await setActiveGroup(list.first.id);
      }
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
    }
  }

  Future<GroupOutDto?> createGroup({
    required String name,
    String groupType = 'family',
  }) async {
    state = state.copyWith(loading: true, clearError: true);
    try {
      final svc = ref.read(groupServiceProvider);
      final g = await svc.createGroup(name: name, groupType: groupType);

      final newList = [g, ...state.groups.where((x) => x.id != g.id)];
      state = state.copyWith(loading: false, groups: newList);
      await setActiveGroup(g.id);
      return g;
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
      return null;
    }
  }

  Future<GroupDetailDto?> loadDetail(String groupId, {bool force = false}) async {
    if (!force && state.details.containsKey(groupId)) {
      return state.details[groupId];
    }

    state = state.copyWith(loading: true, clearError: true);
    try {
      final svc = ref.read(groupServiceProvider);
      final d = await svc.getGroupDetail(groupId);

      final next = Map<String, GroupDetailDto>.from(state.details);
      next[groupId] = d;
      state = state.copyWith(loading: false, details: next);
      return d;
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
      return null;
    }
  }

  Future<CreateInviteRespDto?> createInvite({
    required String groupId,
    String inviteeEmail = '',
    int expiresHours = 24,
  }) async {
    state = state.copyWith(loading: true, clearError: true);
    try {
      final svc = ref.read(groupServiceProvider);
      final r = await svc.createInvite(
        groupId: groupId,
        inviteeEmail: inviteeEmail,
        expiresHours: expiresHours,
      );
      state = state.copyWith(loading: false);
      return r;
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
      return null;
    }
  }

  Future<AcceptInviteRespDto?> acceptInvite({required String token}) async {
    state = state.copyWith(loading: true, clearError: true);
    try {
      final svc = ref.read(groupServiceProvider);
      final r = await svc.acceptInvite(token: token);

      await refreshGroups();
      state = state.copyWith(loading: false);
      return r;
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
      return null;
    }
  }
}

final groupControllerProvider =
    StateNotifierProvider<GroupController, GroupState>(
  (ref) => GroupController(ref),
);
