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

static String get legal => '$baseUrl/api/legal';

  // ===== API endpoints =====
  static String get aiAnalyze => '$baseUrl/api/ai/analyze';
  static String get cloudRecord => '$baseUrl/api/cloud/records/getall';
  static String get cloudSaveRecord => '$baseUrl/api/cloud/records';
  static String cloudRecordDelete(String id) => '$baseUrl/api/cloud/records/$id';
  static String get cloudRecords => '$baseUrl/api/records/all';
  static String cloudRecordDetail(String id) => '$baseUrl/api/cloud/records/$id';

  static String get authGoogle => '$baseUrl/api/auth/google';
  static String get authRegister => '$baseUrl/api/auth/register';
  static String get authLogin => '$baseUrl/api/auth/login';
  static String get authMe => '$baseUrl/api/auth/me';
  static String get authLogout => '$baseUrl/api/auth/logout';

  static String get billingSubscription => '$baseUrl/api/billing/subscription';
  static String get billingEntitlements => '$baseUrl/api/billing/entitlements';
  static String get billingVerify => '$baseUrl/api/billing/verify';

  // ===== Group endpoints =====
static String get groups => '$baseUrl/api/groups';
static String groupDetail(String groupId) => '$baseUrl/api/groups/$groupId';
static String groupInvites(String groupId) => '$baseUrl/api/groups/$groupId/invites';
static String get inviteAccept => '$baseUrl/api/invites/accept';

static String groupPatch(String groupId) => '$baseUrl/api/groups/$groupId';
static String groupDelete(String groupId) => '$baseUrl/api/groups/$groupId';
static String groupRemoveMember(String groupId, String userId) => '$baseUrl/api/groups/$groupId/members/$userId';
static String groupTransferOwner(String groupId) => '$baseUrl/api/groups/$groupId/transfer-owner';

}
