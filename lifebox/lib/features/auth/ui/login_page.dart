import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lifebox/core/widgets/TermsConsent.dart';

import '../state/auth_providers.dart';
import '../../../core/widgets/auth_widgets.dart';
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

  void _submitLogin(AppLocalizations l10n) {
    setState(() => _submitted = true);

    if (!_ensureTermsChecked(l10n)) return;

    final ok = _formKey.currentState?.validate() ?? false;
    if (!ok) return;

    ref.read(authControllerProvider.notifier).loginWithEmail(
          _email.text.trim(),
          _pwd.text,
        );
  }

  final _termsChecked = ValueNotifier<bool>(false);

  @override
  void dispose() {
    _termsChecked.dispose();
    _email.dispose();
    _pwd.dispose();
    super.dispose();
  }

  bool _ensureTermsChecked(AppLocalizations l10n) {
    if (_termsChecked.value) return true;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.terms_must_agree)),
    );
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authControllerProvider);
    final l10n = AppLocalizations.of(context);

    // ✅ Splash 主色系：跟你现在的启动背景一致
    const bgTop = Color(0xFF16264D);
    const bgBottom = Color(0xFF1B2E5A);

    return Scaffold(
      backgroundColor: bgTop, // 防止滚动露底时变白
      body: Stack(
        children: [
          // ===== 顶部渐变背景（头部舞台）=====
          Container(
            height: 320,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [bgTop, bgBottom],
              ),
            ),
          ),

          // 可选：轻微高光（更“银河”一点，想要就保留）
          Positioned(
            right: -80,
            top: -60,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.06),
              ),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ===== 头部内容（你要重点改的区域）=====
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 22, 24, 18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 顶部品牌行：logo + LifeInbox
                        Row(
                          children: [
                            // 你原本的 logo
                            Image.asset(
                              'assets/images/logo-b.png',
                              height: 60,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              l10n.login_title, // 你要固定可换成 'おかえりなさい'
                              style: const TextStyle(
                                fontSize: 28,
                                height: 1.15,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),

                        Text(
                          l10n.login_subtitle,
                          style: TextStyle(
                            fontSize: 14,
                            height: 1.4,
                            color: Colors.white.withOpacity(0.74),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ===== 白色表单卡片（承接）=====
                  Container(
                    margin: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                    padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 18,
                          offset: const Offset(0, 10),
                          color: Colors.black.withOpacity(0.12),
                        ),
                      ],
                    ),
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
                              if (!_isValidEmail(s)) {
                                return l10n.input_valid_mail_format;
                              }
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
                            onFieldSubmitted: (_) => _submitLogin(l10n),
                            validator: (v) {
                              final s = (v ?? '');
                              if (s.isEmpty) return l10n.input_valid_pwd_must;
                              return null;
                            },
                            suffix: IconButton(
                              onPressed: () =>
                                  setState(() => _obscure = !_obscure),
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
                            label: auth.loading
                                ? l10n.login_logining
                                : l10n.login_with_mail,
                            onPressed: auth.loading
                                ? null
                                : () {
                                    if (!_ensureTermsChecked(l10n)) return;
                                    ref
                                        .read(authControllerProvider.notifier)
                                        .loginWithGoogle();
                                  },
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(l10n.login_no_account),
                              TextButton(
                                onPressed: auth.loading
                                    ? null
                                    : () => context.push('/register'),
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
                              icon: const Icon(Icons.g_mobiledata),
                              label: Text(l10n.login_with_google),
                              onPressed: auth.loading
                                  ? null
                                  : () {
                                      ref
                                          .read(authControllerProvider.notifier)
                                          .loginWithGoogle();
                                    },
                            ),
                          ),
                          const SizedBox(height: 14),
                          TermsConsent(checked: _termsChecked, onDark: false),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
