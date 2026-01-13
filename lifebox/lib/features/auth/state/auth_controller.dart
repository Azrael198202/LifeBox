import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// =======================
/// Domain
/// =======================

class AppUser {
  final String uid;
  final String email;
  final String displayName;

  AppUser({
    required this.uid,
    required this.email,
    required this.displayName,
  });
}

/// =======================
/// State
/// =======================

class AuthState {
  final AppUser? user;
  final bool loading;
  final String? error;

  const AuthState({
    required this.user,
    this.loading = false,
    this.error,
  });

  bool get isAuthenticated => user != null;

  AuthState copyWith({
    AppUser? user,
    bool? loading,
    String? error,
  }) {
    return AuthState(
      user: user ?? this.user,
      loading: loading ?? this.loading,
      error: error,
    );
  }
}

/// =======================
/// Controller
/// =======================

class AuthController extends StateNotifier<AuthState> {
  AuthController() : super(const AuthState(user: null));

  /// 🔑 给 GoRouter 用的刷新流
  final _stream = StreamController<AuthState>.broadcast();
  @override
  Stream<AuthState> get stream => _stream.stream;

  void _emit(AuthState s) {
    state = s;
    _stream.add(s);
  }

  /// =======================
  /// Email / Password
  /// =======================

  Future<void> register(String email, String password) async {
    _emit(state.copyWith(loading: true, error: null));
    try {
      await Future.delayed(const Duration(milliseconds: 400));
      final user = AppUser(
        uid: 'u_${DateTime.now().millisecondsSinceEpoch}',
        email: email,
        displayName: email.split('@').first,
      );
      _emit(AuthState(user: user, loading: false));
    } catch (e) {
      _emit(AuthState(user: null, loading: false, error: e.toString()));
    }
  }

  Future<void> login(String email, String password) async {
    _emit(state.copyWith(loading: true, error: null));
    try {
      await Future.delayed(const Duration(milliseconds: 300));
      final user = AppUser(
        uid: 'u_demo',
        email: email,
        displayName: email.split('@').first,
      );
      _emit(AuthState(user: user, loading: false));
    } catch (e) {
      _emit(AuthState(user: null, loading: false, error: e.toString()));
    }
  }

  /// =======================
  /// Third-party (Google placeholder)
  /// =======================

  Future<void> loginWithGoogle() async {
    _emit(state.copyWith(loading: true, error: null));
    try {
      await Future.delayed(const Duration(milliseconds: 350));
      final user = AppUser(
        uid: 'u_google',
        email: 'google_user@example.com',
        displayName: 'GoogleUser',
      );
      _emit(AuthState(user: user, loading: false));
    } catch (e) {
      _emit(AuthState(user: null, loading: false, error: e.toString()));
    }
  }

  /// =======================
  /// Logout
  /// =======================

  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 150));
    _emit(const AuthState(user: null));
  }

  @override
  void dispose() {
    _stream.close();
    super.dispose();
  }
}

/// =======================
/// Provider
/// =======================

final authControllerProvider =
    StateNotifierProvider<AuthController, AuthState>(
  (ref) => AuthController(),
);
