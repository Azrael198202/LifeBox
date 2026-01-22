import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import '../data/subscription_store.dart';

/// Store：负责 IAP 初始化、商品查询、购买、恢复、purchaseStream 监听
final subscriptionStoreProvider = Provider<SubscriptionStore>((ref) {
  // ✅ 你项目里已经改成 SubscriptionStore(this.billing)
  // 这里保持你现有写法：从别处注入 billing（你已完成）
  // 如果你这里还没注入，请把 billingServiceProvider watch 后传入。
  throw UnimplementedError(
    'Please wire subscriptionStoreProvider with BillingService injection as you already did.',
  );
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

  // 商品 ID（和商店后台一致）
  static const monthlyId = 'lifebox_premium_monthly';
  static const yearlyId = 'lifebox_premium_yearly';

  Future<void> _init() async {
    final store = ref.read(subscriptionStoreProvider);

    // 0) 绑定回调（必须尽早，避免漏掉 purchaseStream 触发后的 setSubscribed）
    store.onSubscribedChanged = (v) {
      state = state.copyWith(subscribed: v, busy: false, error: null);
    };
    store.onError = (msg) {
      state = state.copyWith(error: msg, busy: false);
    };

    // 1) 先读本地缓存（只做 UI 快速显示）
    try {
      final cached = await store.getSubscribed();
      state = state.copyWith(subscribed: cached);
    } catch (_) {}

    // 2) 刷新服务端真实订阅状态（不阻塞商品加载）
    () async {
      try {
        final real = await store.refreshSubscribedFromServer();
        state = state.copyWith(subscribed: real);
      } catch (_) {
        // 网络失败不致命：保持缓存状态
      }
    }();

    // 3) 初始化 IAP + 查询商品
    state = state.copyWith(loading: true, error: null);
    try {
      await store.init();
      final products = await store.queryProducts({monthlyId, yearlyId});
      state = state.copyWith(loading: false, products: products);
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
    }
  }

  /// ✅ 购买（月付 or 年付）
  Future<bool> purchase(ProductDetails product) async {
    if (state.busy) return false;
    state = state.copyWith(busy: true, error: null);
    try {
      final store = ref.read(subscriptionStoreProvider);
      await store.purchase(product);

      // ✅ 不在这里 setSubscribed(true)
      // 真正的订阅更新由 purchaseStream -> server verify -> store.setSubscribed -> onSubscribedChanged 驱动
      return true;
    } catch (e) {
      state = state.copyWith(busy: false, error: e.toString());
      return false;
    }
  }

  /// ✅ 恢复购买
  Future<bool> restore() async {
    if (state.busy) return false;
    state = state.copyWith(busy: true, error: null);
    try {
      final store = ref.read(subscriptionStoreProvider);
      await store.restore();

      // 恢复同样由 purchaseStream 驱动最终 subscribed 更新
      return true;
    } catch (e) {
      state = state.copyWith(busy: false, error: e.toString());
      return false;
    }
  }

  /// ✅ 手动刷新（比如 Settings 页下拉刷新）
  Future<void> refresh() async {
    try {
      final store = ref.read(subscriptionStoreProvider);
      final real = await store.refreshSubscribedFromServer();
      state = state.copyWith(subscribed: real);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// ✅ Debug：手动设置订阅状态（仅本地缓存）
  Future<void> debugSetSubscribed(bool v) async {
    final store = ref.read(subscriptionStoreProvider);
    await store.debugSetSubscribed(v);
    state = state.copyWith(subscribed: v);
  }
}
