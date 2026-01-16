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

  @override
  String get calendarTitle => '日历';

  @override
  String get pickYearMonthTitle => '选择年月';

  @override
  String get yearLabel => '年';

  @override
  String get monthLabel => '月';

  @override
  String get cancel => 'キャンセル';

  @override
  String get confirm => '确定';

  @override
  String get speechSheetTitle => '语音识别内容';

  @override
  String get speechHintEditable => '识别结果会显示在这里，可编辑';

  @override
  String get goImport => '去导入';

  @override
  String receivedSnack(String text) {
    return '已收到：$text';
  }

  @override
  String get confirmAction => '确认';

  @override
  String get weekdaySun => '日';

  @override
  String get weekdayMon => '一';

  @override
  String get weekdayTue => '二';

  @override
  String get weekdayWed => '三';

  @override
  String get weekdayThu => '四';

  @override
  String get weekdayFri => '五';

  @override
  String get weekdaySat => '六';

  @override
  String dayItemsTitle(String date) {
    return '当天事项：$date';
  }

  @override
  String get noDueItemsForDay => '这一天没有设置截止日期的事项。';

  @override
  String get setDueHint => '提示：给事项设置截止日期后会显示在日历里。';

  @override
  String get noDueDate => '无截止';

  @override
  String duePrefix(String due) {
    return '截止：$due';
  }

  @override
  String get nextStep => '下一步';

  @override
  String get inboxDetailTitle => '详情';

  @override
  String inboxDetailSource(String source) {
    return '来源：$source';
  }

  @override
  String get inboxDetailThumbnailPlaceholder => '（这里未来放缩略图/来源图）';

  @override
  String get inboxDetailStructuredFields => '结构化字段';

  @override
  String get inboxDetailDueTodo => '截止日期：TODO';

  @override
  String get inboxDetailAmountTodo => '金额：TODO';

  @override
  String get inboxDetailPhoneUrlTodo => '电话/URL：TODO';

  @override
  String get inboxDetailPrimaryActionAddCalendar => '主动作：加入日历';

  @override
  String get inboxDetailMarkDoneTodo => '完成（TODO）';

  @override
  String get inboxDetailEvidenceTitle => '解析依据（OCR 片段）';

  @override
  String get inboxDetailOcrPlaceholder => 'OCR: ...（后续接入本地 OCR 缓存并展示）';

  @override
  String get inboxTitle => 'Life Inbox';

  @override
  String get inboxEmptyTitle => '这里还没有内容';

  @override
  String get inboxEmptySubtitle => '去导入截图或按住语音开始吧';

  @override
  String get tooltipCalendarView => '日历视图';

  @override
  String get tooltipImport => '导入';

  @override
  String get tooltipSettings => '设置';

  @override
  String tabHigh(int count) {
    return '高优先（$count）';
  }

  @override
  String tabPending(int count) {
    return '待处理（$count）';
  }

  @override
  String tabDone(int count) {
    return '已完成（$count）';
  }

  @override
  String get speechBarHintHoldToTalk => '按住语音，说完松开即可生成文字';

  @override
  String speechBarRecentPrefix(String text) {
    return '最近：$text';
  }

  @override
  String get lockPageTitle => '应用已锁定';

  @override
  String get lockPageNeedUnlock => '需要解锁后才能继续';

  @override
  String get unlock => '解锁';

  @override
  String unlockReturnTo(String target) {
    return '解锁后将返回：$target';
  }

  @override
  String get holdToTalkReleaseToStop => '松开结束';

  @override
  String get holdToTalkHoldToSpeak => '按住说话';

  @override
  String get holdToTalkUnavailable => '语音不可用';

  @override
  String get riskPrefix => '风险 ';

  @override
  String get riskHigh => '高';

  @override
  String get riskMid => '中';

  @override
  String get riskLow => '低';

  @override
  String get importTypeAll => '全部';

  @override
  String get importTypeScreenshots => '截图';

  @override
  String get importTypePhotos => '相册照片';

  @override
  String actionPageTitle(String actionType) {
    return '动作：$actionType';
  }

  @override
  String actionTypeLabel(String actionType) {
    return '动作类型：$actionType';
  }

  @override
  String actionItemIdLabel(String itemId) {
    return '事项ID：$itemId';
  }

  @override
  String get actionTodoDynamicRender => 'TODO：这里按 actionType 动态渲染';

  @override
  String get actionConfirmTodo => '确认（TODO：调用原生日历/复制模板/外链跳转）';
}
