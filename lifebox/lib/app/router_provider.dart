import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lifebox/features/inbox/ui/add_to_device_calendar_page.dart';
import 'package:lifebox/features/settings/ui/add_member_app_account_page.dart';
import 'package:lifebox/features/settings/ui/join_group_page.dart';
import 'package:lifebox/features/settings/ui/paywall_page.dart';

import '../core/services/app_lock.dart';
import '../features/auth/state/auth_providers.dart';

import '../features/auth/ui/login_page.dart';
import '../features/auth/ui/register_page.dart';
import '../features/lock/ui/lock_page.dart';

import '../features/inbox/ui/inbox_page.dart';
import '../features/inbox/ui/inbox_detail_page.dart';
import '../features/capture/ui/import_page.dart';
import '../features/actions/ui/action_page.dart';
import '../features/settings/ui/settings_page.dart';

import '../features/settings/ui/personal_info_page.dart';
import '../features/settings/ui/group_management_page.dart';
import '../features/settings/ui/group_settings_page.dart';

final routerProvider = Provider<GoRouter>((ref) {
  // auth and lock state
  final authState = ref.watch(authControllerProvider);
  final lockState = ref.watch(appLockProvider);

  // router refresh
  final authController = ref.read(authControllerProvider.notifier);

  return GoRouter(
    initialLocation: '/inbox',

    // automatic refresh when authState / lockState changes
    refreshListenable: GoRouterRefreshStream(authController.stream),

    redirect: (context, state) {
      final loc = state.matchedLocation;

      final isAuthed = authState.isAuthenticated;
      final isOnAuthPage = loc == '/login' || loc == '/register';

      // 1) unauthed：must go to login
      if (!isAuthed && !isOnAuthPage) return '/login';
      if (!isAuthed && isOnAuthPage) return null;

      // 2) authed & on auth page => go to inbox
      if (isAuthed && isOnAuthPage) return '/inbox';

      // 3) App locked => go to /lock
      if (isAuthed && lockState.enabled && lockState.isLocked) {
        if (loc != '/lock') {
          // save current location to "from" query param
          final from = Uri.encodeComponent(state.uri.toString());
          return '/lock?from=$from';
        }
        return null;
      }

      // 4) unlock but still at /lock : return form or /inbox
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

      // Lock route with optional "from" query parameter
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
            builder: (_, state) =>
                InboxDetailPage(id: state.pathParameters['id']!),
          ),
        ],
      ),

      GoRoute(
        path: '/inbox/add_to_calendar/:id',
        builder: (_, state) => AddToDeviceCalendarPage(
          recordId: state.pathParameters['id']!,
        ),
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

      GoRoute(
        path: '/paywall',
        builder: (_, __) => const PaywallPage(),
      ),

      GoRoute(
        path: '/settings',
        builder: (_, __) => const SettingsPage(),
        routes: [
          GoRoute(
            path: 'profile',
            builder: (_, __) => const PersonalInfoPage(),
          ),
          GoRoute(
            path: 'groups',
            builder: (_, __) => const GroupManagementPage(),
            routes: [
              GoRoute(
                path: 'create',
                builder: (_, __) => const GroupSettingsPage(), // groupId = null
              ),
              GoRoute(
                path: 'join',
                builder: (_, __) => const JoinGroupPage(),
              ),
              GoRoute(
                path: ':id',
                builder: (_, state) =>
                    GroupSettingsPage(groupId: state.pathParameters['id']),
              ),
              GoRoute(
                path: 'add-member/app',
                builder: (_, __) => const AddMemberAppAccountPage(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});

/// GoRouter refresh helper class used to notify GoRouter of changes
/// when the provided stream emits new events.
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
