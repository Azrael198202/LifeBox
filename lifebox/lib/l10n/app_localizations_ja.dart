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
  String get clear_OK => '削除';

  @override
  String get logout_title => 'ログアウト';

  @override
  String get logout_QA => '現在のアカウントからログアウトしますか？';

  @override
  String get logout_OK => 'ログアウト';

  @override
  String get not_logged_in => '未ログイン';

  @override
  String get common_Cancel => 'キャンセル';

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
  String get login_to_register => 'アカウントをお持ちでない方はこちら';

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
  String get import_title => '取り込み';

  @override
  String get import_title_full => '取り込み（絞り込み + キュー）';

  @override
  String get import_perm_title => '写真へのアクセス権がありません';

  @override
  String get import_perm_subtitle_ios =>
      'iOS の「設定 → プライバシーとセキュリティ → 写真」からアクセスを許可してください。';

  @override
  String get import_perm_retry => '権限を再リクエスト';

  @override
  String get import_action_refresh => '更新';

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
  String get import_loading_more => '読み込み中…';

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
    return '確定（$count）';
  }

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
  String get cancel => 'キャンセル';

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
  String get inboxDetailMarkDoneTodo => '完了としてマーク（TODO）';

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
}
