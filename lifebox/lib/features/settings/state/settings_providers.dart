import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../inbox/data/cloud_settings_store.dart';

final cloudSettingsStoreProvider = Provider((ref) => CloudSettingsStore());

final cloudEnabledProvider = StateNotifierProvider<CloudEnabledNotifier, bool>(
  (ref) => CloudEnabledNotifier(ref),
);

class CloudEnabledNotifier extends StateNotifier<bool> {
  CloudEnabledNotifier(this.ref) : super(false) {
    _load();
  }

  final Ref ref;

  Future<void> _load() async {
    final store = ref.read(cloudSettingsStoreProvider);
    state = await store.getCloudEnabled();
  }

  Future<void> setEnabled(bool v) async {
    state = v;
    final store = ref.read(cloudSettingsStoreProvider);
    await store.setCloudEnabled(v);
  }
}
