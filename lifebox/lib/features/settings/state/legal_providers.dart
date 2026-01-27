import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:lifebox/core/services/legal_api.dart';

final dioProvider = Provider<Dio>((ref) {
  return Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 20),
  ));
});

final legalApiProvider = Provider<LegalApi>((ref) {
  return LegalApi(ref.watch(dioProvider));
});

/// Family provider：按 (type, lang) 拉取并缓存
final legalDocProvider =
    FutureProvider.family<LegalDoc, ({LegalType type, String lang})>(
  (ref, arg) async {
    final api = ref.watch(legalApiProvider);
    return api.fetchLegal(type: arg.type, lang: arg.lang);
  },
);