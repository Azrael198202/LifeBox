import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lifebox/l10n/app_localizations.dart';

import '../state/auth_controller.dart';
import 'auth_widgets.dart';

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final _email = TextEditingController();
  final _pwd = TextEditingController();
  final _pwd2 = TextEditingController();

  bool _obscure1 = true;
  bool _obscure2 = true;

  @override
  void dispose() {
    _email.dispose();
    _pwd.dispose();
    _pwd2.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authControllerProvider);
    final l10n = AppLocalizations.of(context);

    final pwdNotMatch = _pwd.text.isNotEmpty &&
        _pwd2.text.isNotEmpty &&
        _pwd.text != _pwd2.text;

    return AuthLayout(
      title: l10n.register_title,
      subtitle: l10n.register_subtitle,
      logo: Image.asset('assets/images/logo.png', height: 34),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AuthTextField(
            controller: _email,
            label: l10n.common_mail,
            hint: l10n.common_mail_hit,
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 14),
          AuthTextField(
            controller: _pwd,
            label: l10n.common_password,
            hint: l10n.register_password_hint,
            icon: Icons.lock_outline,
            obscureText: _obscure1,
            suffix: IconButton(
              onPressed: () => setState(() => _obscure1 = !_obscure1),
              icon: Icon(
                _obscure1 ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                color: const Color(0xFF6B7280),
              ),
            ),
          ),
          const SizedBox(height: 14),
          AuthTextField(
            controller: _pwd2,
            label: l10n.register_password_confirm_label,
            hint: l10n.register_password_confirm_hint,
            icon: Icons.lock_outline,
            obscureText: _obscure2,
            suffix: IconButton(
              onPressed: () => setState(() => _obscure2 = !_obscure2),
              icon: Icon(
                _obscure2 ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                color: const Color(0xFF6B7280),
              ),
            ),
          ),
          const SizedBox(height: 12),

          if (pwdNotMatch) ...[
            Text(l10n.register_password_mismatch, style: TextStyle(color: Colors.red)),
            const SizedBox(height: 8),
          ],

          if (auth.error != null) ...[
            Text(auth.error!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 10),
          ],

          AuthPrimaryButton(
            label: auth.loading ? l10n.register_button_loading: l10n.register_button_email,
            onPressed: auth.loading
                ? null
                : () {
                    final email = _email.text.trim();
                    final p1 = _pwd.text;
                    final p2 = _pwd2.text;

                    if (email.isEmpty || !email.contains('@')) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(l10n.register_error_email_invalid)),
                      );
                      return;
                    }
                    if (p1.length < 8) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(l10n.register_error_password_too_short)),
                      );
                      return;
                    }
                    if (p1 != p2) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(l10n.register_password_mismatch)),
                      );
                      return;
                    }
                    ref.read(authControllerProvider.notifier).register(email, p1);
                  },
          ),

          const SizedBox(height: 10),
          AuthSecondaryButton(
            label: l10n.register_back_to_login,
            icon: Icons.arrow_back,
            onPressed: () => context.pop(),
          ),

          const SizedBox(height: 10),
          AuthHintText(l10n.register_hint_success),
        ],
      ),
    );
  }
}
