import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/app_user.dart';
import '../../../core/services/auth_service.dart';

// ✅ 统一 API 异常 & 错误 Key
import '../../../core/network/api_exception.dart';

class AuthState {
  final AppUser? user;
  final List<GroupBrief> groups;
  final String? accessToken;

  final bool loading;

  // ✅ 改为 errorKey（不再存 message）
  final ApiErrorKey? errorKey;

  const AuthState({
    required this.user,
    this.groups = const [],
    this.accessToken,
    this.loading = false,
    this.errorKey,
  });

  bool get isAuthenticated => user != null && (accessToken?.isNotEmpty ?? false);

  AuthState copyWith({
    AppUser? user,
    List<GroupBrief>? groups,
    String? accessToken,
    bool? loading,
    ApiErrorKey? errorKey,
    bool clearError = false, // ✅ 方便清空 error
  }) {
    return AuthState(
      user: user ?? this.user,
      groups: groups ?? this.groups,
      accessToken: accessToken ?? this.accessToken,
      loading: loading ?? this.loading,
      errorKey: clearError ? null : (errorKey ?? this.errorKey),
    );
  }
}

/// 你可以之后从 Settings 里读取 baseUrl
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

class AuthController extends StateNotifier<AuthState> {
  AuthController(this._svc) : super(const AuthState(user: null));

  final AuthService _svc;

  /// 给 GoRouter 用的刷新流
  final _stream = StreamController<AuthState>.broadcast();
  @override
  Stream<AuthState> get stream => _stream.stream;

  void _emit(AuthState s) {
    state = s;
    _stream.add(s);
  }

  /// ✅ UI 输入时调用，清掉错误提示
  void clearError() => _emit(state.copyWith(clearError: true));

  ApiErrorKey _mapError(Object e) {
    if (e is ApiException) return e.errorKey;
    return ApiErrorKey.unknown;
  }

  /// App 启动时可调用：尝试用 token 拉 /me
  Future<void> bootstrap() async {
    // TODO: 从 secure storage / shared prefs 恢复 token，然后 _svc.me()
  }

  Future<void> loginWithGoogle() async {
    _emit(state.copyWith(loading: true, clearError: true));
    try {
      final session = await _svc.signInWithGoogle();
      _emit(AuthState(
        user: session.user,
        groups: session.groups,
        accessToken: session.accessToken,
        loading: false,
      ));
    } catch (e) {
      _emit(AuthState(
        user: null,
        loading: false,
        errorKey: _mapError(e),
      ));
    }
  }

  Future<void> refreshMe() async {
    _emit(state.copyWith(loading: true, clearError: true));
    try {
      final session = await _svc.me();
      _emit(AuthState(
        user: session.user,
        groups: session.groups,
        accessToken: session.accessToken,
        loading: false,
      ));
    } catch (e) {
      _emit(state.copyWith(
        loading: false,
        errorKey: _mapError(e),
      ));
    }
  }

  Future<void> registerWithEmail(String email, String password) async {
    _emit(state.copyWith(loading: true, clearError: true));
    try {
      final session = await _svc.registerWithEmail(
        email: email,
        password: password,
      );
      _emit(AuthState(
        user: session.user,
        groups: session.groups,
        accessToken: session.accessToken,
        loading: false,
      ));
    } catch (e) {
      _emit(AuthState(
        user: null,
        loading: false,
        errorKey: _mapError(e),
      ));
    }
  }

  Future<void> loginWithEmail(String email, String password) async {
    _emit(state.copyWith(loading: true, clearError: true));
    try {
      final session = await _svc.loginWithEmail(
        email: email,
        password: password,
      );
      _emit(AuthState(
        user: session.user,
        groups: session.groups,
        accessToken: session.accessToken,
        loading: false,
      ));
    } catch (e) {
      _emit(AuthState(
        user: null,
        loading: false,
        errorKey: _mapError(e),
      ));
    }
  }

  Future<void> logout() async {
    _emit(state.copyWith(loading: true, clearError: true));
    await _svc.logout();
    _emit(const AuthState(user: null));
  }

  @override
  void dispose() {
    _stream.close();
    super.dispose();
  }
}

final authControllerProvider = StateNotifierProvider<AuthController, AuthState>(
  (ref) => AuthController(ref.read(authServiceProvider)),
);
