import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lifebox/l10n/app_localizations.dart';
import '../../../core/network/api_error_l10n.dart';

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
  final _formKey = GlobalKey<FormState>();
  bool _submitted = false;
  bool _obscure1 = true;
  bool _obscure2 = true;

  bool _isValidEmail(String s) {
    final email = s.trim();
    final re = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    return re.hasMatch(email);
  }

  void _submitRegister() {
    setState(() => _submitted = true);
    final ok = _formKey.currentState?.validate() ?? false;
    if (!ok) return;

    ref.read(authControllerProvider.notifier).registerWithEmail(
          _email.text.trim(),
          _pwd.text,
        );
  }

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
            autovalidateMode: _submitted
                ? AutovalidateMode.onUserInteraction
                : AutovalidateMode.disabled,
            validator: (v) {
              final s = (v ?? '').trim();
              if (s.isEmpty) return l10n.input_valid_mail_must;
              if (!_isValidEmail(s)) return l10n.register_error_email_invalid;
              return null;
            },
          ),
          const SizedBox(height: 14),
          AuthTextField(
            controller: _pwd,
            label: l10n.common_password,
            hint: l10n.register_password_hint,
            icon: Icons.lock_outline,
            obscureText: _obscure1,
            autovalidateMode: _submitted
                ? AutovalidateMode.onUserInteraction
                : AutovalidateMode.disabled,
            validator: (v) {
              final s = (v ?? '');
              if (s.isEmpty) return l10n.input_valid_mail_must;
              if (s.length < 8) return l10n.register_error_password_too_short;
              return null;
            },
            suffix: IconButton(
              onPressed: () => setState(() => _obscure1 = !_obscure1),
              icon: Icon(
                _obscure1
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
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
            autovalidateMode: _submitted
                ? AutovalidateMode.onUserInteraction
                : AutovalidateMode.disabled,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _submitRegister(),
            validator: (v) {
              final s = (v ?? '');
              if (s.isEmpty) return l10n.input_valid_comfirm_pwd;
              if (s != _pwd.text) return l10n.register_password_mismatch;
              return null;
            },
            suffix: IconButton(
              onPressed: () => setState(() => _obscure2 = !_obscure2),
              icon: Icon(
                _obscure2
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: const Color(0xFF6B7280),
              ),
            ),
          ),
          const SizedBox(height: 12),
          if (pwdNotMatch) ...[
            Text(l10n.register_password_mismatch,
                style: TextStyle(color: Colors.red)),
            const SizedBox(height: 8),
          ],

          if (auth.errorKey != null) ...[
              Text(
                auth.errorKey!.message(l10n),
                style: const TextStyle(color: Colors.red),
              ),
              const SizedBox(height: 10),
            ],
          AuthPrimaryButton(
            label: auth.loading ? l10n.loading_more : l10n.register_button_email,
            onPressed: auth.loading ? null : _submitRegister,
          ),
          const SizedBox(height: 10),
          Row(
            children: const [
              Expanded(child: Divider()),
              Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Text('or')),
              Expanded(child: Divider()),
            ],
          ),
          const SizedBox(height: 16),
          // ✅ Google 注册（后端自动注册/登录）
          AuthSecondaryButton(
            label: 'Continue with Google',
            icon: Icons.g_mobiledata,
            onPressed: auth.loading
                ? null
                : () =>
                    ref.read(authControllerProvider.notifier).loginWithGoogle(),
          ),
          const SizedBox(height: 10),
          AuthHintText(l10n.register_hint_success),
        ],
      ),
    );
  }
}
