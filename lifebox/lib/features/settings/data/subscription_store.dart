import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/services.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:lifebox/core/services/billing_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 只做订阅（月付+年付）
class SubscriptionStore {
  SubscriptionStore(this.billing);

  final BillingService billing;

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

  // =================
  // Local cache flag
  // =================
  Future<bool> getSubscribed() async {
    final sp = await SharedPreferences.getInstance();
    return sp.getBool(_kSubscribed) ?? false;
  }

  /// ⚠️ 这里只是缓存（真相来自服务端）
  Future<void> setSubscribed(bool v) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setBool(_kSubscribed, v);
    onSubscribedChanged?.call(v);
  }

  /// 从服务端刷新真实订阅状态（建议：App 启动/打开设置时调用）
  Future<bool> refreshSubscribedFromServer() async {
    final data = await billing.getSubscription();
    final subscribed = data['subscribed'] == true;
    await setSubscribed(subscribed);
    return subscribed;
  }

  // =================
  // Init / Dispose
  // =================
  Future<void> init() async {
    if (_inited) return;
    _inited = true;

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

  // =================
  // Products
  // =================
  Future<List<ProductDetails>> queryProducts(Set<String> ids) async {
    try {
      final available = await _iap.isAvailable();
      if (!available) throw Exception('課金サービスを利用できません');
    } on PlatformException catch (_) {
      throw Exception('Google Play に接続できません。Google Play 対応端末でログインしてください。');
    }

    final resp = await _iap.queryProductDetails(ids);
    if (resp.error != null) {
      throw Exception(resp.error!.message);
    }

    // 如果 notFoundIDs 不为空，说明商店后台 productId 不匹配
    // if (resp.notFoundIDs.isNotEmpty) { ... }

    return resp.productDetails;
  }

  // =================
  // Purchase / Restore
  // =================
  Future<void> purchase(ProductDetails product) async {
    final param = PurchaseParam(productDetails: product);
    await _iap.buyNonConsumable(purchaseParam: param);
  }

  Future<void> restore() async {
    await _iap.restorePurchases();
  }

  // ==========================
  // PurchaseStream handler
  // ==========================
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

        // 先 completePurchase（避免重复回调）
        if (p.pendingCompletePurchase) {
          await _iap.completePurchase(p);
        }

        if (!isTarget) {
          continue;
        }

        // ✅ 关键：调用服务端 verify，再以服务端结果为准更新缓存/UI
        try {
          final platform = _platformString();

          final serverData = p.verificationData.serverVerificationData;
          final localData = p.verificationData.localVerificationData;

          // Android：purchase_token 通常能从 serverVerificationData 拿到（具体依赖插件实现）
          // iOS：receipt 也可能在 serverVerificationData（后续接 Apple 校验时你可以调整字段）
          final resp = await billing.verify(
            platform: platform,
            productId: p.productID,
            purchaseToken: platform == 'android'
                ? (serverData.isNotEmpty ? serverData : null)
                : null,
            receipt: platform == 'ios'
                ? (serverData.isNotEmpty ? serverData : null)
                : null,
            transactionId: p.purchaseID,
            originalTransactionId: null,
            clientPayload: {
              'productId': p.productID,
              'purchaseId': p.purchaseID,
              'status': p.status.toString(),
              'serverDataLen': serverData.length,
              'localDataLen': localData.length,
            },
          );

          final subscribed = resp['subscribed'] == true;

          await setSubscribed(subscribed);
        } catch (e) {
          onError?.call(e.toString());
        }
      }

      // canceled / other：不同平台支持不同状态，这里不额外处理
    }
  }

  Future<bool> hasEntitlement(String key) async {
    final list = await billing.getEntitlements();
    // 每个元素形如 { entitlement, status, ... }
    return list.any((e) => e['entitlement'] == key && e['status'] == 'active');
  }

  bool _isTargetProduct(String id) => id == monthlyId || id == yearlyId;

  String _platformString() {
    if (Platform.isAndroid) return 'android';
    if (Platform.isIOS) return 'ios';
    // 订阅一般只跑在移动端，兜底
    return 'android';
  }

  /// Debug
  Future<void> debugSetSubscribed(bool v) => setSubscribed(v);
}
