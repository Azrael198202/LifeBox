// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get settings_title => '設定';

  @override
  String get language_title => '言語';

  @override
  String get language_jp => '日本語';

  @override
  String get language_zh => '中国語';

  @override
  String get language_en => '英語';

  @override
  String get clear => 'クリア';

  @override
  String get delete => '削除';

  @override
  String get cancel => 'キャンセル';

  @override
  String get save => '保存';

  @override
  String get finish => '終了';

  @override
  String get select => '選択';

  @override
  String get colorBlueGrey => 'ブルーグレー';

  @override
  String get colorBlue => 'ブルー';

  @override
  String get colorGreen => 'グリーン';

  @override
  String get colorOrange => 'オレンジ';

  @override
  String get colorPink => 'ピンク';

  @override
  String get colorPurple => 'パープル';

  @override
  String get colorRed => 'レッド';

  @override
  String get colorGeneric => 'カラー';

  @override
  String get colorTitle => '色（カレンダー）';

  @override
  String get deleteConfirm => '本当に削除しますか？';

  @override
  String get deleteConfirmTitle => '削除確認';

  @override
  String get continueText => '次へ';

  @override
  String get language_subtitle => '表示言語を切り替えます';

  @override
  String get upload_policy_title => 'OCRテキストのみアップロード（既定：ON）';

  @override
  String get upload_policy_subtitle => 'プライバシー優先：画像はアップロードしません（後で設定可）';

  @override
  String get app_lock_title => 'アプリロックを有効化（推奨）';

  @override
  String get app_lock_subtitle => 'バックグラウンド復帰時にロック（後で顔/指紋対応）';

  @override
  String get cache_title => 'ローカルキャッシュ';

  @override
  String get cache_subtitle => '7日/30日/永久（TODO）';

  @override
  String get clear_data_title => 'データを削除';

  @override
  String get clear_data_subtitle => 'ローカル削除 / クラウド削除（API予約）';

  @override
  String get clear_QA => 'ローカル削除 / クラウド削除（API予約）';

  @override
  String get clear_content => 'ローカル削除 / クラウド削除（API予約）';

  @override
  String get logout_title => 'ログアウト';

  @override
  String get logout_QA => '現在のアカウントからログアウトしますか？';

  @override
  String get logout_OK => 'ログアウト';

  @override
  String get not_logged_in => '未ログイン';

  @override
  String no_name(Object name) {
    return 'ユーザー $name';
  }

  @override
  String get no_title => '(タイトルなし)\' ';

  @override
  String get another => 'その他 ';

  @override
  String get version_text => 'Life Inbox • v0.1.0 (MVP)';

  @override
  String get app_name => 'Life Inbox';

  @override
  String get terms_agree_prefix => '続行すると、以下に同意したものとみなされます。';

  @override
  String get open_terms_action => 'TODO：利用規約を開く';

  @override
  String get terms_title => '利用規約';

  @override
  String get terms_and => ' および ';

  @override
  String get open_privacy_action => 'TODO：プライバシーポリシーを開く';

  @override
  String get privacy_title => 'プライバシーポリシー';

  @override
  String get common_mail => 'メール';

  @override
  String get common_mail_hit => 'example@email.com';

  @override
  String get common_password => 'パスワード';

  @override
  String get common_or => 'または';

  @override
  String get common_password_hit => 'パスワードを入力してください';

  @override
  String get type_label => '種類';

  @override
  String get login_title => 'おかえりなさい';

  @override
  String get login_subtitle =>
      'ログインすると、スクリーンショットを取り込み、タスクやリスクを自動で検出し、アプリロックでプライバシーを保護できます。';

  @override
  String get login_logining => 'ログイン中...';

  @override
  String get login_with_mail => 'メールでログイン';

  @override
  String get login_with_google => 'Googleでログイン（仮）';

  @override
  String get login_continue_google => 'Continue with Google';

  @override
  String get login_no_account => 'アカウントをお持ちでない方は';

  @override
  String get login_to_register => '新規';

  @override
  String get login_hit => 'ヒント：ログイン後、設定からアプリロック（Face ID／指紋／システム認証）を有効にできます。';

  @override
  String get register_title => 'アカウント作成';

  @override
  String get register_subtitle =>
      'メールで登録します。後から Google/Apple の連携ができ、アプリロックを有効にして安全性を高められます。';

  @override
  String get register_password_hint => '8文字以上';

  @override
  String get register_password_confirm_label => 'パスワード（確認）';

  @override
  String get register_password_confirm_hint => 'もう一度入力してください';

  @override
  String get register_password_mismatch => 'パスワードが一致しません';

  @override
  String get register_button_loading => '登録中...';

  @override
  String get register_button_email => 'メールで登録';

  @override
  String get register_back_to_login => 'ログインに戻る';

  @override
  String get register_hint_success => '登録が完了すると自動的に受信箱へ移動します。';

  @override
  String get register_error_email_invalid => '正しいメールアドレスを入力してください';

  @override
  String get register_error_password_too_short => 'パスワードは8文字以上にしてください';

  @override
  String get all_Time => '期間指定なし';

  @override
  String get import_title => '写真取込';

  @override
  String get import_title_full => '写真取込';

  @override
  String get import_perm_title => '写真へのアクセス権がありません';

  @override
  String get import_perm_subtitle_ios =>
      'iOS の「設定 → プライバシーとセキュリティ → 写真」からアクセスを許可してください。';

  @override
  String get import_perm_retry => '権限を再リクエスト';

  @override
  String get refresh => '更新';

  @override
  String get import_range_unlimited => '期間指定なし';

  @override
  String get import_filter_range_label => '期間';

  @override
  String get import_filter_clear_range => '期間をクリア';

  @override
  String get import_screenshots_not_found =>
      '「スクリーンショット」アルバムが見つかりません。スクリーンショット絞り込みは全ての写真に切り替わります。';

  @override
  String import_screenshots_album_prefix(Object count) {
    return 'スクリーンショット： $count';
  }

  @override
  String import_selected_count(Object count) {
    return '$count 件選択中';
  }

  @override
  String get import_select_all_visible => '全選択';

  @override
  String get import_clear_selection => '選択解除';

  @override
  String import_queue_label(Object count) {
    return 'キュー $count';
  }

  @override
  String get import_empty_title => '条件に一致する写真がありません';

  @override
  String get import_empty_subtitle => '期間や種類の条件を変更してみてください。';

  @override
  String get loading_more => '読み込み中…';

  @override
  String get import_enqueue_button => '処理キューに追加';

  @override
  String import_enqueue_button_with_count(Object count) {
    return '処理キューに追加（$count）';
  }

  @override
  String get ocr_queue_title => 'OCR キュー';

  @override
  String get ocr_queue_clear => 'キューを空にする';

  @override
  String ocr_results_button(Object count) {
    return '結果（$count）';
  }

  @override
  String ocr_processing_prefix(Object count) {
    return '処理中：$count';
  }

  @override
  String get ocr_no_current => '実行中のタスクはありません';

  @override
  String ocr_queued_prefix(Object count) {
    return '待機：';
  }

  @override
  String get ocr_queue_empty => '待機中なし';

  @override
  String ocrResultsTitle(int count) {
    return 'OCR結果（$count）';
  }

  @override
  String get selectAll => '全選択';

  @override
  String get clearSelection => 'クリア';

  @override
  String get clearResultsTooltip => '結果をクリア';

  @override
  String get confirmButtonPleaseSelect => 'カードを選択してください';

  @override
  String confirmButtonSelectedCount(int count) {
    return '確認（$count）';
  }

  @override
  String get analysis_confirm_title => '確認保存';

  @override
  String get analysis_confirm_section_editable => '解析結果（編集可）';

  @override
  String get analysis_confirm_field_title => 'タイトル';

  @override
  String get analysis_confirm_field_summary => '内容／要約';

  @override
  String get analysis_confirm_field_due => '期限（YYYYMMDD）';

  @override
  String get analysis_confirm_field_risk => 'リスク';

  @override
  String get analysis_confirm_field_amount => '金額';

  @override
  String get analysis_confirm_field_currency => '通貨（JPY/CNY）';

  @override
  String get analysis_confirm_section_request => 'リクエスト（参考）';

  @override
  String get analysis_confirm_saving => '保存中...';

  @override
  String get analysis_confirm_save => '問題なければ保存';

  @override
  String get analysis_confirm_invalid_date =>
      '日付形式が正しくありません。YYYY-MM-DD を使用してください。';

  @override
  String get analysis_confirm_untitled => '無題';

  @override
  String get emptyOcrResults => 'OCR結果がありません';

  @override
  String get ocrStatusSuccess => '成功';

  @override
  String get ocrStatusFailed => '失敗';

  @override
  String get ocrStatusRunning => '処理中';

  @override
  String get ocrStatusQueued => '待機中';

  @override
  String get ocrFailedDefaultError => '認識に失敗しました';

  @override
  String get noTextPlaceholder => '（テキストなし）';

  @override
  String get ocrFullTextTitle => 'OCR全文';

  @override
  String get close => '閉じる';

  @override
  String get viewFullText => '全文を見る';

  @override
  String get calendarTitle => 'カレンダー';

  @override
  String get pickYearMonthTitle => '年月を選択';

  @override
  String get yearLabel => '年';

  @override
  String get monthLabel => '月';

  @override
  String get confirm => '確定';

  @override
  String get speechSheetTitle => '音声認識の内容';

  @override
  String get speechHintEditable => '認識結果がここに表示されます。編集できます。';

  @override
  String get goImport => 'インポートへ';

  @override
  String receivedSnack(String text) {
    return '受信しました：$text';
  }

  @override
  String get confirmAction => '確認';

  @override
  String get weekdaySun => '日';

  @override
  String get weekdayMon => '月';

  @override
  String get weekdayTue => '火';

  @override
  String get weekdayWed => '水';

  @override
  String get weekdayThu => '木';

  @override
  String get weekdayFri => '金';

  @override
  String get weekdaySat => '土';

  @override
  String dayItemsTitle(String date) {
    return '当日の項目：$date';
  }

  @override
  String get noDueItemsForDay => 'この日に期限が設定された項目はありません。';

  @override
  String get setDueHint => 'ヒント：項目に期限を設定するとカレンダーに表示されます。';

  @override
  String get noDueDate => '期限なし';

  @override
  String duePrefix(String due) {
    return '期限：$due';
  }

  @override
  String get nextStep => '次へ';

  @override
  String get inboxDetailTitle => '詳細';

  @override
  String inboxDetailSource(String source) {
    return '出所：$source';
  }

  @override
  String get inboxDetailThumbnailPlaceholder => '（将来的にサムネイル／元画像をここに表示）';

  @override
  String get inboxDetailStructuredFields => '構造化フィールド';

  @override
  String get inboxDetailDueTodo => '期限：TODO';

  @override
  String get inboxDetailAmountTodo => '金額：TODO';

  @override
  String get inboxDetailPhoneUrlTodo => '電話／URL：TODO';

  @override
  String get inboxDetailPrimaryActionAddCalendar => '主アクション：カレンダーに追加';

  @override
  String get inboxDetailMarkDoneTodo => '完了：TODO';

  @override
  String get inboxDetailEvidenceTitle => '解析根拠（OCR 断片）';

  @override
  String get inboxDetailOcrPlaceholder => 'OCR: ...（後ほどローカルOCRキャッシュと連携して表示）';

  @override
  String get inboxTitle => 'Life Inbox';

  @override
  String get inboxEmptyTitle => 'まだ内容がありません';

  @override
  String get inboxEmptySubtitle => 'スクリーンショットをインポートするか、音声ボタンを長押しして始めましょう';

  @override
  String get tooltipCalendarView => 'カレンダー表示';

  @override
  String get tooltipImport => 'インポート';

  @override
  String get tooltipSettings => '設定';

  @override
  String tabHigh(int count) {
    return '高優先（$count）';
  }

  @override
  String tabPending(int count) {
    return '未処理（$count）';
  }

  @override
  String tabDone(int count) {
    return '完了（$count）';
  }

  @override
  String get speechBarHintHoldToTalk => '音声を長押しし、話し終えたら離すと文字になります';

  @override
  String speechBarRecentPrefix(String text) {
    return '最近：$text';
  }

  @override
  String get lockPageTitle => 'アプリはロックされています';

  @override
  String get lockPageNeedUnlock => '続行するにはロック解除が必要です';

  @override
  String get unlock => 'ロック解除';

  @override
  String unlockReturnTo(String target) {
    return 'ロック解除後に戻ります：$target';
  }

  @override
  String get holdToTalkReleaseToStop => '離して終了';

  @override
  String get holdToTalkHoldToSpeak => '長押しで話す';

  @override
  String get holdToTalkUnavailable => '音声は利用できません';

  @override
  String get riskPrefix => 'リスク ';

  @override
  String get riskHigh => '高';

  @override
  String get riskMid => '中';

  @override
  String get riskLow => '低';

  @override
  String get importTypeAll => 'すべて';

  @override
  String get importTypeScreenshots => 'スクショ';

  @override
  String get importTypePhotos => '写真';

  @override
  String actionPageTitle(String actionType) {
    return 'アクション：$actionType';
  }

  @override
  String actionTypeLabel(String actionType) {
    return 'アクション種別：$actionType';
  }

  @override
  String actionItemIdLabel(String itemId) {
    return '項目ID：$itemId';
  }

  @override
  String get actionTodoDynamicRender => 'TODO：ここは actionType に応じて動的に描画';

  @override
  String get actionConfirmTodo => '確認（TODO：端末のカレンダー呼び出し／テンプレ複製／外部リンク遷移）';

  @override
  String error_loading(String error) {
    return '読み込みに失敗しました:$error';
  }

  @override
  String get setting_title => '設定';

  @override
  String get setting_not_logged_in => '未ログイン';

  @override
  String get setting_cloud_title => 'クラウド保存（有料）';

  @override
  String get setting_cloud_on => 'クラウド保存をオンにしました（サーバーに同期します）。';

  @override
  String get setting_cloud_off => 'クラウド保存をオフにしました（端末内のみに保存されます）。';

  @override
  String get setting_cloud_sub_success => '購読に成功しました。クラウド保存をオンにしました。';

  @override
  String get setting_cloud_status_subscribed => '購読中';

  @override
  String get setting_cloud_status_unsubscribed => '未購読';

  @override
  String setting_cloud_desc_on(Object status) {
    return 'オン：保存確定時にクラウドAPIを呼び出します（$status）。';
  }

  @override
  String setting_cloud_desc_off(Object status) {
    return '初期設定はオフ：データは端末内のみに保存されます（$status）。';
  }

  @override
  String get setting_debug_reset_sub => 'DEBUG：購読状態を未購読にリセット';

  @override
  String get setting_debug_reset_done => '未購読にリセットしました（DEBUG）';

  @override
  String get setting_privacy_saved_demo => '保存しました（サンプル：後ほど永続化に対応予定）。';

  @override
  String get setting_cache_todo => 'TODO：キャッシュ設定ページ。';

  @override
  String get setting_clear_confirm_title => 'クリアしますか？';

  @override
  String get setting_clear_confirm_desc => '端末内のキャッシュデータを削除します（サンプル表示）。';

  @override
  String get setting_clear_ok => 'クリア';

  @override
  String get setting_clear_done => 'クリアしました（サンプル：後ほど実装予定）。';

  @override
  String get setting_group => 'グループの管理（有料）';

  @override
  String get input_valid_mail_must => 'メールを入力してください';

  @override
  String get input_valid_mail_format => '正しいメールアドレスを入力してください';

  @override
  String get input_valid_pwd_must => 'パスワードを入力してください';

  @override
  String get input_valid_comfirm_pwd => '確認用パスワードを入力してください';

  @override
  String get register_with_mail => 'Eメールで登録';

  @override
  String get badRequest => 'リクエスト内容が正しくありません';

  @override
  String get unauthorized => 'メールアドレスまたはパスワードが正しくありません';

  @override
  String get forbidden => 'この操作を行う権限がありません';

  @override
  String get notFound => 'データが見つかりません';

  @override
  String get conflict => 'このメールアドレスは既に登録されています';

  @override
  String get validationError => '入力内容を確認してください（メール形式など）';

  @override
  String get serverError => 'サーバーエラーが発生しました。しばらくしてから再試行してください';

  @override
  String get unknown => '不明なエラーが発生しました';

  @override
  String get cloud_paywall_title => 'クラウド保存（有料）';

  @override
  String get cloud_paywall_desc => 'クラウド保存を利用するには Pro プランへの登録が必要です（Mock）。';

  @override
  String get cloud_feature_backup => 'サーバー上のデータベースに保存';

  @override
  String get cloud_feature_sync => '複数端末で同期（今後対応）';

  @override
  String get cloud_feature_offline => 'オフラインでも利用可能';

  @override
  String get cloud_price_monthly => '料金：月額 ¥300（Mock）';

  @override
  String get subscription_restore => '購入を復元';

  @override
  String get subscription_subscribe => '登録して有効化';

  @override
  String get paywallTitle => 'プレミアム（有料）';

  @override
  String get paywallDesc => 'グループ管理・クラウド保存などの機能を利用するには\nプレミアム登録が必要です。';

  @override
  String get loadingText => '読み込み中...';

  @override
  String get planMonthly => '月額プラン';

  @override
  String get planYearly => '年額プラン';

  @override
  String get restorePurchase => '購入を復元（Restore）';

  @override
  String get cancelGuideTitle => '解約はApp Store / Google Playのサブスク管理から';

  @override
  String get cancelGuideSubtitle => 'アプリ内では解約できません';

  @override
  String get notNow => '今はしない';

  @override
  String get personalInfoTitle => '個人情報';

  @override
  String get profileImage => 'プロフィール画像';

  @override
  String get nickname => 'ニックネーム';

  @override
  String get joinGroupTitle => 'グループに入る';

  @override
  String get joinGroupHelp => 'グループのオーナーに連絡して招待を出してもらってください\n（グループの設定＞メンバーを追加）';

  @override
  String get joinGroupHint => '招待コードを入力してください';

  @override
  String get joinGroupCodeEmpty => '招待コードを入力してください';

  @override
  String get joinGroupJoined => '参加しました';

  @override
  String get groupCreateTitle => 'グループ作成';

  @override
  String get groupName => 'グループ名';

  @override
  String get groupSettingsTitle => 'グループ設定';

  @override
  String get groupMembers => 'グループメンバー';

  @override
  String get groupOwnerLabel => 'グループの所有者';

  @override
  String get groupMemberLabel => '普通メンバー';

  @override
  String get ownerOnlyCanChange => 'オーナーのみ変更できます';

  @override
  String get ownerOnlyCanAdd => 'オーナーのみ追加できます';

  @override
  String get ownerOnlyCanDelete => 'オーナーのみ削除できます';

  @override
  String get groupNameInputTitleCreate => 'グループ名を入力';

  @override
  String get groupNameInputTitleEdit => 'グループ名称';

  @override
  String get groupNameEmpty => 'グループ名を入力してください';

  @override
  String get groupCreated => 'グループを作成しました';

  @override
  String get addMember => 'メンバーを追加';

  @override
  String get inviteSmsNotImplemented => 'SMSで招待（未実装）';

  @override
  String get inviteEmailNotImplemented => 'メールで招待（未実装）';

  @override
  String get deleteGroupTitle => 'グループの削除';

  @override
  String get noPermission => '権限がありません';

  @override
  String get memberTransferOwner => 'オーナーに移管';

  @override
  String get memberRemove => 'メンバーを削除';

  @override
  String get memberRemoved => '削除しました';

  @override
  String get ownerTransferred => 'オーナーを移管しました';

  @override
  String get deleteApiNotConnected => '削除API未接続';

  @override
  String get swipeMarkDone => '完了にする';

  @override
  String get swipeRestore => '未完了に戻す';

  @override
  String get groupManage => 'グループ管理';

  @override
  String get nogroup => 'まだグループがありません';

  @override
  String get joinGroup => 'グループに入る';

  @override
  String get inviteChooseMethodTitle => '誘う方法を選択';

  @override
  String get inviteMethodAccount => 'アプリアカウント';

  @override
  String get inviteMethodSms => 'SMS';

  @override
  String get inviteMethodEmail => '電子メール';

  @override
  String get inviteMethodCode => '招待コード';

  @override
  String get inviteCodeCopied => '招待コードをコピーしました';

  @override
  String get account => 'アカウント';

  @override
  String get inputAccount => 'アカウント番号を入力してください';

  @override
  String get inputName => 'メンバーの名前を入力';

  @override
  String get displayname => '名前';

  @override
  String get speechSavedToLocalInbox => 'ローカルInboxに保存しました';

  @override
  String speechAnalyzeFailed(Object error) {
    return '音声解析に失敗しました：$error';
  }

  @override
  String get speechMockTitle => '音声テキスト（模擬）';

  @override
  String get speechMockCustomInputLabel => 'カスタム入力（優先）';

  @override
  String get speechMockUseInput => '入力を使用';

  @override
  String get speechParsing => '解析中...';

  @override
  String get speechMockTooltip => '音声テキスト（模擬）';

  @override
  String get group_desc => 'グループ管理は有料機能です（未契約／グループ未作成のため「個人」に固定されています）';

  @override
  String get group => 'グループ';

  @override
  String get personal => '個人';

  @override
  String get holidayShort => '祝';

  @override
  String get holidayLabel => '祝日';

  @override
  String get holidaysLoading => '祝日を読み込み中…';

  @override
  String get copied => 'コピーした';

  @override
  String get groupInviteMessage => 'LifeBoxのグループに招待されています。以下の招待コードを使って参加できます。';

  @override
  String get inviteCodeLabel => '招待コード';

  @override
  String get groupInviteEmailSubject => 'LifeBox グループへの招待';

  @override
  String get joinGroupFailed => '招待コードが無効、または期限切れです。';
}
