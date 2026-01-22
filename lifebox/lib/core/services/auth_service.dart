import 'dart:convert';
import 'dart:io';

import 'package:google_sign_in/google_sign_in.dart';
import 'package:lifebox/core/network/app_config.dart';

import '../../features/auth/domain/app_user.dart';
import '../network/api_exception.dart';

class AuthService {
  AuthService();

  String? _accessToken;
  AuthSession? _session;

  String? get accessToken => _accessToken;
  AuthSession? get session => _session;

  final _googleSignIn = GoogleSignIn(
    scopes: <String>[
      'email',
      'profile',
      'openid',
    ],
  );

  /// ---------- Public APIs ----------

  /// ✅ Google 登录（后端会自动“注册/创建用户+family group”，所以前台不区分登录/注册）
  Future<AuthSession> signInWithGoogle() async {
    final account = await _googleSignIn.signIn();
    if (account == null) {
      throw ApiException(
        statusCode: 0,
        errorKey: ApiErrorKey.unknown,
        raw: 'Google sign-in cancelled',
      );
    }

    final auth = await account.authentication;
    final idToken = auth.idToken;
    if (idToken == null || idToken.isEmpty) {
      throw ApiException(
        statusCode: 0,
        errorKey: ApiErrorKey.unknown,
        raw: 'Google id_token not available',
      );
    }

    final resp = await _postJsonUri(
      Uri.parse(AppConfig.authGoogle),
      {'id_token': idToken},
      bearer: null,
    );

    final session = AuthSession.fromJson(resp);
    _session = session;
    _accessToken = session.accessToken;
    return session;
  }

  Future<AuthSession> registerWithEmail({
    required String email,
    required String password,
  }) async {
    final resp = await _postJsonUri(
      Uri.parse(AppConfig.authRegister),
      {
        'email': email,
        'password': password,
      },
      bearer: null,
    );

    final session = AuthSession.fromJson(resp);
    _session = session;
    _accessToken = session.accessToken;
    return session;
  }

  Future<AuthSession> loginWithEmail({
    required String email,
    required String password,
  }) async {
    final resp = await _postJsonUri(
      Uri.parse(AppConfig.authLogin),
      {
        'email': email,
        'password': password,
      },
      bearer: null,
    );

    final session = AuthSession.fromJson(resp);
    _session = session;
    _accessToken = session.accessToken;
    return session;
  }

  /// ✅ 用已有 token 拉取当前用户（App 冷启动时可调用）
  Future<AuthSession> me() async {
    final token = _accessToken;
    if (token == null) {
      throw ApiException(
        statusCode: 0,
        errorKey: ApiErrorKey.unauthorized,
        raw: 'Not authenticated',
      );
    }

    final resp = await _getJsonUri(Uri.parse(AppConfig.authMe), bearer: token);
    final session = AuthSession.fromJson(resp);
    _session = session;
    _accessToken = session.accessToken; // 后端可能会刷新 token
    return session;
  }

  /// ✅ 登出（JWT 模式后端是 no-op，但我们要清掉本地 token）
  Future<void> logout() async {
    final token = _accessToken;
    try {
      if (token != null) {
        await _postJsonUri(Uri.parse(AppConfig.authLogout), const {}, bearer: token);
      }
    } catch (_) {
      // ignore network errors on logout
    } finally {
      _accessToken = null;
      _session = null;
      try {
        await _googleSignIn.signOut();
      } catch (_) {}
    }
  }

  /// ---------- Internal HTTP helpers ----------
  Future<Map<String, dynamic>> _getJsonUri(
    Uri uri, {
    required String bearer,
  }) async {
    final client = HttpClient();
    try {
      final req = await client.getUrl(uri);
      req.headers.set(HttpHeaders.acceptHeader, 'application/json');
      req.headers.set(HttpHeaders.authorizationHeader, 'Bearer $bearer');

      final res = await req.close();
      final body = await res.transform(utf8.decoder).join();

      if (res.statusCode < 200 || res.statusCode >= 300) {
        throw ApiException.fromHttp(
          statusCode: res.statusCode,
          body: body,
        );
      }
      return jsonDecode(body) as Map<String, dynamic>;
    } finally {
      client.close(force: true);
    }
  }

  Future<Map<String, dynamic>> _postJsonUri(
    Uri uri,
    Map<String, dynamic> payload, {
    String? bearer,
  }) async {
    final client = HttpClient();
    try {
      final req = await client.postUrl(uri);
      req.headers.set(HttpHeaders.contentTypeHeader, 'application/json');
      req.headers.set(HttpHeaders.acceptHeader, 'application/json');
      if (bearer != null) {
        req.headers.set(HttpHeaders.authorizationHeader, 'Bearer $bearer');
      }

      req.add(utf8.encode(jsonEncode(payload)));

      final res = await req.close();
      final body = await res.transform(utf8.decoder).join();

      if (res.statusCode < 200 || res.statusCode >= 300) {
        throw ApiException.fromHttp(
          statusCode: res.statusCode,
          body: body,
        );
      }
      return jsonDecode(body) as Map<String, dynamic>;
    } finally {
      client.close(force: true);
    }
  }
}
