enum AppEnv { dev, prod }

class AppConfig {
  // 👉 当前环境（以后只改这一行）
  static const AppEnv env = AppEnv.dev;

  static const String _devBaseUrl = 'http://192.168.1.199:8000';
  static const String _prodBaseUrl = 'https://api.lifebox.app';

  static String get baseUrl {
    switch (env) {
      case AppEnv.prod:
        return _prodBaseUrl;
      case AppEnv.dev:
      default:
        return _devBaseUrl;
    }
  }

  // ===== API endpoints =====
  static String get aiAnalyze => '$baseUrl/api/ai/analyze';
  static String get cloudSaveRecord => '$baseUrl/api/cloud/records';

  static String get authGoogle => '$baseUrl/api/auth/google';
  static String get authRegister => '$baseUrl/api/auth/register';
  static String get authLogin => '$baseUrl/api/auth/login';
  static String get authMe => '$baseUrl/api/auth/me';
  static String get authLogout => '$baseUrl/api/auth/logout';
}
