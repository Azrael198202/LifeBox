import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'router_provider.dart';
import 'theme/theme.dart';
import '../core/services/app_lock.dart';

class LifeInboxApp extends ConsumerStatefulWidget {
  const LifeInboxApp({super.key});

  @override
  ConsumerState<LifeInboxApp> createState() => _LifeInboxAppState();
}

class _LifeInboxAppState extends ConsumerState<LifeInboxApp>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// ✅ App 从后台回到前台时，触发应用锁
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ref.read(appLockProvider.notifier).onResume();
    }
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Life Inbox',
      theme: buildAppTheme(),
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
