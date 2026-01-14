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
}
