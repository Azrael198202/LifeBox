import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/services/app_lock.dart';
import '../features/auth/state/auth_controller.dart';

import '../features/auth/ui/login_page.dart';
import '../features/auth/ui/register_page.dart';
import '../features/lock/ui/lock_page.dart';

import '../features/inbox/ui/inbox_page.dart';
import '../features/inbox/ui/inbox_detail_page.dart';
import '../features/capture/ui/import_page.dart';
import '../features/actions/ui/action_page.dart';
import '../features/settings/ui/settings_page.dart';

final routerProvider = Provider<GoRouter>((ref) {
  // ✅ 状态
  final authState = ref.watch(authControllerProvider);
  final lockState = ref.watch(appLockProvider);

  // ✅ notifier（用于 router refresh）
  final authController = ref.read(authControllerProvider.notifier);

  return GoRouter(
    initialLocation: '/inbox',

    /// ✅ auth stream 有变化就刷新 router（保持你原来的）
    refreshListenable: GoRouterRefreshStream(authController.stream),

    redirect: (context, state) {
      final loc = state.matchedLocation;

      final isAuthed = authState.isAuthenticated;
      final isOnAuthPage = loc == '/login' || loc == '/register';

      // 1) 未登录：只能去 login/register
      if (!isAuthed && !isOnAuthPage) return '/login';
      if (!isAuthed && isOnAuthPage) return null;

      // 2) 已登录：不允许回到 login/register
      if (isAuthed && isOnAuthPage) return '/inbox';

      // 3) App 锁：已登录但锁住 => 去 /lock（带 from）
      if (isAuthed && lockState.enabled && lockState.isLocked) {
        if (loc != '/lock') {
          // 把当前目标路径完整保存下来（包含 query / pathParams）
          final from = Uri.encodeComponent(state.uri.toString());
          return '/lock?from=$from';
        }
        return null;
      }

      // 4) 已解锁但还停在 /lock => 回到 from 或默认页
      if (isAuthed &&
          (!lockState.enabled || !lockState.isLocked) &&
          loc == '/lock') {
        final from = state.uri.queryParameters['from'];
        return from != null ? Uri.decodeComponent(from) : '/inbox';
      }

      return null;
    },

    routes: [
      GoRoute(path: '/login', builder: (_, __) => const LoginPage()),
      GoRoute(path: '/register', builder: (_, __) => const RegisterPage()),

      // ✅ Lock route：接收 from
      GoRoute(
        path: '/lock',
        builder: (context, state) {
          final from = state.uri.queryParameters['from'];
          return LockPage(from: from);
        },
      ),

      GoRoute(path: '/import', builder: (_, __) => const ImportPage()),

      GoRoute(
        path: '/inbox',
        builder: (_, __) => const InboxPage(),
        routes: [
          GoRoute(
            path: 'detail/:id',
            builder: (_, state) => InboxDetailPage(id: state.pathParameters['id']!),
          ),
        ],
      ),

      GoRoute(
        path: '/action',
        builder: (_, state) {
          final type = state.uri.queryParameters['type'] ?? 'calendar';
          final id = state.uri.queryParameters['id'] ?? '';
          return ActionPage(actionType: type, itemId: id);
        },
      ),

      GoRoute(path: '/settings', builder: (_, __) => const SettingsPage()),
    ],
  );
});

/// ✅ GoRouter 的 refreshListenable 需要 Listenable
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    _sub = stream.listen((_) => notifyListeners());
  }

  late final StreamSubscription<dynamic> _sub;

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}
