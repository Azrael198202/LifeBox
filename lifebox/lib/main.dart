import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'app/di.dart';
import 'app/app.dart';

final sessionEpochProvider = StateProvider<int>((_) => 0);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  tz.initializeTimeZones();
  await configureDependencies();
  runApp(
    const ProviderScope(
      child: _Root(),
    ),
  );
}

class _Root extends ConsumerWidget {
  const _Root();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final epoch = ref.watch(sessionEpochProvider);

    return ProviderScope(
      key: ValueKey(epoch),
      child: const LifeInboxApp(),
    );
  }
}
