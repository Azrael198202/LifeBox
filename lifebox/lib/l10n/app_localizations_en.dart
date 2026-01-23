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
  String get language_jp => 'Japanese';

  @override
  String get language_zh => 'Chinese';

  @override
  String get language_en => 'English';

  @override
  String get clear => 'Clear';

  @override
  String get delete => 'Delete';

  @override
  String get cancel => 'Delete';

  @override
  String get save => 'Save';

  @override
  String get finish => 'Finish';

  @override
  String get select => 'Select';

  @override
  String get colorBlueGrey => 'Blue grey';

  @override
  String get colorBlue => 'Blue';

  @override
  String get colorGreen => 'Green';

  @override
  String get colorOrange => 'Orange';

  @override
  String get colorPink => 'Pink';

  @override
  String get colorPurple => 'Purple';

  @override
  String get colorRed => 'Red';

  @override
  String get colorGeneric => 'Color';

  @override
  String get colorTitle => 'Color(Calendar)';

  @override
  String get deleteConfirm => 'Are you sure you want to delete it?';

  @override
  String get deleteConfirmTitle => 'Delete Confirm';

  @override
  String get continueText => 'Continue';

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
  String get clear_QA => 'Confirm clearing?';

  @override
  String get clear_content =>
      'This will clear locally cached data (sample placeholder).';

  @override
  String get logout_title => 'Log out';

  @override
  String get logout_QA => 'Are you sure you want to log out?';

  @override
  String get logout_OK => 'Log out';

  @override
  String get not_logged_in => 'Not signed in';

  @override
  String no_name(Object name) {
    return 'User $name';
  }

  @override
  String get no_title => '(No title)\' ';

  @override
  String get another => 'Other';

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
  String get type_label => 'Type';

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
  String get login_continue_google => 'Continue with Google';

  @override
  String get login_no_account => 'No account?';

  @override
  String get login_to_register => 'Sign up';

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

  @override
  String get all_Time => 'Any time';

  @override
  String get import_title => 'Import';

  @override
  String get import_title_full => 'Import (Filters + Queue)';

  @override
  String get import_perm_title => 'Photo permission not granted';

  @override
  String get import_perm_subtitle_ios =>
      'Go to iOS Settings → Privacy & Security → Photos and allow access.';

  @override
  String get import_perm_retry => 'Request permission again';

  @override
  String get refresh => 'Refresh';

  @override
  String get import_range_unlimited => 'Any time';

  @override
  String get import_filter_range_label => 'Date range';

  @override
  String get import_filter_clear_range => 'Clear range';

  @override
  String get import_screenshots_not_found =>
      'No “Screenshots” album detected. Screenshot filtering will fall back to all photos.';

  @override
  String import_screenshots_album_prefix(Object count) {
    return 'Screenshots album:  $count';
  }

  @override
  String import_selected_count(Object count) {
    return '$count selected';
  }

  @override
  String get import_select_all_visible => 'All';

  @override
  String get import_clear_selection => 'Clear selection';

  @override
  String import_queue_label(Object count) {
    return 'Queue $count';
  }

  @override
  String get import_empty_title => 'No photos match your filters';

  @override
  String get import_empty_subtitle =>
      'Try changing the date range or type filter.';

  @override
  String get loading_more => 'Loading…';

  @override
  String get import_enqueue_button => 'Add to processing queue';

  @override
  String import_enqueue_button_with_count(Object count) {
    return 'Add to processing queue ($count)';
  }

  @override
  String get ocr_queue_title => 'OCR Queue';

  @override
  String get ocr_queue_clear => 'Clear queue';

  @override
  String ocr_results_button(Object count) {
    return 'Results ($count)';
  }

  @override
  String ocr_processing_prefix(Object count) {
    return 'Processing: ';
  }

  @override
  String get ocr_no_current => 'No task is currently running';

  @override
  String ocr_queued_prefix(Object count) {
    return 'Queued: $count';
  }

  @override
  String get ocr_queue_empty => 'Queue is empty';

  @override
  String ocrResultsTitle(int count) {
    return 'OCR Results ($count)';
  }

  @override
  String get selectAll => 'Select all';

  @override
  String get clearSelection => 'Clear';

  @override
  String get clearResultsTooltip => 'Clear results';

  @override
  String get confirmButtonPleaseSelect => 'Please select a card';

  @override
  String confirmButtonSelectedCount(int count) {
    return 'Confirm ($count)';
  }

  @override
  String get analysis_confirm_title => 'Confirm & Save';

  @override
  String get analysis_confirm_section_editable => 'Parsed Result (Editable)';

  @override
  String get analysis_confirm_field_title => 'Title';

  @override
  String get analysis_confirm_field_summary => 'Content / Summary';

  @override
  String get analysis_confirm_field_due => 'Due date (YYYYMMDD)';

  @override
  String get analysis_confirm_field_risk => 'Risk';

  @override
  String get analysis_confirm_field_amount => 'Amount';

  @override
  String get analysis_confirm_field_currency => 'Currency (JPY/CNY)';

  @override
  String get analysis_confirm_section_request => 'Request (Reference)';

  @override
  String get analysis_confirm_saving => 'Saving...';

  @override
  String get analysis_confirm_save => 'Looks good, save';

  @override
  String get analysis_confirm_invalid_date =>
      'Invalid date format. Please use YYYY-MM-DD.';

  @override
  String get analysis_confirm_untitled => 'Untitled';

  @override
  String get emptyOcrResults => 'No OCR results yet';

  @override
  String get ocrStatusSuccess => 'Success';

  @override
  String get ocrStatusFailed => 'Failed';

  @override
  String get ocrStatusRunning => 'Processing';

  @override
  String get ocrStatusQueued => 'Queued';

  @override
  String get ocrFailedDefaultError => 'Recognition failed';

  @override
  String get noTextPlaceholder => '(No text)';

  @override
  String get ocrFullTextTitle => 'Full OCR Text';

  @override
  String get close => 'Close';

  @override
  String get viewFullText => 'View full text';

  @override
  String get calendarTitle => 'Calendar';

  @override
  String get pickYearMonthTitle => 'Select year & month';

  @override
  String get yearLabel => 'Year';

  @override
  String get monthLabel => 'Month';

  @override
  String get confirm => 'Confirm';

  @override
  String get speechSheetTitle => 'Speech recognition text';

  @override
  String get speechHintEditable =>
      'The recognized text will appear here and can be edited.';

  @override
  String get goImport => 'Go to import';

  @override
  String receivedSnack(String text) {
    return 'Received: $text';
  }

  @override
  String get confirmAction => 'Confirm';

  @override
  String get weekdaySun => 'Sun';

  @override
  String get weekdayMon => 'Mon';

  @override
  String get weekdayTue => 'Tue';

  @override
  String get weekdayWed => 'Wed';

  @override
  String get weekdayThu => 'Thu';

  @override
  String get weekdayFri => 'Fri';

  @override
  String get weekdaySat => 'Sat';

  @override
  String dayItemsTitle(String date) {
    return 'Items for the day: $date';
  }

  @override
  String get noDueItemsForDay =>
      'There are no items with a due date on this day.';

  @override
  String get setDueHint => 'Tip: Set a due date to show items on the calendar.';

  @override
  String get noDueDate => 'No due date';

  @override
  String duePrefix(String due) {
    return 'Due: $due';
  }

  @override
  String get nextStep => 'Next';

  @override
  String get inboxDetailTitle => 'Details';

  @override
  String inboxDetailSource(String source) {
    return 'Source: $source';
  }

  @override
  String get inboxDetailThumbnailPlaceholder =>
      '(Thumbnail/source image will go here in the future)';

  @override
  String get inboxDetailStructuredFields => 'Structured fields';

  @override
  String get inboxDetailDueTodo => 'Due date: TODO';

  @override
  String get inboxDetailAmountTodo => 'Amount: TODO';

  @override
  String get inboxDetailPhoneUrlTodo => 'Phone/URL: TODO';

  @override
  String get inboxDetailPrimaryActionAddCalendar =>
      'Primary action: Add to calendar';

  @override
  String get inboxDetailMarkDoneTodo => 'Done：TODO';

  @override
  String get inboxDetailEvidenceTitle => 'Evidence (OCR snippets)';

  @override
  String get inboxDetailOcrPlaceholder =>
      'OCR: ... (Later, this will show local OCR cache content)';

  @override
  String get inboxTitle => 'Life Inbox';

  @override
  String get inboxEmptyTitle => 'Nothing here yet';

  @override
  String get inboxEmptySubtitle =>
      'Import screenshots or hold the mic button to start';

  @override
  String get tooltipCalendarView => 'Calendar view';

  @override
  String get tooltipImport => 'Import';

  @override
  String get tooltipSettings => 'Settings';

  @override
  String tabHigh(int count) {
    return 'High priority ($count)';
  }

  @override
  String tabPending(int count) {
    return 'To do ($count)';
  }

  @override
  String tabDone(int count) {
    return 'Done ($count)';
  }

  @override
  String get speechBarHintHoldToTalk =>
      'Hold to speak. Release when done to generate text.';

  @override
  String speechBarRecentPrefix(String text) {
    return 'Recent: $text';
  }

  @override
  String get lockPageTitle => 'App locked';

  @override
  String get lockPageNeedUnlock => 'Unlock to continue';

  @override
  String get unlock => 'Unlock';

  @override
  String unlockReturnTo(String target) {
    return 'After unlocking, you will return to: $target';
  }

  @override
  String get holdToTalkReleaseToStop => 'Release to stop';

  @override
  String get holdToTalkHoldToSpeak => 'Hold to speak';

  @override
  String get holdToTalkUnavailable => 'Voice unavailable';

  @override
  String get riskPrefix => 'Risk ';

  @override
  String get riskHigh => 'High';

  @override
  String get riskMid => 'Medium';

  @override
  String get riskLow => 'Low';

  @override
  String get importTypeAll => 'All';

  @override
  String get importTypeScreenshots => 'Screenshots';

  @override
  String get importTypePhotos => 'Photos';

  @override
  String actionPageTitle(String actionType) {
    return 'Action: $actionType';
  }

  @override
  String actionTypeLabel(String actionType) {
    return 'Action type: $actionType';
  }

  @override
  String actionItemIdLabel(String itemId) {
    return 'Item ID: $itemId';
  }

  @override
  String get actionTodoDynamicRender =>
      'TODO: Render dynamically based on actionType';

  @override
  String get actionConfirmTodo =>
      'Confirm (TODO: open native calendar / copy template / open external link)';

  @override
  String error_loading(String error) {
    return 'Failed to load:$error';
  }

  @override
  String get setting_title => 'Settings';

  @override
  String get setting_not_logged_in => 'Not logged in';

  @override
  String get setting_cloud_title => 'Cloud Backup (Paid)';

  @override
  String get setting_cloud_on =>
      'Cloud backup is on (will sync to the server).';

  @override
  String get setting_cloud_off =>
      'Cloud backup is off (saved on this device only).';

  @override
  String get setting_cloud_sub_success =>
      'Subscription successful. Cloud backup is now on.';

  @override
  String get setting_cloud_status_subscribed => 'Subscribed';

  @override
  String get setting_cloud_status_unsubscribed => 'Not subscribed';

  @override
  String setting_cloud_desc_on(Object status) {
    return 'On: The app will call the cloud API when saving ($status).';
  }

  @override
  String setting_cloud_desc_off(Object status) {
    return 'Off by default: Data is saved on this device only ($status).';
  }

  @override
  String get setting_debug_reset_sub =>
      'DEBUG: Reset subscription to not subscribed';

  @override
  String get setting_debug_reset_done => 'Reset to not subscribed (DEBUG)';

  @override
  String get setting_privacy_saved_demo =>
      'Saved (demo: persistence will be added later).';

  @override
  String get setting_cache_todo => 'TODO: Cache settings page.';

  @override
  String get setting_clear_confirm_title => 'Clear data?';

  @override
  String get setting_clear_confirm_desc =>
      'This will clear local cached data (demo placeholder).';

  @override
  String get setting_clear_ok => 'Clear';

  @override
  String get setting_clear_done =>
      'Cleared (demo: real cleanup will be added later).';

  @override
  String get setting_group => 'Group & Share(Paid)';

  @override
  String get input_valid_mail_must => 'Please enter the email address';

  @override
  String get input_valid_mail_format => 'Please enter a valid email address';

  @override
  String get input_valid_pwd_must => 'Please enter the password';

  @override
  String get input_valid_comfirm_pwd => 'Please enter the confirm password';

  @override
  String get register_with_mail => 'Register with Email';

  @override
  String get badRequest => 'Invalid request';

  @override
  String get unauthorized => 'Invalid email or password';

  @override
  String get forbidden => 'You do not have permission to perform this action';

  @override
  String get notFound => 'Resource not found';

  @override
  String get conflict => 'This email is already registered';

  @override
  String get validationError => 'Please check your input (e.g. email format)';

  @override
  String get serverError => 'Server error occurred. Please try again later';

  @override
  String get unknown => 'An unknown error occurred';

  @override
  String get cloud_paywall_title => 'Cloud Backup (Paid)';

  @override
  String get cloud_paywall_desc =>
      'A Pro subscription is required to enable cloud backup (Mock).';

  @override
  String get cloud_feature_backup => 'Back up data to the server database';

  @override
  String get cloud_feature_sync => 'Sync across multiple devices (coming soon)';

  @override
  String get cloud_feature_offline => 'Offline access on this device';

  @override
  String get cloud_price_monthly => 'Price: ¥300 / month (Mock)';

  @override
  String get subscription_restore => 'Restore Purchase';

  @override
  String get subscription_subscribe => 'Subscribe & Enable';

  @override
  String get paywallTitle => 'Premium (Paid)';

  @override
  String get paywallDesc =>
      'To use features like group management and cloud backup,\nPremium subscription is required.';

  @override
  String get loadingText => 'Loading...';

  @override
  String get planMonthly => 'Monthly plan';

  @override
  String get planYearly => 'Yearly plan';

  @override
  String get restorePurchase => 'Restore purchase';

  @override
  String get cancelGuideTitle =>
      'Manage cancellations in App Store / Google Play subscriptions';

  @override
  String get cancelGuideSubtitle => 'You can’t cancel inside the app';

  @override
  String get notNow => 'Not now';

  @override
  String get personalInfoTitle => 'Personal info';

  @override
  String get profileImage => 'Profile photo';

  @override
  String get nickname => 'Nickname';

  @override
  String get joinGroupTitle => 'Join a group';

  @override
  String get joinGroupHelp =>
      'Contact the group owner to send you an invitation\n(Group settings > Add members)';

  @override
  String get joinGroupHint => 'Enter invitation code';

  @override
  String get joinGroupCodeEmpty => 'Please enter an invitation code';

  @override
  String get joinGroupJoined => 'Joined';

  @override
  String get groupCreateTitle => 'Create group';

  @override
  String get groupSettingsTitle => 'Group settings';

  @override
  String get groupMembers => 'Group members';

  @override
  String get groupOwnerLabel => 'Owner';

  @override
  String get groupMemberLabel => 'Member';

  @override
  String get ownerOnlyCanChange => 'Only the owner can change this';

  @override
  String get ownerOnlyCanAdd => 'Only the owner can add members';

  @override
  String get ownerOnlyCanDelete => 'Only the owner can delete the group';

  @override
  String get groupNameInputTitleCreate => 'Enter group name';

  @override
  String get groupNameInputTitleEdit => 'Group name';

  @override
  String get groupNameEmpty => 'Please enter a group name';

  @override
  String get groupCreated => 'Group created';

  @override
  String get addMember => 'Add member';

  @override
  String get inviteSmsNotImplemented => 'Invite via SMS (not implemented)';

  @override
  String get inviteEmailNotImplemented => 'Invite via email (not implemented)';

  @override
  String get deleteGroupTitle => 'Delete group';

  @override
  String get noPermission => 'No permission';

  @override
  String get memberTransferOwner => 'Transfer ownership';

  @override
  String get memberRemove => 'Remove member';

  @override
  String get memberRemoved => 'Removed';

  @override
  String get ownerTransferred => 'Ownership transferred';

  @override
  String get deleteApiNotConnected => 'Delete API not connected';

  @override
  String get swipeMarkDone => 'Mark done';

  @override
  String get swipeRestore => 'Restore';

  @override
  String get groupManage => 'Group & Share';

  @override
  String get nogroup => 'No group yet';

  @override
  String get joinGroup => 'Join a group';

  @override
  String get inviteChooseMethodTitle => 'Choose an invite method';

  @override
  String get inviteMethodAccount => 'App account';

  @override
  String get inviteMethodSms => 'SMS';

  @override
  String get inviteMethodEmail => 'Email';

  @override
  String get inviteMethodCode => 'Invite code';

  @override
  String get inviteCodeCopied => 'Invite code copied';

  @override
  String get account => 'Account';

  @override
  String get inputAccount => 'Enter account email';

  @override
  String get inputName => 'Enter member display name';

  @override
  String get displayname => 'Display name';

  @override
  String get speechSavedToLocalInbox => 'Saved to local Inbox';

  @override
  String speechAnalyzeFailed(Object error) {
    return 'Speech analysis failed: $error';
  }

  @override
  String get speechMockTitle => 'Mock speech text';

  @override
  String get speechMockCustomInputLabel => 'Custom input (preferred)';

  @override
  String get speechMockUseInput => 'Use input';

  @override
  String get speechParsing => 'Parsing...';

  @override
  String get speechMockTooltip => 'Mock speech text';

  @override
  String get group_desc =>
      'Group management is a paid feature (not subscribed or no group created, so it is fixed to Personal).';

  @override
  String get group => 'Group';

  @override
  String get personal => 'Personal';

  @override
  String get holidayShort => 'H';

  @override
  String get holidayLabel => 'Holiday';

  @override
  String get holidaysLoading => 'Loading holidays…';
}
