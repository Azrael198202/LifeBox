import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:lifebox/l10n/app_localizations.dart';

import 'router_provider.dart';
import 'theme/theme.dart';
import '../core/services/app_lock.dart';
import '../core/i18n/locale_controller.dart';

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

  /// app background -> foreground trigger the app lock check
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ref.read(appLockProvider.notifier).onResume();
    }
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);
    final locale = ref.watch(localeProvider);
    // final l10n = AppLocalizations.of(context);

    return MaterialApp.router(
      locale: locale,
      supportedLocales: const [
        Locale('ja'),
        Locale('zh'),
        Locale('en'),
      ],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      title: "スッと",
      theme: buildLightTheme(),
      darkTheme: buildDarkTheme(),
      themeMode: ThemeMode.system,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
