import '../core/services/auth_store.dart';

late final AuthStore authStore;

Future<void> configureDependencies() async {
  authStore = AuthStore();
}
