import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import '../data/subscription_store.dart';

/// Store：负责 IAP 初始化、商品查询、购买、恢复、purchaseStream 监听
final subscriptionStoreProvider = Provider<SubscriptionStore>((ref) {
  final store = SubscriptionStore();
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

/// 维持你现在的用法：
/// final sub = ref.watch(subscriptionProvider);
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

    // 1) 读取本地订阅状态（或你已有的持久化）
    final subscribed = await store.getSubscribed();
    state = state.copyWith(subscribed: subscribed);

    // 2) 初始化 IAP + 查询商品
    state = state.copyWith(loading: true, error: null);
    try {
      await store.init(); // 负责 purchaseStream 监听等（store 里实现）
      final products = await store.queryProducts({monthlyId, yearlyId});
      state = state.copyWith(loading: false, products: products);
    } catch (e) {
      state = state.copyWith(
        loading: false,
        error: e.toString(),
      );
    }

    // 3) 订阅 store 的购买事件（当购买成功/恢复成功时，更新 subscribed）
    store.onSubscribedChanged = (v) async {
      state = state.copyWith(subscribed: v, busy: false, error: null);
    };

    store.onError = (msg) {
      state = state.copyWith(error: msg, busy: false);
    };
  }

  /// ✅ 购买（月付 or 年付）
  Future<bool> purchase(ProductDetails product) async {
    if (state.busy) return false;
    state = state.copyWith(busy: true, error: null);
    try {
      final store = ref.read(subscriptionStoreProvider);
      await store.purchase(product);
      // 结果通过 purchaseStream -> store 回调 -> onSubscribedChanged 反映到 state
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
      return true;
    } catch (e) {
      state = state.copyWith(busy: false, error: e.toString());
      return false;
    }
  }

  /// ✅ Debug：手动设置订阅状态
  Future<void> debugSetSubscribed(bool v) async {
    final store = ref.read(subscriptionStoreProvider);
    await store.setSubscribed(v);
    state = state.copyWith(subscribed: v);
  }
}
