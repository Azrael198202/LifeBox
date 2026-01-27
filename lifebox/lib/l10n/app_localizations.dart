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

  /// No description provided for @language_jp.
  ///
  /// In ja, this message translates to:
  /// **'日本語'**
  String get language_jp;

  /// No description provided for @language_zh.
  ///
  /// In ja, this message translates to:
  /// **'中国語'**
  String get language_zh;

  /// No description provided for @language_en.
  ///
  /// In ja, this message translates to:
  /// **'英語'**
  String get language_en;

  /// No description provided for @clear.
  ///
  /// In ja, this message translates to:
  /// **'クリア'**
  String get clear;

  /// No description provided for @delete.
  ///
  /// In ja, this message translates to:
  /// **'削除'**
  String get delete;

  /// No description provided for @cancel.
  ///
  /// In ja, this message translates to:
  /// **'キャンセル'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In ja, this message translates to:
  /// **'保存'**
  String get save;

  /// No description provided for @finish.
  ///
  /// In ja, this message translates to:
  /// **'終了'**
  String get finish;

  /// No description provided for @select.
  ///
  /// In ja, this message translates to:
  /// **'選択'**
  String get select;

  /// No description provided for @colorBlueGrey.
  ///
  /// In ja, this message translates to:
  /// **'ブルーグレー'**
  String get colorBlueGrey;

  /// No description provided for @colorBlue.
  ///
  /// In ja, this message translates to:
  /// **'ブルー'**
  String get colorBlue;

  /// No description provided for @colorGreen.
  ///
  /// In ja, this message translates to:
  /// **'グリーン'**
  String get colorGreen;

  /// No description provided for @colorOrange.
  ///
  /// In ja, this message translates to:
  /// **'オレンジ'**
  String get colorOrange;

  /// No description provided for @colorPink.
  ///
  /// In ja, this message translates to:
  /// **'ピンク'**
  String get colorPink;

  /// No description provided for @colorPurple.
  ///
  /// In ja, this message translates to:
  /// **'パープル'**
  String get colorPurple;

  /// No description provided for @colorRed.
  ///
  /// In ja, this message translates to:
  /// **'レッド'**
  String get colorRed;

  /// No description provided for @colorGeneric.
  ///
  /// In ja, this message translates to:
  /// **'カラー'**
  String get colorGeneric;

  /// No description provided for @colorTitle.
  ///
  /// In ja, this message translates to:
  /// **'色（カレンダー）'**
  String get colorTitle;

  /// No description provided for @deleteConfirm.
  ///
  /// In ja, this message translates to:
  /// **'本当に削除しますか？'**
  String get deleteConfirm;

  /// No description provided for @deleteConfirmTitle.
  ///
  /// In ja, this message translates to:
  /// **'削除確認'**
  String get deleteConfirmTitle;

  /// No description provided for @continueText.
  ///
  /// In ja, this message translates to:
  /// **'次へ'**
  String get continueText;

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

  /// No description provided for @no_name.
  ///
  /// In ja, this message translates to:
  /// **'ユーザー {name}'**
  String no_name(Object name);

  /// No description provided for @no_title.
  ///
  /// In ja, this message translates to:
  /// **'(タイトルなし)\' '**
  String get no_title;

  /// No description provided for @another.
  ///
  /// In ja, this message translates to:
  /// **'その他 '**
  String get another;

  /// No description provided for @version_text.
  ///
  /// In ja, this message translates to:
  /// **'スッと • v0.1.0 (MVP)'**
  String get version_text;

  /// No description provided for @app_name.
  ///
  /// In ja, this message translates to:
  /// **'スッと'**
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

  /// No description provided for @login_continue_google.
  ///
  /// In ja, this message translates to:
  /// **'Continue with Google'**
  String get login_continue_google;

  /// No description provided for @login_no_account.
  ///
  /// In ja, this message translates to:
  /// **'アカウントをお持ちでない方は'**
  String get login_no_account;

  /// No description provided for @login_to_register.
  ///
  /// In ja, this message translates to:
  /// **'新規'**
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
  /// **'写真取込'**
  String get import_title;

  /// No description provided for @import_title_full.
  ///
  /// In ja, this message translates to:
  /// **'写真取込'**
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

  /// No description provided for @refresh.
  ///
  /// In ja, this message translates to:
  /// **'更新'**
  String get refresh;

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
  /// **'全選択'**
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

  /// No description provided for @loading_more.
  ///
  /// In ja, this message translates to:
  /// **'読み込み中…'**
  String get loading_more;

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

  /// No description provided for @login_already_have_account.
  ///
  /// In ja, this message translates to:
  /// **'すでにアカウントをお持ちですか？'**
  String get login_already_have_account;

  /// No description provided for @login_to_login.
  ///
  /// In ja, this message translates to:
  /// **'ログインへ'**
  String get login_to_login;

  /// No description provided for @terms_must_agree.
  ///
  /// In ja, this message translates to:
  /// **'利用規約とプライバシーポリシーに同意してください。'**
  String get terms_must_agree;

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
  /// **'確認（{count}）'**
  String confirmButtonSelectedCount(int count);

  /// No description provided for @analysis_confirm_title.
  ///
  /// In ja, this message translates to:
  /// **'確認保存'**
  String get analysis_confirm_title;

  /// No description provided for @analysis_confirm_section_editable.
  ///
  /// In ja, this message translates to:
  /// **'解析結果（編集可）'**
  String get analysis_confirm_section_editable;

  /// No description provided for @analysis_confirm_field_title.
  ///
  /// In ja, this message translates to:
  /// **'タイトル'**
  String get analysis_confirm_field_title;

  /// No description provided for @analysis_confirm_field_summary.
  ///
  /// In ja, this message translates to:
  /// **'内容／要約'**
  String get analysis_confirm_field_summary;

  /// No description provided for @analysis_confirm_field_due.
  ///
  /// In ja, this message translates to:
  /// **'期限（YYYYMMDD）'**
  String get analysis_confirm_field_due;

  /// No description provided for @analysis_confirm_field_risk.
  ///
  /// In ja, this message translates to:
  /// **'リスク'**
  String get analysis_confirm_field_risk;

  /// No description provided for @analysis_confirm_field_amount.
  ///
  /// In ja, this message translates to:
  /// **'金額'**
  String get analysis_confirm_field_amount;

  /// No description provided for @analysis_confirm_field_currency.
  ///
  /// In ja, this message translates to:
  /// **'通貨（JPY/CNY）'**
  String get analysis_confirm_field_currency;

  /// No description provided for @analysis_confirm_section_request.
  ///
  /// In ja, this message translates to:
  /// **'リクエスト（参考）'**
  String get analysis_confirm_section_request;

  /// No description provided for @analysis_confirm_saving.
  ///
  /// In ja, this message translates to:
  /// **'保存中...'**
  String get analysis_confirm_saving;

  /// No description provided for @analysis_confirm_save.
  ///
  /// In ja, this message translates to:
  /// **'問題なければ保存'**
  String get analysis_confirm_save;

  /// No description provided for @analysis_confirm_invalid_date.
  ///
  /// In ja, this message translates to:
  /// **'日付形式が正しくありません。YYYY-MM-DD を使用してください。'**
  String get analysis_confirm_invalid_date;

  /// No description provided for @analysis_confirm_untitled.
  ///
  /// In ja, this message translates to:
  /// **'無題'**
  String get analysis_confirm_untitled;

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
  /// **'完了：TODO'**
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
  /// **'スッと'**
  String get inboxTitle;

  /// No description provided for @inboxSubtitle.
  ///
  /// In ja, this message translates to:
  /// **'　気持ちが軽くなる'**
  String get inboxSubtitle;

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

  /// No description provided for @holdToTalkReleaseToStop.
  ///
  /// In ja, this message translates to:
  /// **'離して終了'**
  String get holdToTalkReleaseToStop;

  /// No description provided for @holdToTalkHoldToSpeak.
  ///
  /// In ja, this message translates to:
  /// **'長押しで話す'**
  String get holdToTalkHoldToSpeak;

  /// No description provided for @holdToTalkUnavailable.
  ///
  /// In ja, this message translates to:
  /// **'音声は利用できません'**
  String get holdToTalkUnavailable;

  /// No description provided for @riskPrefix.
  ///
  /// In ja, this message translates to:
  /// **'リスク '**
  String get riskPrefix;

  /// No description provided for @riskHigh.
  ///
  /// In ja, this message translates to:
  /// **'高'**
  String get riskHigh;

  /// No description provided for @riskMid.
  ///
  /// In ja, this message translates to:
  /// **'中'**
  String get riskMid;

  /// No description provided for @riskLow.
  ///
  /// In ja, this message translates to:
  /// **'低'**
  String get riskLow;

  /// No description provided for @importTypeAll.
  ///
  /// In ja, this message translates to:
  /// **'すべて'**
  String get importTypeAll;

  /// No description provided for @importTypeScreenshots.
  ///
  /// In ja, this message translates to:
  /// **'スクショ'**
  String get importTypeScreenshots;

  /// No description provided for @importTypePhotos.
  ///
  /// In ja, this message translates to:
  /// **'写真'**
  String get importTypePhotos;

  /// No description provided for @actionPageTitle.
  ///
  /// In ja, this message translates to:
  /// **'アクション：{actionType}'**
  String actionPageTitle(String actionType);

  /// No description provided for @actionTypeLabel.
  ///
  /// In ja, this message translates to:
  /// **'アクション種別：{actionType}'**
  String actionTypeLabel(String actionType);

  /// No description provided for @actionItemIdLabel.
  ///
  /// In ja, this message translates to:
  /// **'項目ID：{itemId}'**
  String actionItemIdLabel(String itemId);

  /// No description provided for @actionTodoDynamicRender.
  ///
  /// In ja, this message translates to:
  /// **'TODO：ここは actionType に応じて動的に描画'**
  String get actionTodoDynamicRender;

  /// No description provided for @actionConfirmTodo.
  ///
  /// In ja, this message translates to:
  /// **'確認（TODO：端末のカレンダー呼び出し／テンプレ複製／外部リンク遷移）'**
  String get actionConfirmTodo;

  /// No description provided for @error_loading.
  ///
  /// In ja, this message translates to:
  /// **'読み込みに失敗しました:{error}'**
  String error_loading(String error);

  /// No description provided for @setting_title.
  ///
  /// In ja, this message translates to:
  /// **'設定'**
  String get setting_title;

  /// No description provided for @setting_not_logged_in.
  ///
  /// In ja, this message translates to:
  /// **'未ログイン'**
  String get setting_not_logged_in;

  /// No description provided for @setting_cloud_title.
  ///
  /// In ja, this message translates to:
  /// **'クラウド保存（有料）'**
  String get setting_cloud_title;

  /// No description provided for @setting_cloud_on.
  ///
  /// In ja, this message translates to:
  /// **'クラウド保存をオンにしました（サーバーに同期します）。'**
  String get setting_cloud_on;

  /// No description provided for @setting_cloud_off.
  ///
  /// In ja, this message translates to:
  /// **'クラウド保存をオフにしました（端末内のみに保存されます）。'**
  String get setting_cloud_off;

  /// No description provided for @setting_cloud_sub_success.
  ///
  /// In ja, this message translates to:
  /// **'購読に成功しました。クラウド保存をオンにしました。'**
  String get setting_cloud_sub_success;

  /// No description provided for @setting_cloud_status_subscribed.
  ///
  /// In ja, this message translates to:
  /// **'購読中'**
  String get setting_cloud_status_subscribed;

  /// No description provided for @setting_cloud_status_unsubscribed.
  ///
  /// In ja, this message translates to:
  /// **'未購読'**
  String get setting_cloud_status_unsubscribed;

  /// No description provided for @setting_cloud_desc_on.
  ///
  /// In ja, this message translates to:
  /// **'オン：保存確定時にクラウドAPIを呼び出します（{status}）。'**
  String setting_cloud_desc_on(Object status);

  /// No description provided for @setting_cloud_desc_off.
  ///
  /// In ja, this message translates to:
  /// **'初期設定はオフ：データは端末内のみに保存されます（{status}）。'**
  String setting_cloud_desc_off(Object status);

  /// No description provided for @setting_debug_reset_sub.
  ///
  /// In ja, this message translates to:
  /// **'DEBUG：購読状態を未購読にリセット'**
  String get setting_debug_reset_sub;

  /// No description provided for @setting_debug_reset_done.
  ///
  /// In ja, this message translates to:
  /// **'未購読にリセットしました（DEBUG）'**
  String get setting_debug_reset_done;

  /// No description provided for @setting_privacy_saved_demo.
  ///
  /// In ja, this message translates to:
  /// **'保存しました（サンプル：後ほど永続化に対応予定）。'**
  String get setting_privacy_saved_demo;

  /// No description provided for @setting_cache_todo.
  ///
  /// In ja, this message translates to:
  /// **'TODO：キャッシュ設定ページ。'**
  String get setting_cache_todo;

  /// No description provided for @setting_clear_confirm_title.
  ///
  /// In ja, this message translates to:
  /// **'クリアしますか？'**
  String get setting_clear_confirm_title;

  /// No description provided for @setting_clear_confirm_desc.
  ///
  /// In ja, this message translates to:
  /// **'端末内のキャッシュデータを削除します（サンプル表示）。'**
  String get setting_clear_confirm_desc;

  /// No description provided for @setting_clear_ok.
  ///
  /// In ja, this message translates to:
  /// **'クリア'**
  String get setting_clear_ok;

  /// No description provided for @setting_clear_done.
  ///
  /// In ja, this message translates to:
  /// **'クリアしました（サンプル：後ほど実装予定）。'**
  String get setting_clear_done;

  /// No description provided for @setting_group.
  ///
  /// In ja, this message translates to:
  /// **'グループの管理（有料）'**
  String get setting_group;

  /// No description provided for @input_valid_mail_must.
  ///
  /// In ja, this message translates to:
  /// **'メールを入力してください'**
  String get input_valid_mail_must;

  /// No description provided for @input_valid_mail_format.
  ///
  /// In ja, this message translates to:
  /// **'正しいメールアドレスを入力してください'**
  String get input_valid_mail_format;

  /// No description provided for @input_valid_pwd_must.
  ///
  /// In ja, this message translates to:
  /// **'パスワードを入力してください'**
  String get input_valid_pwd_must;

  /// No description provided for @input_valid_comfirm_pwd.
  ///
  /// In ja, this message translates to:
  /// **'確認用パスワードを入力してください'**
  String get input_valid_comfirm_pwd;

  /// No description provided for @register_with_mail.
  ///
  /// In ja, this message translates to:
  /// **'Eメールで登録'**
  String get register_with_mail;

  /// No description provided for @badRequest.
  ///
  /// In ja, this message translates to:
  /// **'リクエスト内容が正しくありません'**
  String get badRequest;

  /// No description provided for @unauthorized.
  ///
  /// In ja, this message translates to:
  /// **'メールアドレスまたはパスワードが正しくありません'**
  String get unauthorized;

  /// No description provided for @forbidden.
  ///
  /// In ja, this message translates to:
  /// **'この操作を行う権限がありません'**
  String get forbidden;

  /// No description provided for @notFound.
  ///
  /// In ja, this message translates to:
  /// **'データが見つかりません'**
  String get notFound;

  /// No description provided for @conflict.
  ///
  /// In ja, this message translates to:
  /// **'このメールアドレスは既に登録されています'**
  String get conflict;

  /// No description provided for @validationError.
  ///
  /// In ja, this message translates to:
  /// **'入力内容を確認してください（メール形式など）'**
  String get validationError;

  /// No description provided for @serverError.
  ///
  /// In ja, this message translates to:
  /// **'サーバーエラーが発生しました。しばらくしてから再試行してください'**
  String get serverError;

  /// No description provided for @unknown.
  ///
  /// In ja, this message translates to:
  /// **'不明なエラーが発生しました'**
  String get unknown;

  /// No description provided for @cloud_paywall_title.
  ///
  /// In ja, this message translates to:
  /// **'クラウド保存（有料）'**
  String get cloud_paywall_title;

  /// No description provided for @cloud_paywall_desc.
  ///
  /// In ja, this message translates to:
  /// **'クラウド保存を利用するには Pro プランへの登録が必要です（Mock）。'**
  String get cloud_paywall_desc;

  /// No description provided for @cloud_feature_backup.
  ///
  /// In ja, this message translates to:
  /// **'サーバー上のデータベースに保存'**
  String get cloud_feature_backup;

  /// No description provided for @cloud_feature_sync.
  ///
  /// In ja, this message translates to:
  /// **'複数端末で同期（今後対応）'**
  String get cloud_feature_sync;

  /// No description provided for @cloud_feature_offline.
  ///
  /// In ja, this message translates to:
  /// **'オフラインでも利用可能'**
  String get cloud_feature_offline;

  /// No description provided for @cloud_price_monthly.
  ///
  /// In ja, this message translates to:
  /// **'料金：月額 ¥300（Mock）'**
  String get cloud_price_monthly;

  /// No description provided for @subscription_restore.
  ///
  /// In ja, this message translates to:
  /// **'購入を復元'**
  String get subscription_restore;

  /// No description provided for @subscription_subscribe.
  ///
  /// In ja, this message translates to:
  /// **'登録して有効化'**
  String get subscription_subscribe;

  /// No description provided for @paywallTitle.
  ///
  /// In ja, this message translates to:
  /// **'プレミアム（有料）'**
  String get paywallTitle;

  /// No description provided for @paywallDesc.
  ///
  /// In ja, this message translates to:
  /// **'グループ管理・クラウド保存などの機能を利用するには\nプレミアム登録が必要です。'**
  String get paywallDesc;

  /// No description provided for @loadingText.
  ///
  /// In ja, this message translates to:
  /// **'読み込み中...'**
  String get loadingText;

  /// No description provided for @planMonthly.
  ///
  /// In ja, this message translates to:
  /// **'月額プラン'**
  String get planMonthly;

  /// No description provided for @planYearly.
  ///
  /// In ja, this message translates to:
  /// **'年額プラン'**
  String get planYearly;

  /// No description provided for @restorePurchase.
  ///
  /// In ja, this message translates to:
  /// **'購入を復元（Restore）'**
  String get restorePurchase;

  /// No description provided for @cancelGuideTitle.
  ///
  /// In ja, this message translates to:
  /// **'解約はApp Store / Google Playのサブスク管理から'**
  String get cancelGuideTitle;

  /// No description provided for @cancelGuideSubtitle.
  ///
  /// In ja, this message translates to:
  /// **'アプリ内では解約できません'**
  String get cancelGuideSubtitle;

  /// No description provided for @notNow.
  ///
  /// In ja, this message translates to:
  /// **'今はしない'**
  String get notNow;

  /// No description provided for @personalInfoTitle.
  ///
  /// In ja, this message translates to:
  /// **'個人情報'**
  String get personalInfoTitle;

  /// No description provided for @profileImage.
  ///
  /// In ja, this message translates to:
  /// **'プロフィール画像'**
  String get profileImage;

  /// No description provided for @nickname.
  ///
  /// In ja, this message translates to:
  /// **'ニックネーム'**
  String get nickname;

  /// No description provided for @joinGroupTitle.
  ///
  /// In ja, this message translates to:
  /// **'グループに入る'**
  String get joinGroupTitle;

  /// No description provided for @joinGroupHelp.
  ///
  /// In ja, this message translates to:
  /// **'グループのオーナーに連絡して招待を出してもらってください\n（グループの設定＞メンバーを追加）'**
  String get joinGroupHelp;

  /// No description provided for @joinGroupHint.
  ///
  /// In ja, this message translates to:
  /// **'招待コードを入力してください'**
  String get joinGroupHint;

  /// No description provided for @joinGroupCodeEmpty.
  ///
  /// In ja, this message translates to:
  /// **'招待コードを入力してください'**
  String get joinGroupCodeEmpty;

  /// No description provided for @joinGroupJoined.
  ///
  /// In ja, this message translates to:
  /// **'参加しました'**
  String get joinGroupJoined;

  /// No description provided for @groupCreateTitle.
  ///
  /// In ja, this message translates to:
  /// **'グループ作成'**
  String get groupCreateTitle;

  /// No description provided for @groupName.
  ///
  /// In ja, this message translates to:
  /// **'グループ名'**
  String get groupName;

  /// No description provided for @groupSettingsTitle.
  ///
  /// In ja, this message translates to:
  /// **'グループ設定'**
  String get groupSettingsTitle;

  /// No description provided for @groupMembers.
  ///
  /// In ja, this message translates to:
  /// **'グループメンバー'**
  String get groupMembers;

  /// No description provided for @groupOwnerLabel.
  ///
  /// In ja, this message translates to:
  /// **'グループの所有者'**
  String get groupOwnerLabel;

  /// No description provided for @groupMemberLabel.
  ///
  /// In ja, this message translates to:
  /// **'普通メンバー'**
  String get groupMemberLabel;

  /// No description provided for @ownerOnlyCanChange.
  ///
  /// In ja, this message translates to:
  /// **'オーナーのみ変更できます'**
  String get ownerOnlyCanChange;

  /// No description provided for @ownerOnlyCanAdd.
  ///
  /// In ja, this message translates to:
  /// **'オーナーのみ追加できます'**
  String get ownerOnlyCanAdd;

  /// No description provided for @ownerOnlyCanDelete.
  ///
  /// In ja, this message translates to:
  /// **'オーナーのみ削除できます'**
  String get ownerOnlyCanDelete;

  /// No description provided for @groupNameInputTitleCreate.
  ///
  /// In ja, this message translates to:
  /// **'グループ名を入力'**
  String get groupNameInputTitleCreate;

  /// No description provided for @groupNameInputTitleEdit.
  ///
  /// In ja, this message translates to:
  /// **'グループ名称'**
  String get groupNameInputTitleEdit;

  /// No description provided for @groupNameEmpty.
  ///
  /// In ja, this message translates to:
  /// **'グループ名を入力してください'**
  String get groupNameEmpty;

  /// No description provided for @groupCreated.
  ///
  /// In ja, this message translates to:
  /// **'グループを作成しました'**
  String get groupCreated;

  /// No description provided for @addMember.
  ///
  /// In ja, this message translates to:
  /// **'メンバーを追加'**
  String get addMember;

  /// No description provided for @inviteSmsNotImplemented.
  ///
  /// In ja, this message translates to:
  /// **'SMSで招待（未実装）'**
  String get inviteSmsNotImplemented;

  /// No description provided for @inviteEmailNotImplemented.
  ///
  /// In ja, this message translates to:
  /// **'メールで招待（未実装）'**
  String get inviteEmailNotImplemented;

  /// No description provided for @deleteGroupTitle.
  ///
  /// In ja, this message translates to:
  /// **'グループの削除'**
  String get deleteGroupTitle;

  /// No description provided for @noPermission.
  ///
  /// In ja, this message translates to:
  /// **'権限がありません'**
  String get noPermission;

  /// No description provided for @memberTransferOwner.
  ///
  /// In ja, this message translates to:
  /// **'オーナーに移管'**
  String get memberTransferOwner;

  /// No description provided for @memberRemove.
  ///
  /// In ja, this message translates to:
  /// **'メンバーを削除'**
  String get memberRemove;

  /// No description provided for @memberRemoved.
  ///
  /// In ja, this message translates to:
  /// **'削除しました'**
  String get memberRemoved;

  /// No description provided for @ownerTransferred.
  ///
  /// In ja, this message translates to:
  /// **'オーナーを移管しました'**
  String get ownerTransferred;

  /// No description provided for @deleteApiNotConnected.
  ///
  /// In ja, this message translates to:
  /// **'削除API未接続'**
  String get deleteApiNotConnected;

  /// No description provided for @swipeMarkDone.
  ///
  /// In ja, this message translates to:
  /// **'完了にする'**
  String get swipeMarkDone;

  /// No description provided for @swipeRestore.
  ///
  /// In ja, this message translates to:
  /// **'未完了に戻す'**
  String get swipeRestore;

  /// No description provided for @groupManage.
  ///
  /// In ja, this message translates to:
  /// **'グループ管理'**
  String get groupManage;

  /// No description provided for @nogroup.
  ///
  /// In ja, this message translates to:
  /// **'まだグループがありません'**
  String get nogroup;

  /// No description provided for @joinGroup.
  ///
  /// In ja, this message translates to:
  /// **'グループに入る'**
  String get joinGroup;

  /// No description provided for @inviteChooseMethodTitle.
  ///
  /// In ja, this message translates to:
  /// **'誘う方法を選択'**
  String get inviteChooseMethodTitle;

  /// No description provided for @inviteMethodAccount.
  ///
  /// In ja, this message translates to:
  /// **'アプリアカウント'**
  String get inviteMethodAccount;

  /// No description provided for @inviteMethodSms.
  ///
  /// In ja, this message translates to:
  /// **'SMS'**
  String get inviteMethodSms;

  /// No description provided for @inviteMethodEmail.
  ///
  /// In ja, this message translates to:
  /// **'電子メール'**
  String get inviteMethodEmail;

  /// No description provided for @inviteMethodCode.
  ///
  /// In ja, this message translates to:
  /// **'招待コード'**
  String get inviteMethodCode;

  /// No description provided for @inviteCodeCopied.
  ///
  /// In ja, this message translates to:
  /// **'招待コードをコピーしました'**
  String get inviteCodeCopied;

  /// No description provided for @account.
  ///
  /// In ja, this message translates to:
  /// **'アカウント'**
  String get account;

  /// No description provided for @inputAccount.
  ///
  /// In ja, this message translates to:
  /// **'アカウント番号を入力してください'**
  String get inputAccount;

  /// No description provided for @inputName.
  ///
  /// In ja, this message translates to:
  /// **'メンバーの名前を入力'**
  String get inputName;

  /// No description provided for @displayname.
  ///
  /// In ja, this message translates to:
  /// **'名前'**
  String get displayname;

  /// No description provided for @speechSavedToLocalInbox.
  ///
  /// In ja, this message translates to:
  /// **'ローカルInboxに保存しました'**
  String get speechSavedToLocalInbox;

  /// No description provided for @speechAnalyzeFailed.
  ///
  /// In ja, this message translates to:
  /// **'音声解析に失敗しました：{error}'**
  String speechAnalyzeFailed(Object error);

  /// No description provided for @speechMockTitle.
  ///
  /// In ja, this message translates to:
  /// **'音声テキスト（模擬）'**
  String get speechMockTitle;

  /// No description provided for @speechMockCustomInputLabel.
  ///
  /// In ja, this message translates to:
  /// **'カスタム入力（優先）'**
  String get speechMockCustomInputLabel;

  /// No description provided for @speechMockUseInput.
  ///
  /// In ja, this message translates to:
  /// **'入力を使用'**
  String get speechMockUseInput;

  /// No description provided for @speechParsing.
  ///
  /// In ja, this message translates to:
  /// **'解析中...'**
  String get speechParsing;

  /// No description provided for @speechMockTooltip.
  ///
  /// In ja, this message translates to:
  /// **'音声テキスト（模擬）'**
  String get speechMockTooltip;

  /// No description provided for @group_desc.
  ///
  /// In ja, this message translates to:
  /// **'グループ管理は有料機能です（未契約／グループ未作成のため「個人」に固定されています）'**
  String get group_desc;

  /// No description provided for @group.
  ///
  /// In ja, this message translates to:
  /// **'グループ'**
  String get group;

  /// No description provided for @personal.
  ///
  /// In ja, this message translates to:
  /// **'個人'**
  String get personal;

  /// No description provided for @holidayShort.
  ///
  /// In ja, this message translates to:
  /// **'祝'**
  String get holidayShort;

  /// No description provided for @holidayLabel.
  ///
  /// In ja, this message translates to:
  /// **'祝日'**
  String get holidayLabel;

  /// No description provided for @holidaysLoading.
  ///
  /// In ja, this message translates to:
  /// **'祝日を読み込み中…'**
  String get holidaysLoading;

  /// No description provided for @copied.
  ///
  /// In ja, this message translates to:
  /// **'コピーした'**
  String get copied;

  /// No description provided for @groupInviteMessage.
  ///
  /// In ja, this message translates to:
  /// **'スッとのグループに招待されています。以下の招待コードを使って参加できます。'**
  String get groupInviteMessage;

  /// No description provided for @inviteCodeLabel.
  ///
  /// In ja, this message translates to:
  /// **'招待コード'**
  String get inviteCodeLabel;

  /// No description provided for @groupInviteEmailSubject.
  ///
  /// In ja, this message translates to:
  /// **'スッと グループへの招待'**
  String get groupInviteEmailSubject;

  /// No description provided for @joinGroupFailed.
  ///
  /// In ja, this message translates to:
  /// **'招待コードが無効、または期限切れです。'**
  String get joinGroupFailed;
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
