import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'package:lifebox/l10n/app_localizations.dart';

/// =============================
/// Invite Share Utils
/// =============================

String buildInviteText(
  AppLocalizations l10n,
  String inviteCode,
) {
  return '${l10n.groupInviteMessage}\n\n'
      '${l10n.inviteCodeLabel}: $inviteCode\n';
}

/// copy invite code to clipboard
Future<void> copyInviteCode(
  BuildContext context,
  String inviteCode,
) async {
  await Clipboard.setData(ClipboardData(text: inviteCode));
  if (!context.mounted) return;

  final l10n = AppLocalizations.of(context);
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(l10n.copied)),
  );
}

/// open email app (failure returns false)
Future<bool> launchInviteEmail({
  required String subject,
  required String body,
}) async {
  final uri = Uri(
    scheme: 'mailto',
    queryParameters: {
      'subject': subject,
      'body': body,
    },
  );

  return launchUrl(
    uri,
    mode: LaunchMode.externalApplication,
  );
}

/// open SMS app (failure returns false)
Future<bool> launchInviteSms(String body) async {
  final uri = Uri(
    scheme: 'sms',
    queryParameters: {
      'body': body,
    },
  );

  return launchUrl(
    uri,
    mode: LaunchMode.externalApplication,
  );
}

/// fallback share method
Future<void> shareInviteFallback({
  required String text,
  String? subject,
}) async {
  await Share.share(
    text,
    subject: subject,
  );
}