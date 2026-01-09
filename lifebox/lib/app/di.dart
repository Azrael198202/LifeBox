import '../core/services/api_client.dart';
import '../core/services/auth_store.dart';

late final ApiClient apiClient;
late final AuthStore authStore;

Future<void> configureDependencies() async {
  authStore = AuthStore();
  apiClient = ApiClient(authStore: authStore);
}
