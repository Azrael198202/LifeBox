// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get settings_title => 'Settings';

  @override
  String get language_title => 'Language';

  @override
  String get language_subtitle => 'Change display language';

  @override
  String get upload_policy_title => 'Upload OCR text only (default ON)';

  @override
  String get upload_policy_subtitle =>
      'Privacy-first: images are not uploaded (configurable later)';

  @override
  String get app_lock_title => 'Enable App Lock (recommended)';

  @override
  String get app_lock_subtitle =>
      'Require unlock when returning from background (Face/Touch later)';

  @override
  String get cache_title => 'Local Cache';

  @override
  String get cache_subtitle => 'Keep 7 days / 30 days / Forever (TODO)';

  @override
  String get clear_data_title => 'Clear Data';

  @override
  String get clear_data_subtitle => 'Clear local / clear cloud (API reserved)';

  @override
  String get clear_QA => 'ローカル削除 / クラウド削除（API予約）';

  @override
  String get clear_content => 'ローカル削除 / クラウド削除（API予約）';

  @override
  String get clear_OK => '削除';

  @override
  String get logout_title => 'Log out';

  @override
  String get logout_QA => 'Are you sure you want to log out?';

  @override
  String get logout_OK => 'Log out';

  @override
  String get not_logged_in => 'Not signed in';

  @override
  String get common_Cancel => 'Cancel';

  @override
  String get version_text => 'Life Inbox • v0.1.0 (MVP)';

  @override
  String get app_name => 'Life Inbox';

  @override
  String get terms_agree_prefix => 'By continuing, you agree to';

  @override
  String get open_terms_action => 'TODO: Open Terms of Service';

  @override
  String get terms_title => 'Terms of Service';

  @override
  String get terms_and => ' and ';

  @override
  String get open_privacy_action => 'TODO: Open Privacy Policy';

  @override
  String get privacy_title => 'Privacy Policy';

  @override
  String get common_mail => 'Mail';

  @override
  String get common_mail_hit => 'example@email.com';

  @override
  String get common_password => 'Password';

  @override
  String get common_or => 'or';

  @override
  String get common_password_hit => 'Please enter your password';

  @override
  String get login_title => 'Welcome back';

  @override
  String get login_subtitle =>
      'Sign in to import screenshots, automatically detect tasks and risks, and protect your privacy with an app lock.';

  @override
  String get login_logining => 'Signing in...';

  @override
  String get login_with_mail => 'Sign in with email';

  @override
  String get login_with_google => 'Sign in with Google (placeholder)';

  @override
  String get login_to_register => 'Don\'t have an account? Sign up';

  @override
  String get login_hit =>
      'Tip: After signing in, you can enable App Lock in Settings (Face ID / Fingerprint / System authentication).';

  @override
  String get register_title => 'Create an account';

  @override
  String get register_subtitle =>
      'Sign up with email. You can link Google/Apple later and enable App Lock for extra security.';

  @override
  String get register_password_hint => 'At least 8 characters';

  @override
  String get register_password_confirm_label => 'Confirm password';

  @override
  String get register_password_confirm_hint => 'Enter your password again';

  @override
  String get register_password_mismatch => 'Passwords do not match';

  @override
  String get register_button_loading => 'Signing up...';

  @override
  String get register_button_email => 'Sign up with email';

  @override
  String get register_back_to_login => 'Back to sign in';

  @override
  String get register_hint_success =>
      'After signing up, you\'ll be taken to your inbox automatically.';

  @override
  String get register_error_email_invalid =>
      'Please enter a valid email address';

  @override
  String get register_error_password_too_short =>
      'Password must be at least 8 characters';
}
