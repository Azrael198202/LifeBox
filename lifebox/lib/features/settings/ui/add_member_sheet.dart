import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lifebox/core/widgets/invite_method_icon.dart';
import 'package:lifebox/l10n/app_localizations.dart';

class AddMemberResult {
  final String channel; // 'sms' | 'email' | 'copy' | 'invite_code'
  const AddMemberResult({required this.channel});
}

Future<AddMemberResult?> showAddMemberSheet(
  BuildContext context, {
  required String inviteCode,
}) async {
  return showModalBottomSheet<AddMemberResult>(
    context: context,
    isScrollControlled: false,
    showDragHandle: true,
    builder: (ctx) => _InviteMethodSheet(inviteCode: inviteCode),
  );
}

class _InviteMethodSheet extends StatelessWidget {
  const _InviteMethodSheet({required this.inviteCode});
  final String inviteCode;

  @override
  Widget build(BuildContext context) {
      final l10n = AppLocalizations.of(context);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.inviteChooseMethodTitle,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),

            // 4 icons row
            Wrap(
              spacing: 18,
              runSpacing: 12,
              alignment: WrapAlignment.center,
              children: [
                InviteMethodIcon(
                  leading: Image.asset(
                    'assets/icon/white.png',
                    width: 32,
                    height: 32,
                    fit: BoxFit.contain,
                  ),
                  label: l10n.inviteMethodAccount,
                  onTap: () {
                    Navigator.pop(
                        context, const AddMemberResult(channel: 'account'));
                  },
                ),
                InviteMethodIcon(
                  icon: Icons.sms_outlined,
                  label: 'SMS',
                  onTap: () {
                    Navigator.pop(
                        context, const AddMemberResult(channel: 'sms'));
                  },
                ),
                InviteMethodIcon(
                  icon: Icons.mail_outline,
                  label: l10n.inviteMethodEmail,
                  onTap: () {
                    Navigator.pop(
                        context, const AddMemberResult(channel: 'email'));
                  },
                ),
                InviteMethodIcon(
                  icon: Icons.copy_outlined,
                  label: l10n.inviteMethodCode,
                  onTap: () async {
                    await Clipboard.setData(ClipboardData(text: inviteCode));
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l10n.inviteCodeCopied)),
                    );
                    Navigator.pop(
                        context, const AddMemberResult(channel: 'copy'));
                  },
                ),
              ],
            ),

            const SizedBox(height: 12),
            const Divider(height: 1),

            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(l10n.cancel),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
