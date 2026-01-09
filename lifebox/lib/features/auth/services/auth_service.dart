import '../domain/app_user.dart';

class AuthService {
  AppUser? _current;

  AppUser? get currentUser => _current;

  Future<AppUser> registerWithEmail(String email, String password) async {
    // TODO: 接后端 / Firebase
    await Future.delayed(const Duration(milliseconds: 300));
    _current = AppUser(uid: 'u_${DateTime.now().millisecondsSinceEpoch}', email: email, displayName: email.split('@').first);
    return _current!;
  }

  Future<AppUser> signInWithEmail(String email, String password) async {
    // TODO: 校验密码、返回 token 等
    await Future.delayed(const Duration(milliseconds: 250));
    _current = AppUser(uid: 'u_demo', email: email, displayName: email.split('@').first);
    return _current!;
  }

  Future<AppUser> signInWithGoogle() async {
    // TODO: 接 Google Sign-In / Firebase Auth
    await Future.delayed(const Duration(milliseconds: 300));
    _current = AppUser(uid: 'u_google', email: 'google_user@example.com', displayName: 'GoogleUser');
    return _current!;
  }

  Future<void> signOut() async {
    await Future.delayed(const Duration(milliseconds: 100));
    _current = null;
  }
}
