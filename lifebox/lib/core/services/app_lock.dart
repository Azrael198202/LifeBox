import 'package:flutter_riverpod/flutter_riverpod.dart';

class AppLockState {
  final bool enabled;
  final bool isLocked;

  const AppLockState({required this.enabled, required this.isLocked});

  AppLockState copyWith({bool? enabled, bool? isLocked}) =>
      AppLockState(enabled: enabled ?? this.enabled, isLocked: isLocked ?? this.isLocked);
}

class AppLockController extends StateNotifier<AppLockState> {
  AppLockController() : super(const AppLockState(enabled: true, isLocked: false));

  // App 回到前台时触发
  void onResume() {
    if (state.enabled) {
      state = state.copyWith(isLocked: true);
    }
  }

  void unlock() {
    state = state.copyWith(isLocked: false);
  }

  void setEnabled(bool v) {
    state = state.copyWith(enabled: v);
    if (!v) state = state.copyWith(isLocked: false);
  }
}

final appLockProvider = StateNotifierProvider<AppLockController, AppLockState>((ref) {
  return AppLockController();
});
