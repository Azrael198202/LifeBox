import 'package:shared_preferences/shared_preferences.dart';

class CloudSettingsStore {
  static const _kCloudEnabled = 'cloud_sync_enabled';

  Future<bool> getCloudEnabled() async {
    final sp = await SharedPreferences.getInstance();
    return sp.getBool(_kCloudEnabled) ?? false;
  }

  Future<void> setCloudEnabled(bool v) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setBool(_kCloudEnabled, v);
  }
}
