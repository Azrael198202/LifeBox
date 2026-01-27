import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lifebox/core/widgets/TermsConsent.dart';

import 'package:lifebox/l10n/app_localizations.dart';
import '../../../core/network/api_error_l10n.dart';

import '../state/auth_providers.dart';
import '../../../core/widgets/auth_widgets.dart';

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

  void _submitRegister(AppLocalizations l10n) {
    setState(() => _submitted = true);

    if (!_ensureTermsChecked(l10n)) return;

    final ok = _formKey.currentState?.validate() ?? false;
    if (!ok) return;

    ref.read(authControllerProvider.notifier).registerWithEmail(
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
    _pwd2.dispose();
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

    // ✅ Splash 主色系：跟 LoginPage 保持一致
    const bgTop = Color(0xFF16264D);
    const bgBottom = Color(0xFF1B2E5A);

    return Scaffold(
      backgroundColor: bgTop,
      body: Stack(
        children: [
          // ===== 顶部渐变背景 =====
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

          // 可选：轻微高光
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
                  // ===== 头部内容 =====
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 22, 24, 18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Image.asset('assets/images/logo-b.png', height: 60),
                            const SizedBox(width: 10),
                            Text(
                              l10n.register_title,
                              style: const TextStyle(
                                fontSize: 28,
                                height: 1.15,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          l10n.register_subtitle,
                          style: TextStyle(
                            fontSize: 14,
                            height: 1.4,
                            color: Colors.white.withOpacity(0.74),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ===== 白色表单卡片 =====
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
                                return l10n.register_error_email_invalid;
                              }
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
                              if (s.isEmpty) return l10n.input_valid_pwd_must;
                              if (s.length < 8) {
                                return l10n.register_error_password_too_short;
                              }
                              return null;
                            },
                            suffix: IconButton(
                              onPressed: () =>
                                  setState(() => _obscure1 = !_obscure1),
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
                            onFieldSubmitted: (_) => _submitRegister(l10n),
                            validator: (v) {
                              final s = (v ?? '');
                              if (s.isEmpty)
                                return l10n.input_valid_comfirm_pwd;
                              if (s != _pwd.text) {
                                return l10n.register_password_mismatch;
                              }
                              return null;
                            },
                            suffix: IconButton(
                              onPressed: () =>
                                  setState(() => _obscure2 = !_obscure2),
                              icon: Icon(
                                _obscure2
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                color: const Color(0xFF6B7280),
                              ),
                            ),
                          ),

                          const SizedBox(height: 12),

                          // ✅ 实时 mismatch 提示（不用额外 listener）
                          ValueListenableBuilder<TextEditingValue>(
                            valueListenable: _pwd2,
                            builder: (_, __, ___) {
                              final pwdNotMatch = _pwd.text.isNotEmpty &&
                                  _pwd2.text.isNotEmpty &&
                                  _pwd.text != _pwd2.text;
                              if (!pwdNotMatch) return const SizedBox.shrink();
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Text(
                                  l10n.register_password_mismatch,
                                  style: const TextStyle(color: Colors.red),
                                ),
                              );
                            },
                          ),

                          if (auth.errorKey != null) ...[
                            Text(
                              auth.errorKey!.message(l10n),
                              style: const TextStyle(color: Colors.red),
                            ),
                            const SizedBox(height: 10),
                          ],

                          AuthPrimaryButton(
                            label: auth.loading
                                ? l10n.loading_more
                                : l10n.register_button_email,
                            onPressed: auth.loading
                                ? null
                                : () => _submitRegister(l10n),
                          ),

                          const SizedBox(height: 12),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(l10n.login_already_have_account),
                              TextButton(
                                onPressed:
                                    auth.loading ? null : () => context.pop(),
                                child: Text(l10n.login_to_login),
                              ),
                            ],
                          ),

                          const SizedBox(height: 12),
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

                          // ✅ Google 注册（后端自动注册/登录）
                          AuthSecondaryButton(
                            label: l10n.login_continue_google,
                            icon: Icons.g_mobiledata,
                            onPressed: auth.loading
                                ? null
                                : () {
                                    if (!_ensureTermsChecked(l10n)) return;
                                    ref
                                        .read(authControllerProvider.notifier)
                                        .loginWithGoogle();
                                  },
                          ),

                          const SizedBox(height: 10),
                          AuthHintText(l10n.register_hint_success),

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
