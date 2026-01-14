// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get settings_title => '设置';

  @override
  String get language_title => '语言';

  @override
  String get language_subtitle => '切换显示语言';

  @override
  String get upload_policy_title => '仅上传 OCR 文本（默认开）';

  @override
  String get upload_policy_subtitle => '隐私友好：默认不上传原图（后续可配置）';

  @override
  String get app_lock_title => '启用应用锁（推荐）';

  @override
  String get app_lock_subtitle => '从后台回来需解锁（后续支持面部/指纹/系统认证）';

  @override
  String get cache_title => '本地缓存';

  @override
  String get cache_subtitle => '保留 7/30/永久（TODO）';

  @override
  String get clear_data_title => '清除数据';

  @override
  String get clear_data_subtitle => '本地清除 / 云端清除（接口预留）';

  @override
  String get clear_QA => '确认清除？';

  @override
  String get clear_content => '这将清除本地缓存数据（示例占位）。';

  @override
  String get clear_OK => '清除';

  @override
  String get logout_title => '退出登录';

  @override
  String get logout_QA => '确定要退出当前账号吗？';

  @override
  String get logout_OK => '退出登录';

  @override
  String get not_logged_in => '未登录';

  @override
  String get common_Cancel => '取消';

  @override
  String get version_text => 'Life Inbox • v0.1.0 (MVP)';

  @override
  String get app_name => 'Life Inbox';

  @override
  String get terms_agree_prefix => '继续即表示同意';

  @override
  String get open_terms_action => 'TODO：打开服务条款';

  @override
  String get terms_title => '服务条款';

  @override
  String get terms_and => ' 与 ';

  @override
  String get open_privacy_action => 'TODO：打开隐私政策';

  @override
  String get privacy_title => '隐私政策';

  @override
  String get common_mail => '邮箱';

  @override
  String get common_mail_hit => 'example@email.com';

  @override
  String get common_password => '密码';

  @override
  String get common_or => '或';

  @override
  String get common_password_hit => '请输入密码';

  @override
  String get login_title => '欢迎回来';

  @override
  String get login_subtitle => '登录后开始导入截图，自动识别待办与风险，并用应用锁保护隐私。';

  @override
  String get login_logining => '登录中...';

  @override
  String get login_with_mail => '邮箱登录';

  @override
  String get login_with_google => '使用 Google 登录（占位）';

  @override
  String get login_to_register => '没有账号？去注册';

  @override
  String get login_hit => '提示：登录后可在设置中开启应用锁（面容 / 指纹 / 系统认证）。';

  @override
  String get register_title => '创建账号';

  @override
  String get register_subtitle => '用邮箱注册，后续可绑定 Google/Apple，并开启应用锁增强安全。';

  @override
  String get register_password_hint => '至少 8 位';

  @override
  String get register_password_confirm_label => '确认密码';

  @override
  String get register_password_confirm_hint => '再次输入密码';

  @override
  String get register_password_mismatch => '两次密码不一致';

  @override
  String get register_button_loading => '注册中...';

  @override
  String get register_button_email => '邮箱注册';

  @override
  String get register_back_to_login => '返回登录';

  @override
  String get register_hint_success => '注册成功后将自动进入收件箱。';

  @override
  String get register_error_email_invalid => '请输入正确的邮箱';

  @override
  String get register_error_password_too_short => '密码至少 8 位';
}
