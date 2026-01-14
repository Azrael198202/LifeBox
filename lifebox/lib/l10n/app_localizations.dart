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
