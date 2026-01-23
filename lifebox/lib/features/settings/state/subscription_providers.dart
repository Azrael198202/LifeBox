import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import '../../auth/state/auth_providers.dart';
import '../../../core/services/billing_service.dart';
import '../data/subscription_store.dart';

/// ✅ BillingService：从 AuthState 取 accessToken（没有 authProvider 就用这个）
final billingServiceProvider = Provider<BillingService>((ref) {
  return BillingService(
    getAccessToken: () async => ref.read(authControllerProvider).accessToken,
  );
});

/// ✅ Store：注入 BillingService（你现在 SubscriptionStore(this.billing)）
final subscriptionStoreProvider = Provider<SubscriptionStore>((ref) {
  final billing = ref.watch(billingServiceProvider);
  final store = SubscriptionStore(billing);
  ref.onDispose(store.dispose);
  return store;
});

/// UI 用的状态（Paywall Page / SettingsPage 都依赖这个）
class SubscriptionState {
  final bool subscribed;

  /// 初始化/查询商品中
  final bool loading;

  /// 购买/恢复处理中
  final bool busy;

  /// 错误信息
  final String? error;

  /// 可购买的订阅商品（月付/年付）
  final List<ProductDetails> products;

  const SubscriptionState({
    required this.subscribed,
    required this.loading,
    required this.busy,
    required this.products,
    this.error,
  });

  const SubscriptionState.initial()
      : subscribed = false,
        loading = true,
        busy = false,
        error = null,
        products = const [];

  SubscriptionState copyWith({
    bool? subscribed,
    bool? loading,
    bool? busy,
    String? error,
    List<ProductDetails>? products,
  }) {
    return SubscriptionState(
      subscribed: subscribed ?? this.subscribed,
      loading: loading ?? this.loading,
      busy: busy ?? this.busy,
      error: error,
      products: products ?? this.products,
    );
  }
}

final subscriptionProvider =
    StateNotifierProvider<SubscriptionNotifier, SubscriptionState>(
  (ref) => SubscriptionNotifier(ref),
);

class SubscriptionNotifier extends StateNotifier<SubscriptionState> {
  SubscriptionNotifier(this.ref) : super(const SubscriptionState.initial()) {
    _init();
  }

  final Ref ref;

  static const monthlyId = 'lifebox_premium_monthly';
  static const yearlyId = 'lifebox_premium_yearly';

  Future<void> _init() async {
    final store = ref.read(subscriptionStoreProvider);

    // ✅ 先绑定回调（避免漏掉 purchaseStream 回调）
    store.onSubscribedChanged = (v) {
      state = state.copyWith(subscribed: v, busy: false, error: null);
    };
    store.onError = (msg) {
      state = state.copyWith(error: msg, busy: false);
    };

    // 1) 读缓存（UI 快速展示）
    try {
      final cached = await store.getSubscribed();
      state = state.copyWith(subscribed: cached);
    } catch (_) {}

    // 2) 刷新服务端真实订阅（不阻塞 IAP）
    () async {
      try {
        final real = await store.refreshSubscribedFromServer();
        state = state.copyWith(subscribed: real);
      } catch (_) {}
    }();

    // 3) 初始化 IAP + 查询商品（prod 用；dev 不依赖 products 也没关系）
    state = state.copyWith(loading: true, error: null);
    try {
      await store.init();
      final products = await store.queryProducts({monthlyId, yearlyId});
      state = state.copyWith(loading: false, products: products);
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
    }
  }

  Future<bool> purchase(ProductDetails product) async {
    if (state.busy) return false;
    state = state.copyWith(busy: true, error: null);
    try {
      final store = ref.read(subscriptionStoreProvider);
      await store.purchase(product);
      // 真正 subscribed 更新：purchaseStream -> verify -> store.setSubscribed -> onSubscribedChanged
      return true;
    } catch (e) {
      state = state.copyWith(busy: false, error: e.toString());
      return false;
    }
  }

  Future<bool> restore() async {
    if (state.busy) return false;
    state = state.copyWith(busy: true, error: null);
    try {
      final store = ref.read(subscriptionStoreProvider);
      await store.restore();
      return true;
    } catch (e) {
      state = state.copyWith(busy: false, error: e.toString());
      return false;
    }
  }

  Future<void> refresh() async {
    try {
      final store = ref.read(subscriptionStoreProvider);
      final real = await store.refreshSubscribedFromServer();
      state = state.copyWith(subscribed: real);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// ✅ 给 Paywall 的 DEV 路A用：临时占用 busy + 捕获异常
  Future<void> devBusyRun(Future<void> Function() fn) async {
    if (state.busy) return;
    state = state.copyWith(busy: true, error: null);

    try {
      await fn();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    } finally {
      state = state.copyWith(busy: false);
    }
  }

  Future<void> debugSetSubscribed(bool v) async {
    final store = ref.read(subscriptionStoreProvider);
    await store.debugSetSubscribed(v);
    state = state.copyWith(subscribed: v);
  }

  Future<bool> devActivate(String productId) async {

    await devBusyRun(() async {
      final store = ref.read(subscriptionStoreProvider);
      await store.billing.verify(
        platform: 'android',
        productId: productId,
        purchaseToken: 'test_ok',
        clientPayload: {'dev': true},
      );
      await refresh(); // ✅ 确保 subscribed 立刻变 true
    });
    return state.subscribed;
  }

  Future<void> devExpire() async {
    await devBusyRun(() async {
      final store = ref.read(subscriptionStoreProvider);
      await store.billing.verify(
        platform: 'android',
        productId: monthlyId,
        purchaseToken: 'test_expired',
        clientPayload: {'dev': true},
      );
      await refresh();
    });
  }
}
