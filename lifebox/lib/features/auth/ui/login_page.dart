import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../state/auth_controller.dart';
import 'auth_widgets.dart';
import 'package:lifebox/l10n/app_localizations.dart';
import '../../../core/network/api_error_l10n.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _email = TextEditingController();
  final _pwd = TextEditingController();
  bool _obscure = true;
  final _formKey = GlobalKey<FormState>();
  bool _submitted = false;

  bool _isValidEmail(String s) {
    final email = s.trim();
    final re = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    return re.hasMatch(email);
  }

  void _submitLogin() {
    setState(() => _submitted = true);
    final ok = _formKey.currentState?.validate() ?? false;
    if (!ok) return;

    ref.read(authControllerProvider.notifier).loginWithEmail(
          _email.text.trim(),
          _pwd.text,
        );
  }

  @override
  void dispose() {
    _email.dispose();
    _pwd.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authControllerProvider);
    final l10n = AppLocalizations.of(context);

    return AuthLayout(
      title: l10n.login_title,
      subtitle: l10n.login_subtitle,
      logo: Image.asset('assets/images/logo-b.png', height: 34),
      child: Form(
        key: _formKey,
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
                if (!_isValidEmail(s)) return l10n.input_valid_mail_format;
                return null;
              },
            ),
            const SizedBox(height: 14),
            AuthTextField(
              controller: _pwd,
              label: l10n.common_password,
              hint: l10n.common_password_hit,
              icon: Icons.lock_outline,
              obscureText: _obscure,
              autovalidateMode: _submitted
                  ? AutovalidateMode.onUserInteraction
                  : AutovalidateMode.disabled,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _submitLogin(),
              validator: (v) {
                final s = (v ?? '');
                if (s.isEmpty) return l10n.input_valid_pwd_must;
                return null;
              },
              suffix: IconButton(
                onPressed: () => setState(() => _obscure = !_obscure),
                icon: Icon(
                  _obscure
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: const Color(0xFF6B7280),
                ),
              ),
            ),
            const SizedBox(height: 14),
            if (auth.errorKey != null) ...[
              Text(
                auth.errorKey!.message(l10n),
                style: const TextStyle(color: Colors.red),
              ),
              const SizedBox(height: 10),
            ],
            AuthPrimaryButton(
              label: auth.loading ? l10n.login_logining : l10n.login_with_mail,
              onPressed: auth.loading ? null : _submitLogin,
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(l10n.login_no_account),
                TextButton(
                  onPressed:
                      auth.loading ? null : () => context.push('/register'),
                  child: Text(l10n.login_to_register),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: const [
                Expanded(child: Divider()),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Text('or'),
                ),
                Expanded(child: Divider()),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.g_mobiledata), // 你也可以换成 Google 图标资源
                label: Text(l10n.login_with_google),
                onPressed: () {
                  ref.read(authControllerProvider.notifier).loginWithGoogle();
                  // 不用手动跳转：authState 变成已登录后，你 router 会 redirect 到 /inbox
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
