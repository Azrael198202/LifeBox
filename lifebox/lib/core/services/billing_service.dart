import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:lifebox/core/network/app_config.dart';

class BillingService {
  BillingService({
    required this.getAccessToken,
  });

  /// 从 auth 层拿 access token
  final Future<String?> Function() getAccessToken;

  // ======================
  // APIs
  // ======================

  Future<Map<String, dynamic>> getSubscription() async {
    final resp = await http.get(Uri.parse(AppConfig.billingSubscription), headers: await _headers());
    _ensureOk(resp);
    return jsonDecode(resp.body) as Map<String, dynamic>;
  }

  Future<List<dynamic>> getEntitlements() async {
    final resp = await http.get(Uri.parse(AppConfig.billingEntitlements), headers: await _headers());
    _ensureOk(resp);
    return jsonDecode(resp.body) as List<dynamic>;
  }

  Future<Map<String, dynamic>> verify({
    required String platform, // "android" | "ios"
    required String productId,
    String? purchaseToken,
    String? receipt,
    String? transactionId,
    String? originalTransactionId,
    Map<String, dynamic>? clientPayload,
  }) async {
    final body = <String, dynamic>{
      'platform': platform,
      'product_id': productId,
      if (purchaseToken != null) 'purchase_token': purchaseToken,
      if (receipt != null) 'receipt': receipt,
      if (transactionId != null) 'transaction_id': transactionId,
      if (originalTransactionId != null)
        'original_transaction_id': originalTransactionId,
      if (clientPayload != null) 'client_payload': clientPayload,
    };

    final resp = await http.post(
      Uri.parse(AppConfig.billingVerify),
      headers: await _headers(),
      body: jsonEncode(body),
    );

    _ensureOk(resp);
    return jsonDecode(resp.body) as Map<String, dynamic>;
  }

  // ======================
  // helpers
  // ======================

  Future<Map<String, String>> _headers() async {
    final token = await getAccessToken();
    return {
      'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty)
        'Authorization': 'Bearer $token',
    };
  }

  void _ensureOk(http.Response resp) {
    if (resp.statusCode >= 200 && resp.statusCode < 300) return;
    throw Exception(
      'Billing API error: ${resp.statusCode} ${resp.body}',
    );
  }
}
