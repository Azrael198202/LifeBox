import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../state/auth_controller.dart';
import 'auth_widgets.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage>  {
  final _email = TextEditingController();
  final _pwd = TextEditingController();
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authControllerProvider);

    return AuthLayout(
      title: 'Life Inbox',
      subtitle: '登录后开始导入截图，自动识别待办与风险，并用应用锁保护隐私。',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AuthTextField(
            controller: _email,
            label: '邮箱',
            hint: 'example@email.com',
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 14),
          AuthTextField(
            controller: _pwd,
            label: '密码',
            hint: '请输入密码',
            icon: Icons.lock_outline,
            obscureText: _obscure,
            suffix: IconButton(
              onPressed: () => setState(() => _obscure = !_obscure),
              icon: Icon(
                _obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
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
            label: auth.loading ? '登录中...' : '邮箱登录',
            onPressed: auth.loading
                ? null
                : () => ref.read(authControllerProvider.notifier).login(
                      _email.text.trim(),
                      _pwd.text,
                    ),
          ),
          const SizedBox(height: 10),
          AuthSecondaryButton(
            label: '使用 Google 登录（占位）',
            icon: Icons.g_mobiledata,
            onPressed: auth.loading ? null : () => ref.read(authControllerProvider.notifier).loginWithGoogle(),
          ),
          const SizedBox(height: 10),
          TextButton(
            onPressed: () => context.push('/register'),
            child: const Text('没有账号？去注册', style: TextStyle(color: Color(0xFF111827))),
          ),
          const AuthHintText('提示：后续可开启面容/指纹/系统认证的应用锁。'),
        ],
      ),
    );
  }
}
