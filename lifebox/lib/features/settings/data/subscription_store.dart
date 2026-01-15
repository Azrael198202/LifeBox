import 'package:shared_preferences/shared_preferences.dart';

class SubscriptionStore {
  static const _kSubscribed = 'pro_cloud_subscribed';

  Future<bool> getSubscribed() async {
    final sp = await SharedPreferences.getInstance();
    return sp.getBool(_kSubscribed) ?? false;
  }

  Future<void> setSubscribed(bool v) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setBool(_kSubscribed, v);
  }
}
