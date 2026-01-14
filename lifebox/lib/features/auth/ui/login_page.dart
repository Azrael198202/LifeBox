import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../state/auth_controller.dart';
import 'auth_widgets.dart';
import 'package:lifebox/l10n/app_localizations.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _email = TextEditingController();
  final _pwd = TextEditingController();
  bool _obscure = true;

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
            hint: l10n.common_mail_hit,
            icon: Icons.lock_outline,
            obscureText: _obscure,
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
          if (auth.error != null) ...[
            Text(auth.error!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 10),
          ],
          AuthPrimaryButton(
            label: auth.loading ? l10n.login_logining : l10n.login_with_mail,
            onPressed: auth.loading
                ? null
                : () => ref.read(authControllerProvider.notifier).login(
                      _email.text.trim(),
                      _pwd.text,
                    ),
          ),
          const SizedBox(height: 10),
          AuthDivider(text: l10n.common_or),
          const SizedBox(height: 10),
          AuthSecondaryButton(
            label: l10n.login_with_google,
            icon: Icons.g_mobiledata,
            onPressed: auth.loading
                ? null
                : () =>
                    ref.read(authControllerProvider.notifier).loginWithGoogle(),
          ),
          const SizedBox(height: 10),
          TextButton(
            onPressed: () => context.push('/register'),
            child: Text(
              l10n.login_to_register,
              style: TextStyle(
                  color: Color(0xFF111827), fontWeight: FontWeight.w700),
            ),
          ),
          AuthHintText(l10n.login_hit),
        ],
      ),
    );
  }
}
