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
  String get language_jp => '日文';

  @override
  String get language_zh => '中文';

  @override
  String get language_en => '英文';

  @override
  String get clear => '清除';

  @override
  String get delete => '删除';

  @override
  String get cancel => '取消';

  @override
  String get save => '保存';

  @override
  String get finish => '完成';

  @override
  String get select => '选择';

  @override
  String get colorBlueGrey => '蓝灰色';

  @override
  String get colorBlue => '蓝色';

  @override
  String get colorGreen => '绿色';

  @override
  String get colorOrange => '橙色';

  @override
  String get colorPink => '粉色';

  @override
  String get colorPurple => '紫色';

  @override
  String get colorRed => '红色';

  @override
  String get colorGeneric => '颜色';

  @override
  String get colorTitle => '颜色（日历）';

  @override
  String get deleteConfirm => '确定要删除吗？';

  @override
  String get deleteConfirmTitle => '确定删除';

  @override
  String get continueText => '继续';

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
  String get logout_title => '退出登录';

  @override
  String get logout_QA => '确定要退出当前账号吗？';

  @override
  String get logout_OK => '退出登录';

  @override
  String get not_logged_in => '未登录';

  @override
  String no_name(Object name) {
    return '用户 $name';
  }

  @override
  String get no_title => '(无标题)\' ';

  @override
  String get another => '其他 ';

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
  String get login_continue_google => 'Continue with Google';

  @override
  String get login_no_account => '没有账号？';

  @override
  String get login_to_register => '去注册';

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
  String get refresh => '刷新';

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
  String get loading_more => '加载中…';

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
  String get analysis_confirm_title => '确认并保存';

  @override
  String get analysis_confirm_section_editable => '解析结果（可编辑）';

  @override
  String get analysis_confirm_field_title => '标题';

  @override
  String get analysis_confirm_field_summary => '内容/摘要';

  @override
  String get analysis_confirm_field_due => '期限 (YYYYMMDD)';

  @override
  String get analysis_confirm_field_risk => '风险';

  @override
  String get analysis_confirm_field_amount => '金额';

  @override
  String get analysis_confirm_field_currency => '币种 (JPY/CNY)';

  @override
  String get analysis_confirm_section_request => '模拟请求（参考）';

  @override
  String get analysis_confirm_saving => '保存中...';

  @override
  String get analysis_confirm_save => '确认无误，保存';

  @override
  String get analysis_confirm_invalid_date => '日期格式不正确，请使用 YYYY-MM-DD';

  @override
  String get analysis_confirm_untitled => '未命名';

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

  @override
  String error_loading(String error) {
    return '加载失败:$error';
  }

  @override
  String get setting_title => '设置';

  @override
  String get setting_not_logged_in => '未登录';

  @override
  String get setting_cloud_title => '云保存（收费）';

  @override
  String get setting_cloud_on => '云保存已开启（将同步到服务器）';

  @override
  String get setting_cloud_off => '云保存已关闭（仅本机保存）';

  @override
  String get setting_cloud_sub_success => '订阅成功，云保存已开启';

  @override
  String get setting_cloud_status_subscribed => '已订阅';

  @override
  String get setting_cloud_status_unsubscribed => '未订阅';

  @override
  String setting_cloud_desc_on(Object status) {
    return '已开启：确认保存时会调用云端 API（$status）';
  }

  @override
  String setting_cloud_desc_off(Object status) {
    return '默认关闭：数据仅保存在本机（$status）';
  }

  @override
  String get setting_debug_reset_sub => 'DEBUG: 重置订阅为未订阅';

  @override
  String get setting_debug_reset_done => '已重置为未订阅（DEBUG）';

  @override
  String get setting_privacy_saved_demo => '已保存（示例：后续接入持久化）';

  @override
  String get setting_cache_todo => 'TODO：缓存策略设置页';

  @override
  String get setting_clear_confirm_title => '确认清除？';

  @override
  String get setting_clear_confirm_desc => '这将清除本地缓存数据（示例占位）。';

  @override
  String get setting_clear_ok => '清除';

  @override
  String get setting_clear_done => '已清除（示例：后续接入真实清理逻辑）';

  @override
  String get setting_group => '组管理（收费）';

  @override
  String get input_valid_mail_must => '请输入邮箱。';

  @override
  String get input_valid_mail_format => '请输入正确的邮箱';

  @override
  String get input_valid_pwd_must => '请输入密码。';

  @override
  String get input_valid_comfirm_pwd => '请输入确认密码';

  @override
  String get register_with_mail => 'Eメールで登録';

  @override
  String get badRequest => '请求内容不正确';

  @override
  String get unauthorized => '邮箱或密码不正确';

  @override
  String get forbidden => '没有权限执行此操作';

  @override
  String get notFound => '未找到相关数据';

  @override
  String get conflict => '该邮箱已被注册';

  @override
  String get validationError => '请检查输入内容（如邮箱格式）';

  @override
  String get serverError => '服务器发生错误，请稍后再试';

  @override
  String get unknown => '发生未知错误';

  @override
  String get cloud_paywall_title => '云保存（收费）';

  @override
  String get cloud_paywall_desc => '开启云保存需要订阅 Pro（Mock）。';

  @override
  String get cloud_feature_backup => '保存到服务器数据库';

  @override
  String get cloud_feature_sync => '多设备同步（后续）';

  @override
  String get cloud_feature_offline => '本机仍可离线使用';

  @override
  String get cloud_price_monthly => '价格：¥300/月（Mock）';

  @override
  String get subscription_restore => '恢复购买';

  @override
  String get subscription_subscribe => '订阅并开启';

  @override
  String get paywallTitle => '高级版（付费）';

  @override
  String get paywallDesc => '使用群组管理、云端保存等功能\n需要开通高级版。';

  @override
  String get loadingText => '加载中...';

  @override
  String get planMonthly => '月度套餐';

  @override
  String get planYearly => '年度套餐';

  @override
  String get restorePurchase => '恢复购买（Restore）';

  @override
  String get cancelGuideTitle => '取消订阅请到 App Store / Google Play 的订阅管理';

  @override
  String get cancelGuideSubtitle => '应用内无法取消订阅';

  @override
  String get notNow => '暂不';

  @override
  String get personalInfoTitle => '个人信息';

  @override
  String get profileImage => '头像';

  @override
  String get nickname => '昵称';

  @override
  String get joinGroupTitle => '加入群组';

  @override
  String get joinGroupHelp => '请联系群组管理员发送邀请\n（群组设置 ＞ 添加成员）';

  @override
  String get joinGroupHint => '请输入邀请码';

  @override
  String get joinGroupCodeEmpty => '请输入邀请码';

  @override
  String get joinGroupJoined => '已加入';

  @override
  String get groupCreateTitle => '创建群组';

  @override
  String get groupName => '群组名';

  @override
  String get groupSettingsTitle => '群组设置';

  @override
  String get groupMembers => '群组成员';

  @override
  String get groupOwnerLabel => '群主';

  @override
  String get groupMemberLabel => '普通成员';

  @override
  String get ownerOnlyCanChange => '仅群主可修改';

  @override
  String get ownerOnlyCanAdd => '仅群主可添加成员';

  @override
  String get ownerOnlyCanDelete => '仅群主可删除';

  @override
  String get groupNameInputTitleCreate => '请输入群组名称';

  @override
  String get groupNameInputTitleEdit => '群组名称';

  @override
  String get groupNameEmpty => '请输入群组名称';

  @override
  String get groupCreated => '已创建群组';

  @override
  String get addMember => '添加成员';

  @override
  String get inviteSmsNotImplemented => '通过短信邀请（未实现）';

  @override
  String get inviteEmailNotImplemented => '通过邮件邀请（未实现）';

  @override
  String get deleteGroupTitle => '删除群组';

  @override
  String get noPermission => '没有权限';

  @override
  String get memberTransferOwner => '转让群主';

  @override
  String get memberRemove => '移除成员';

  @override
  String get memberRemoved => '已移除';

  @override
  String get ownerTransferred => '已转让群主';

  @override
  String get deleteApiNotConnected => '删除 API 未接入';

  @override
  String get swipeMarkDone => '标记完成';

  @override
  String get swipeRestore => '恢复待办';

  @override
  String get groupManage => '群组管理';

  @override
  String get nogroup => '还没有群组';

  @override
  String get joinGroup => '加入群组';

  @override
  String get inviteChooseMethodTitle => '选择邀请方式';

  @override
  String get inviteMethodAccount => '应用账号';

  @override
  String get inviteMethodSms => '短信';

  @override
  String get inviteMethodEmail => '电子邮件';

  @override
  String get inviteMethodCode => '邀请码';

  @override
  String get inviteCodeCopied => '已复制邀请码';

  @override
  String get account => '账号';

  @override
  String get inputAccount => '请输入账号邮箱';

  @override
  String get inputName => '请输入成员显示名';

  @override
  String get displayname => '显示名';

  @override
  String get speechSavedToLocalInbox => '已保存到本地 Inbox';

  @override
  String speechAnalyzeFailed(Object error) {
    return '语音解析失败：$error';
  }

  @override
  String get speechMockTitle => '模拟语音文本';

  @override
  String get speechMockCustomInputLabel => '自定义输入（优先）';

  @override
  String get speechMockUseInput => '使用输入';

  @override
  String get speechParsing => '解析中...';

  @override
  String get speechMockTooltip => '模拟语音文本';

  @override
  String get group_desc => '分组管理为付费功能（未订阅 / 尚未创建分组，因此固定为「个人」）';

  @override
  String get group => '群组';

  @override
  String get personal => '个人';

  @override
  String get holidayShort => '休';

  @override
  String get holidayLabel => '假期';

  @override
  String get holidaysLoading => '正在加载假期…';

  @override
  String get copied => '已复制';

  @override
  String get groupInviteMessage => '邀请你加入 LifeBox 群组。使用下面的邀请码即可加入。';

  @override
  String get inviteCodeLabel => '邀请码';

  @override
  String get groupInviteEmailSubject => '邀请你加入 LifeBox 群组';

  @override
  String get joinGroupFailed => '邀请码无效或已过期。';
}
