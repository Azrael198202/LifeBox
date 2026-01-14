import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ja'),
    Locale('zh')
  ];

  /// No description provided for @settings_title.
  ///
  /// In ja, this message translates to:
  /// **'設定'**
  String get settings_title;

  /// No description provided for @language_title.
  ///
  /// In ja, this message translates to:
  /// **'言語'**
  String get language_title;

  /// No description provided for @language_subtitle.
  ///
  /// In ja, this message translates to:
  /// **'表示言語を切り替えます'**
  String get language_subtitle;

  /// No description provided for @upload_policy_title.
  ///
  /// In ja, this message translates to:
  /// **'OCRテキストのみアップロード（既定：ON）'**
  String get upload_policy_title;

  /// No description provided for @upload_policy_subtitle.
  ///
  /// In ja, this message translates to:
  /// **'プライバシー優先：画像はアップロードしません（後で設定可）'**
  String get upload_policy_subtitle;

  /// No description provided for @app_lock_title.
  ///
  /// In ja, this message translates to:
  /// **'アプリロックを有効化（推奨）'**
  String get app_lock_title;

  /// No description provided for @app_lock_subtitle.
  ///
  /// In ja, this message translates to:
  /// **'バックグラウンド復帰時にロック（後で顔/指紋対応）'**
  String get app_lock_subtitle;

  /// No description provided for @cache_title.
  ///
  /// In ja, this message translates to:
  /// **'ローカルキャッシュ'**
  String get cache_title;

  /// No description provided for @cache_subtitle.
  ///
  /// In ja, this message translates to:
  /// **'7日/30日/永久（TODO）'**
  String get cache_subtitle;

  /// No description provided for @clear_data_title.
  ///
  /// In ja, this message translates to:
  /// **'データを削除'**
  String get clear_data_title;

  /// No description provided for @clear_data_subtitle.
  ///
  /// In ja, this message translates to:
  /// **'ローカル削除 / クラウド削除（API予約）'**
  String get clear_data_subtitle;

  /// No description provided for @clear_QA.
  ///
  /// In ja, this message translates to:
  /// **'ローカル削除 / クラウド削除（API予約）'**
  String get clear_QA;

  /// No description provided for @clear_content.
  ///
  /// In ja, this message translates to:
  /// **'ローカル削除 / クラウド削除（API予約）'**
  String get clear_content;

  /// No description provided for @clear_OK.
  ///
  /// In ja, this message translates to:
  /// **'削除'**
  String get clear_OK;

  /// No description provided for @logout_title.
  ///
  /// In ja, this message translates to:
  /// **'ログアウト'**
  String get logout_title;

  /// No description provided for @logout_QA.
  ///
  /// In ja, this message translates to:
  /// **'現在のアカウントからログアウトしますか？'**
  String get logout_QA;

  /// No description provided for @logout_OK.
  ///
  /// In ja, this message translates to:
  /// **'ログアウト'**
  String get logout_OK;

  /// No description provided for @not_logged_in.
  ///
  /// In ja, this message translates to:
  /// **'未ログイン'**
  String get not_logged_in;

  /// No description provided for @common_Cancel.
  ///
  /// In ja, this message translates to:
  /// **'キャンセル'**
  String get common_Cancel;

  /// No description provided for @version_text.
  ///
  /// In ja, this message translates to:
  /// **'Life Inbox • v0.1.0 (MVP)'**
  String get version_text;

  /// No description provided for @app_name.
  ///
  /// In ja, this message translates to:
  /// **'Life Inbox'**
  String get app_name;

  /// No description provided for @terms_agree_prefix.
  ///
  /// In ja, this message translates to:
  /// **'続行すると、以下に同意したものとみなされます。'**
  String get terms_agree_prefix;

  /// No description provided for @open_terms_action.
  ///
  /// In ja, this message translates to:
  /// **'TODO：利用規約を開く'**
  String get open_terms_action;

  /// No description provided for @terms_title.
  ///
  /// In ja, this message translates to:
  /// **'利用規約'**
  String get terms_title;

  /// No description provided for @terms_and.
  ///
  /// In ja, this message translates to:
  /// **' および '**
  String get terms_and;

  /// No description provided for @open_privacy_action.
  ///
  /// In ja, this message translates to:
  /// **'TODO：プライバシーポリシーを開く'**
  String get open_privacy_action;

  /// No description provided for @privacy_title.
  ///
  /// In ja, this message translates to:
  /// **'プライバシーポリシー'**
  String get privacy_title;

  /// No description provided for @common_mail.
  ///
  /// In ja, this message translates to:
  /// **'メール'**
  String get common_mail;

  /// No description provided for @common_mail_hit.
  ///
  /// In ja, this message translates to:
  /// **'example@email.com'**
  String get common_mail_hit;

  /// No description provided for @common_password.
  ///
  /// In ja, this message translates to:
  /// **'パスワード'**
  String get common_password;

  /// No description provided for @common_or.
  ///
  /// In ja, this message translates to:
  /// **'または'**
  String get common_or;

  /// No description provided for @common_password_hit.
  ///
  /// In ja, this message translates to:
  /// **'パスワードを入力してください'**
  String get common_password_hit;

  /// No description provided for @type_label.
  ///
  /// In ja, this message translates to:
  /// **'種類'**
  String get type_label;

  /// No description provided for @login_title.
  ///
  /// In ja, this message translates to:
  /// **'おかえりなさい'**
  String get login_title;

  /// No description provided for @login_subtitle.
  ///
  /// In ja, this message translates to:
  /// **'ログインすると、スクリーンショットを取り込み、タスクやリスクを自動で検出し、アプリロックでプライバシーを保護できます。'**
  String get login_subtitle;

  /// No description provided for @login_logining.
  ///
  /// In ja, this message translates to:
  /// **'ログイン中...'**
  String get login_logining;

  /// No description provided for @login_with_mail.
  ///
  /// In ja, this message translates to:
  /// **'メールでログイン'**
  String get login_with_mail;

  /// No description provided for @login_with_google.
  ///
  /// In ja, this message translates to:
  /// **'Googleでログイン（仮）'**
  String get login_with_google;

  /// No description provided for @login_to_register.
  ///
  /// In ja, this message translates to:
  /// **'アカウントをお持ちでない方はこちら'**
  String get login_to_register;

  /// No description provided for @login_hit.
  ///
  /// In ja, this message translates to:
  /// **'ヒント：ログイン後、設定からアプリロック（Face ID／指紋／システム認証）を有効にできます。'**
  String get login_hit;

  /// No description provided for @register_title.
  ///
  /// In ja, this message translates to:
  /// **'アカウント作成'**
  String get register_title;

  /// No description provided for @register_subtitle.
  ///
  /// In ja, this message translates to:
  /// **'メールで登録します。後から Google/Apple の連携ができ、アプリロックを有効にして安全性を高められます。'**
  String get register_subtitle;

  /// No description provided for @register_password_hint.
  ///
  /// In ja, this message translates to:
  /// **'8文字以上'**
  String get register_password_hint;

  /// No description provided for @register_password_confirm_label.
  ///
  /// In ja, this message translates to:
  /// **'パスワード（確認）'**
  String get register_password_confirm_label;

  /// No description provided for @register_password_confirm_hint.
  ///
  /// In ja, this message translates to:
  /// **'もう一度入力してください'**
  String get register_password_confirm_hint;

  /// No description provided for @register_password_mismatch.
  ///
  /// In ja, this message translates to:
  /// **'パスワードが一致しません'**
  String get register_password_mismatch;

  /// No description provided for @register_button_loading.
  ///
  /// In ja, this message translates to:
  /// **'登録中...'**
  String get register_button_loading;

  /// No description provided for @register_button_email.
  ///
  /// In ja, this message translates to:
  /// **'メールで登録'**
  String get register_button_email;

  /// No description provided for @register_back_to_login.
  ///
  /// In ja, this message translates to:
  /// **'ログインに戻る'**
  String get register_back_to_login;

  /// No description provided for @register_hint_success.
  ///
  /// In ja, this message translates to:
  /// **'登録が完了すると自動的に受信箱へ移動します。'**
  String get register_hint_success;

  /// No description provided for @register_error_email_invalid.
  ///
  /// In ja, this message translates to:
  /// **'正しいメールアドレスを入力してください'**
  String get register_error_email_invalid;

  /// No description provided for @register_error_password_too_short.
  ///
  /// In ja, this message translates to:
  /// **'パスワードは8文字以上にしてください'**
  String get register_error_password_too_short;

  /// No description provided for @all_Time.
  ///
  /// In ja, this message translates to:
  /// **'期間指定なし'**
  String get all_Time;

  /// No description provided for @import_title.
  ///
  /// In ja, this message translates to:
  /// **'取り込み'**
  String get import_title;

  /// No description provided for @import_title_full.
  ///
  /// In ja, this message translates to:
  /// **'取り込み（絞り込み + キュー）'**
  String get import_title_full;

  /// No description provided for @import_perm_title.
  ///
  /// In ja, this message translates to:
  /// **'写真へのアクセス権がありません'**
  String get import_perm_title;

  /// No description provided for @import_perm_subtitle_ios.
  ///
  /// In ja, this message translates to:
  /// **'iOS の「設定 → プライバシーとセキュリティ → 写真」からアクセスを許可してください。'**
  String get import_perm_subtitle_ios;

  /// No description provided for @import_perm_retry.
  ///
  /// In ja, this message translates to:
  /// **'権限を再リクエスト'**
  String get import_perm_retry;

  /// No description provided for @import_action_refresh.
  ///
  /// In ja, this message translates to:
  /// **'更新'**
  String get import_action_refresh;

  /// No description provided for @import_range_unlimited.
  ///
  /// In ja, this message translates to:
  /// **'期間指定なし'**
  String get import_range_unlimited;

  /// No description provided for @import_filter_range_label.
  ///
  /// In ja, this message translates to:
  /// **'期間'**
  String get import_filter_range_label;

  /// No description provided for @import_filter_clear_range.
  ///
  /// In ja, this message translates to:
  /// **'期間をクリア'**
  String get import_filter_clear_range;

  /// No description provided for @import_screenshots_not_found.
  ///
  /// In ja, this message translates to:
  /// **'「スクリーンショット」アルバムが見つかりません。スクリーンショット絞り込みは全ての写真に切り替わります。'**
  String get import_screenshots_not_found;

  /// No description provided for @import_screenshots_album_prefix.
  ///
  /// In ja, this message translates to:
  /// **'スクリーンショット： {count}'**
  String import_screenshots_album_prefix(Object count);

  /// No description provided for @import_selected_count.
  ///
  /// In ja, this message translates to:
  /// **'{count} 件選択中'**
  String import_selected_count(Object count);

  /// No description provided for @import_select_all_visible.
  ///
  /// In ja, this message translates to:
  /// **'表示中を全選択'**
  String get import_select_all_visible;

  /// No description provided for @import_clear_selection.
  ///
  /// In ja, this message translates to:
  /// **'選択解除'**
  String get import_clear_selection;

  /// No description provided for @import_queue_label.
  ///
  /// In ja, this message translates to:
  /// **'キュー {count}'**
  String import_queue_label(Object count);

  /// No description provided for @import_empty_title.
  ///
  /// In ja, this message translates to:
  /// **'条件に一致する写真がありません'**
  String get import_empty_title;

  /// No description provided for @import_empty_subtitle.
  ///
  /// In ja, this message translates to:
  /// **'期間や種類の条件を変更してみてください。'**
  String get import_empty_subtitle;

  /// No description provided for @import_loading_more.
  ///
  /// In ja, this message translates to:
  /// **'読み込み中…'**
  String get import_loading_more;

  /// No description provided for @import_enqueue_button.
  ///
  /// In ja, this message translates to:
  /// **'処理キューに追加'**
  String get import_enqueue_button;

  /// No description provided for @import_enqueue_button_with_count.
  ///
  /// In ja, this message translates to:
  /// **'処理キューに追加（{count}）'**
  String import_enqueue_button_with_count(Object count);

  /// No description provided for @ocr_queue_title.
  ///
  /// In ja, this message translates to:
  /// **'OCR キュー'**
  String get ocr_queue_title;

  /// No description provided for @ocr_queue_clear.
  ///
  /// In ja, this message translates to:
  /// **'キューを空にする'**
  String get ocr_queue_clear;

  /// No description provided for @ocr_results_button.
  ///
  /// In ja, this message translates to:
  /// **'結果（{count}）'**
  String ocr_results_button(Object count);

  /// No description provided for @ocr_processing_prefix.
  ///
  /// In ja, this message translates to:
  /// **'処理中：{count}'**
  String ocr_processing_prefix(Object count);

  /// No description provided for @ocr_no_current.
  ///
  /// In ja, this message translates to:
  /// **'実行中のタスクはありません'**
  String get ocr_no_current;

  /// No description provided for @ocr_queued_prefix.
  ///
  /// In ja, this message translates to:
  /// **'待機：'**
  String ocr_queued_prefix(Object count);

  /// No description provided for @ocr_queue_empty.
  ///
  /// In ja, this message translates to:
  /// **'待機中なし'**
  String get ocr_queue_empty;

  /// Title of OCR results page with count
  ///
  /// In ja, this message translates to:
  /// **'OCR結果（{count}）'**
  String ocrResultsTitle(int count);

  /// No description provided for @selectAll.
  ///
  /// In ja, this message translates to:
  /// **'全選択'**
  String get selectAll;

  /// No description provided for @clearSelection.
  ///
  /// In ja, this message translates to:
  /// **'クリア'**
  String get clearSelection;

  /// No description provided for @clearResultsTooltip.
  ///
  /// In ja, this message translates to:
  /// **'結果をクリア'**
  String get clearResultsTooltip;

  /// No description provided for @confirmButtonPleaseSelect.
  ///
  /// In ja, this message translates to:
  /// **'カードを選択してください'**
  String get confirmButtonPleaseSelect;

  /// Confirm button label with selected count
  ///
  /// In ja, this message translates to:
  /// **'確定（{count}）'**
  String confirmButtonSelectedCount(int count);

  /// No description provided for @emptyOcrResults.
  ///
  /// In ja, this message translates to:
  /// **'OCR結果がありません'**
  String get emptyOcrResults;

  /// No description provided for @ocrStatusSuccess.
  ///
  /// In ja, this message translates to:
  /// **'成功'**
  String get ocrStatusSuccess;

  /// No description provided for @ocrStatusFailed.
  ///
  /// In ja, this message translates to:
  /// **'失敗'**
  String get ocrStatusFailed;

  /// No description provided for @ocrStatusRunning.
  ///
  /// In ja, this message translates to:
  /// **'処理中'**
  String get ocrStatusRunning;

  /// No description provided for @ocrStatusQueued.
  ///
  /// In ja, this message translates to:
  /// **'待機中'**
  String get ocrStatusQueued;

  /// No description provided for @ocrFailedDefaultError.
  ///
  /// In ja, this message translates to:
  /// **'認識に失敗しました'**
  String get ocrFailedDefaultError;

  /// No description provided for @noTextPlaceholder.
  ///
  /// In ja, this message translates to:
  /// **'（テキストなし）'**
  String get noTextPlaceholder;

  /// No description provided for @ocrFullTextTitle.
  ///
  /// In ja, this message translates to:
  /// **'OCR全文'**
  String get ocrFullTextTitle;

  /// No description provided for @close.
  ///
  /// In ja, this message translates to:
  /// **'閉じる'**
  String get close;

  /// No description provided for @viewFullText.
  ///
  /// In ja, this message translates to:
  /// **'全文を見る'**
  String get viewFullText;

  /// No description provided for @calendarTitle.
  ///
  /// In ja, this message translates to:
  /// **'カレンダー'**
  String get calendarTitle;

  /// No description provided for @pickYearMonthTitle.
  ///
  /// In ja, this message translates to:
  /// **'年月を選択'**
  String get pickYearMonthTitle;

  /// No description provided for @yearLabel.
  ///
  /// In ja, this message translates to:
  /// **'年'**
  String get yearLabel;

  /// No description provided for @monthLabel.
  ///
  /// In ja, this message translates to:
  /// **'月'**
  String get monthLabel;

  /// No description provided for @cancel.
  ///
  /// In ja, this message translates to:
  /// **'キャンセル'**
  String get cancel;

  /// No description provided for @confirm.
  ///
  /// In ja, this message translates to:
  /// **'確定'**
  String get confirm;

  /// No description provided for @speechSheetTitle.
  ///
  /// In ja, this message translates to:
  /// **'音声認識の内容'**
  String get speechSheetTitle;

  /// No description provided for @speechHintEditable.
  ///
  /// In ja, this message translates to:
  /// **'認識結果がここに表示されます。編集できます。'**
  String get speechHintEditable;

  /// No description provided for @goImport.
  ///
  /// In ja, this message translates to:
  /// **'インポートへ'**
  String get goImport;

  /// SnackBar message after receiving final text
  ///
  /// In ja, this message translates to:
  /// **'受信しました：{text}'**
  String receivedSnack(String text);

  /// No description provided for @confirmAction.
  ///
  /// In ja, this message translates to:
  /// **'確認'**
  String get confirmAction;

  /// No description provided for @weekdaySun.
  ///
  /// In ja, this message translates to:
  /// **'日'**
  String get weekdaySun;

  /// No description provided for @weekdayMon.
  ///
  /// In ja, this message translates to:
  /// **'月'**
  String get weekdayMon;

  /// No description provided for @weekdayTue.
  ///
  /// In ja, this message translates to:
  /// **'火'**
  String get weekdayTue;

  /// No description provided for @weekdayWed.
  ///
  /// In ja, this message translates to:
  /// **'水'**
  String get weekdayWed;

  /// No description provided for @weekdayThu.
  ///
  /// In ja, this message translates to:
  /// **'木'**
  String get weekdayThu;

  /// No description provided for @weekdayFri.
  ///
  /// In ja, this message translates to:
  /// **'金'**
  String get weekdayFri;

  /// No description provided for @weekdaySat.
  ///
  /// In ja, this message translates to:
  /// **'土'**
  String get weekdaySat;

  /// Title for selected day section with date
  ///
  /// In ja, this message translates to:
  /// **'当日の項目：{date}'**
  String dayItemsTitle(String date);

  /// No description provided for @noDueItemsForDay.
  ///
  /// In ja, this message translates to:
  /// **'この日に期限が設定された項目はありません。'**
  String get noDueItemsForDay;

  /// No description provided for @setDueHint.
  ///
  /// In ja, this message translates to:
  /// **'ヒント：項目に期限を設定するとカレンダーに表示されます。'**
  String get setDueHint;

  /// No description provided for @noDueDate.
  ///
  /// In ja, this message translates to:
  /// **'期限なし'**
  String get noDueDate;

  /// Due date label prefix on inbox card
  ///
  /// In ja, this message translates to:
  /// **'期限：{due}'**
  String duePrefix(String due);

  /// No description provided for @nextStep.
  ///
  /// In ja, this message translates to:
  /// **'次へ'**
  String get nextStep;

  /// No description provided for @inboxDetailTitle.
  ///
  /// In ja, this message translates to:
  /// **'詳細'**
  String get inboxDetailTitle;

  /// No description provided for @inboxDetailSource.
  ///
  /// In ja, this message translates to:
  /// **'出所：{source}'**
  String inboxDetailSource(String source);

  /// No description provided for @inboxDetailThumbnailPlaceholder.
  ///
  /// In ja, this message translates to:
  /// **'（将来的にサムネイル／元画像をここに表示）'**
  String get inboxDetailThumbnailPlaceholder;

  /// No description provided for @inboxDetailStructuredFields.
  ///
  /// In ja, this message translates to:
  /// **'構造化フィールド'**
  String get inboxDetailStructuredFields;

  /// No description provided for @inboxDetailDueTodo.
  ///
  /// In ja, this message translates to:
  /// **'期限：TODO'**
  String get inboxDetailDueTodo;

  /// No description provided for @inboxDetailAmountTodo.
  ///
  /// In ja, this message translates to:
  /// **'金額：TODO'**
  String get inboxDetailAmountTodo;

  /// No description provided for @inboxDetailPhoneUrlTodo.
  ///
  /// In ja, this message translates to:
  /// **'電話／URL：TODO'**
  String get inboxDetailPhoneUrlTodo;

  /// No description provided for @inboxDetailPrimaryActionAddCalendar.
  ///
  /// In ja, this message translates to:
  /// **'主アクション：カレンダーに追加'**
  String get inboxDetailPrimaryActionAddCalendar;

  /// No description provided for @inboxDetailMarkDoneTodo.
  ///
  /// In ja, this message translates to:
  /// **'完了としてマーク（TODO）'**
  String get inboxDetailMarkDoneTodo;

  /// No description provided for @inboxDetailEvidenceTitle.
  ///
  /// In ja, this message translates to:
  /// **'解析根拠（OCR 断片）'**
  String get inboxDetailEvidenceTitle;

  /// No description provided for @inboxDetailOcrPlaceholder.
  ///
  /// In ja, this message translates to:
  /// **'OCR: ...（後ほどローカルOCRキャッシュと連携して表示）'**
  String get inboxDetailOcrPlaceholder;

  /// No description provided for @inboxTitle.
  ///
  /// In ja, this message translates to:
  /// **'Life Inbox'**
  String get inboxTitle;

  /// No description provided for @inboxEmptyTitle.
  ///
  /// In ja, this message translates to:
  /// **'まだ内容がありません'**
  String get inboxEmptyTitle;

  /// No description provided for @inboxEmptySubtitle.
  ///
  /// In ja, this message translates to:
  /// **'スクリーンショットをインポートするか、音声ボタンを長押しして始めましょう'**
  String get inboxEmptySubtitle;

  /// No description provided for @tooltipCalendarView.
  ///
  /// In ja, this message translates to:
  /// **'カレンダー表示'**
  String get tooltipCalendarView;

  /// No description provided for @tooltipImport.
  ///
  /// In ja, this message translates to:
  /// **'インポート'**
  String get tooltipImport;

  /// No description provided for @tooltipSettings.
  ///
  /// In ja, this message translates to:
  /// **'設定'**
  String get tooltipSettings;

  /// No description provided for @tabHigh.
  ///
  /// In ja, this message translates to:
  /// **'高優先（{count}）'**
  String tabHigh(int count);

  /// No description provided for @tabPending.
  ///
  /// In ja, this message translates to:
  /// **'未処理（{count}）'**
  String tabPending(int count);

  /// No description provided for @tabDone.
  ///
  /// In ja, this message translates to:
  /// **'完了（{count}）'**
  String tabDone(int count);

  /// No description provided for @speechBarHintHoldToTalk.
  ///
  /// In ja, this message translates to:
  /// **'音声を長押しし、話し終えたら離すと文字になります'**
  String get speechBarHintHoldToTalk;

  /// No description provided for @speechBarRecentPrefix.
  ///
  /// In ja, this message translates to:
  /// **'最近：{text}'**
  String speechBarRecentPrefix(String text);

  /// No description provided for @lockPageTitle.
  ///
  /// In ja, this message translates to:
  /// **'アプリはロックされています'**
  String get lockPageTitle;

  /// No description provided for @lockPageNeedUnlock.
  ///
  /// In ja, this message translates to:
  /// **'続行するにはロック解除が必要です'**
  String get lockPageNeedUnlock;

  /// No description provided for @unlock.
  ///
  /// In ja, this message translates to:
  /// **'ロック解除'**
  String get unlock;

  /// No description provided for @unlockReturnTo.
  ///
  /// In ja, this message translates to:
  /// **'ロック解除後に戻ります：{target}'**
  String unlockReturnTo(String target);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ja', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ja':
      return AppLocalizationsJa();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
