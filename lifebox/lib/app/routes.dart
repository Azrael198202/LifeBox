import 'package:go_router/go_router.dart';
import 'package:lifebox/core/services/legal_api.dart';
import 'package:lifebox/features/settings/ui/legal_page.dart';
import '../features/capture/ui/import_page.dart';
import '../features/inbox/ui/inbox_page.dart';
import '../features/inbox/ui/inbox_detail_page.dart';
import '../features/actions/ui/action_page.dart';
import '../features/settings/ui/settings_page.dart';

GoRouter buildRouter() {
  return GoRouter(
    initialLocation: '/inbox',
    routes: [
      GoRoute(
        path: '/import',
        builder: (context, state) => const ImportPage(),
      ),
      GoRoute(
        path: '/inbox',
        builder: (context, state) => const InboxPage(),
        routes: [
          GoRoute(
            path: 'detail/:id',
            builder: (context, state) {
              final id = state.pathParameters['id']!;
              return InboxDetailPage(id: id);
            },
          ),
        ],
      ),
      GoRoute(
        path: '/action',
        builder: (context, state) {
          final type = state.uri.queryParameters['type'] ?? 'calendar';
          final id = state.uri.queryParameters['id'] ?? '';
          return ActionPage(actionType: type, itemId: id);
        },
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsPage(),
      ),
      GoRoute(
        path: '/legal/terms',
        builder: (_, __) => const LegalPage(type: LegalType.terms),
      ),
      GoRoute(
        path: '/legal/privacy',
        builder: (_, __) => const LegalPage(type: LegalType.privacy),
      ),
    ],
  );
}
