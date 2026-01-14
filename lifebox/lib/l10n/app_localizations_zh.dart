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
  String get type_label => '类型';

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

  @override
  String get all_Time => '不限时间';

  @override
  String get import_title => '导入';

  @override
  String get import_title_full => '导入（筛选 + 队列）';

  @override
  String get import_perm_title => '未获得相册权限';

  @override
  String get import_perm_subtitle_ios => '请到 iOS 设置 → 隐私与安全性 → 照片 中允许访问。';

  @override
  String get import_perm_retry => '重新请求权限';

  @override
  String get import_action_refresh => '刷新';

  @override
  String get import_range_unlimited => '不限时间';

  @override
  String get import_filter_range_label => '时间段';

  @override
  String get import_filter_clear_range => '清除时间';

  @override
  String get import_screenshots_not_found => '未检测到“截图相册”，截图筛选将自动降级为全部照片。';

  @override
  String import_screenshots_album_prefix(Object count) {
    return '截图相册： $count';
  }

  @override
  String import_selected_count(Object count) {
    return '已选 $count 张';
  }

  @override
  String get import_select_all_visible => '全选当前';

  @override
  String get import_clear_selection => '取消全选';

  @override
  String import_queue_label(Object count) {
    return '队列 $count';
  }

  @override
  String get import_empty_title => '没有符合条件的照片';

  @override
  String get import_empty_subtitle => '尝试更换时间范围或类型筛选。';

  @override
  String get import_loading_more => '加载中…';

  @override
  String get import_enqueue_button => '加入待处理队列';

  @override
  String import_enqueue_button_with_count(Object count) {
    return '加入待处理队列（$count）';
  }

  @override
  String get ocr_queue_title => 'OCR 队列';

  @override
  String get ocr_queue_clear => '清空排队';

  @override
  String ocr_results_button(Object count) {
    return '结果（$count）';
  }

  @override
  String ocr_processing_prefix(Object count) {
    return '处理中：$count';
  }

  @override
  String get ocr_no_current => '当前无处理中任务';

  @override
  String ocr_queued_prefix(Object count) {
    return '排队：';
  }

  @override
  String get ocr_queue_empty => '排队为空';

  @override
  String ocrResultsTitle(int count) {
    return 'OCR 结果（$count）';
  }

  @override
  String get selectAll => '全选';

  @override
  String get clearSelection => '清空';

  @override
  String get clearResultsTooltip => '清空结果';

  @override
  String get confirmButtonPleaseSelect => '请选择卡片';

  @override
  String confirmButtonSelectedCount(int count) {
    return '确定（$count）';
  }

  @override
  String get emptyOcrResults => '暂无 OCR 结果';

  @override
  String get ocrStatusSuccess => '成功';

  @override
  String get ocrStatusFailed => '失败';

  @override
  String get ocrStatusRunning => '处理中';

  @override
  String get ocrStatusQueued => '排队中';

  @override
  String get ocrFailedDefaultError => '识别失败';

  @override
  String get noTextPlaceholder => '（无文本）';

  @override
  String get ocrFullTextTitle => 'OCR 全文';

  @override
  String get close => '关闭';

  @override
  String get viewFullText => '查看全文';
}
