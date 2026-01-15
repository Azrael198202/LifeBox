import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/subscription_store.dart';

final subscriptionStoreProvider = Provider((ref) => SubscriptionStore());

final subscriptionProvider =
    StateNotifierProvider<SubscriptionNotifier, SubscriptionState>(
  (ref) => SubscriptionNotifier(ref),
);

class SubscriptionState {
  final bool subscribed;
  final bool busy;

  const SubscriptionState({
    required this.subscribed,
    required this.busy,
  });

  SubscriptionState copyWith({bool? subscribed, bool? busy}) => SubscriptionState(
        subscribed: subscribed ?? this.subscribed,
        busy: busy ?? this.busy,
      );
}

class SubscriptionNotifier extends StateNotifier<SubscriptionState> {
  SubscriptionNotifier(this.ref)
      : super(const SubscriptionState(subscribed: false, busy: false)) {
    _load();
  }

  final Ref ref;

  Future<void> _load() async {
    final store = ref.read(subscriptionStoreProvider);
    final v = await store.getSubscribed();
    state = state.copyWith(subscribed: v);
  }

  Future<void> _setSubscribed(bool v) async {
    final store = ref.read(subscriptionStoreProvider);
    await store.setSubscribed(v);
    state = state.copyWith(subscribed: v);
  }

  /// ✅ mock：购买订阅
  Future<bool> purchase() async {
    if (state.busy) return false;
    state = state.copyWith(busy: true);
    try {
      await Future.delayed(const Duration(milliseconds: 900)); // 模拟支付/网络
      await _setSubscribed(true);
      return true;
    } finally {
      state = state.copyWith(busy: false);
    }
  }

  /// ✅ mock：恢复购买（iOS/Android 常见）
  Future<bool> restore() async {
    if (state.busy) return false;
    state = state.copyWith(busy: true);
    try {
      await Future.delayed(const Duration(milliseconds: 700));
      // mock：这里假设恢复成功（你可以改为随机）
      await _setSubscribed(true);
      return true;
    } finally {
      state = state.copyWith(busy: false);
    }
  }

  /// ✅ mock：取消订阅（一般不在 App 内直接取消，通常引导去系统订阅管理）
  Future<void> debugSetSubscribed(bool v) async {
    await _setSubscribed(v);
  }
}
