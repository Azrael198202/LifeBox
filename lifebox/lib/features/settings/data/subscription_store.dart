import 'dart:async';
import 'package:flutter/services.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 只做订阅（月付+年付）
class SubscriptionStore {
  static const monthlyId = 'lifebox_premium_monthly';
  static const yearlyId = 'lifebox_premium_yearly';

  static const _kSubscribed = 'subscribed_v1';

  final InAppPurchase _iap = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _sub;

  /// 给 Notifier 用：购买/恢复成功时回调
  void Function(bool v)? onSubscribedChanged;

  /// 给 Notifier 用：错误回调
  void Function(String msg)? onError;

  bool _inited = false;

  /// ================
  /// Local flag
  /// ================
  Future<bool> getSubscribed() async {
    final sp = await SharedPreferences.getInstance();
    return sp.getBool(_kSubscribed) ?? false;
  }

  Future<void> setSubscribed(bool v) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setBool(_kSubscribed, v);
    onSubscribedChanged?.call(v);
  }

  /// ================
  /// Init / Dispose
  /// ================
  Future<void> init() async {
    if (_inited) return;
    _inited = true;

    // purchaseStream 监听一次就够
    _sub ??= _iap.purchaseStream.listen(
      _onPurchaseUpdated,
      onError: (e) => onError?.call(e.toString()),
    );
  }

  void dispose() {
    _sub?.cancel();
    _sub = null;
    _inited = false;
  }

  /// ================
  /// Products
  /// ================
  Future<List<ProductDetails>> queryProducts(Set<String> ids) async {

    try{
      final available = await _iap.isAvailable();
      if (!available) throw Exception('課金サービスを利用できません');
    } on PlatformException catch (_){
       throw Exception('Google Play に接続できません。Google Play 対応端末でログインしてください。');
    }

    final resp = await _iap.queryProductDetails(ids);
    if (resp.error != null) {
      throw Exception(resp.error!.message);
    }

    // 可选：你可以检查 resp.notFoundIDs，提示配置错误
    // if (resp.notFoundIDs.isNotEmpty) ...

    return resp.productDetails;
  }

  /// ================
  /// Purchase / Restore
  /// ================
  Future<void> purchase(ProductDetails product) async {
    // 订阅产品的类型由商店后台决定。
    // 这里用 buyNonConsumable 也可以触发购买流程（订阅/消耗品/一次性取决于商店产品）。
    final param = PurchaseParam(productDetails: product);
    await _iap.buyNonConsumable(purchaseParam: param);
  }

  Future<void> restore() async {
    await _iap.restorePurchases();
  }

  /// ================
  /// PurchaseStream handler
  /// ================
  Future<void> _onPurchaseUpdated(List<PurchaseDetails> purchases) async {
    for (final p in purchases) {
      // pending：不用当成错误，等状态变化
      if (p.status == PurchaseStatus.pending) {
        continue;
      }

      // error
      if (p.status == PurchaseStatus.error) {
        onError?.call(p.error?.message ?? 'Purchase error');
        if (p.pendingCompletePurchase) {
          await _iap.completePurchase(p);
        }
        continue;
      }

      // purchased / restored
      if (p.status == PurchaseStatus.purchased ||
          p.status == PurchaseStatus.restored) {
        final isTarget = _isTargetProduct(p.productID);

        // ⚠️ 只对我们的订阅商品 setSubscribed
        if (isTarget) {
          // TODO: 上线建议做 receipt 验签（服务器校验）
          await setSubscribed(true);
        }

        if (p.pendingCompletePurchase) {
          await _iap.completePurchase(p);
        }
      }

      // canceled / other：不同平台支持不同状态，这里不额外处理
    }
  }

  bool _isTargetProduct(String id) =>
      id == monthlyId || id == yearlyId;

  /// Debug
  Future<void> debugSetSubscribed(bool v) => setSubscribed(v);
}
