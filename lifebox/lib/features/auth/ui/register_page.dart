import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

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
  Widget build(BuildContext context) {
    final auth = ref.watch(authControllerProvider);

    return AuthLayout(
      title: '创建账号',
      subtitle: '使用邮箱注册，后续可绑定 Google/Apple，并开启应用锁增强安全。',
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
            hint: '至少 8 位',
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
            label: '确认密码',
            hint: '再次输入密码',
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
          const SizedBox(height: 14),

          if (_pwd.text.isNotEmpty && _pwd2.text.isNotEmpty && _pwd.text != _pwd2.text) ...[
            const Text('两次密码不一致', style: TextStyle(color: Colors.red)),
            const SizedBox(height: 10),
          ],

          if (auth.error != null) ...[
            Text(auth.error!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 10),
          ],

          AuthPrimaryButton(
            label: auth.loading ? '注册中...' : '邮箱注册',
            onPressed: auth.loading
                ? null
                : () {
                    final email = _email.text.trim();
                    final p1 = _pwd.text;
                    final p2 = _pwd2.text;

                    if (p1.length < 8) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('密码至少 8 位')));
                      return;
                    }
                    if (p1 != p2) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('两次密码不一致')));
                      return;
                    }
                    ref.read(authControllerProvider.notifier).register(email, p1);
                  },
          ),
          const SizedBox(height: 10),
          AuthSecondaryButton(
            label: '返回登录',
            icon: Icons.arrow_back,
            onPressed: () => context.pop(),
          ),
          const AuthHintText('注册成功后将自动进入收件箱。'),
        ],
      ),
    );
  }
}
