import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/ui/auth_widgets.dart';
import '../../../core/services/app_lock.dart';

class LockPage extends ConsumerWidget {
  const LockPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AuthLayout(
      title: '已锁定',
      subtitle: '为保证隐私安全，请进行解锁认证后继续使用。',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 6),
          const Icon(Icons.lock_outline, size: 52, color: Color(0xFF111827)),
          const SizedBox(height: 14),
          const Text(
            '需要解锁才能继续',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF111827)),
          ),
          const SizedBox(height: 8),
          const AuthHintText('后续将接入 FaceID / TouchID / 指纹 / 系统认证（local_auth）。'),
          const SizedBox(height: 16),
          AuthPrimaryButton(
            label: '解锁（占位）',
            onPressed: () async {
              // TODO: 接 local_auth
              ref.read(appLockProvider.notifier).unlock();
            },
          ),
          const SizedBox(height: 10),
          AuthSecondaryButton(
            label: '暂不解锁（返回后台）',
            icon: Icons.keyboard_arrow_down,
            onPressed: () {
              // 让用户手动离开：这里不强制退出账号
              // 你也可以选择做 logout
              Navigator.of(context).maybePop();
            },
          ),
        ],
      ),
    );
  }
}
