import 'package:dio/dio.dart';
import 'package:lifebox/core/network/app_config.dart';

enum LegalType { terms, privacy }

extension LegalTypeX on LegalType {
  String get apiValue => this == LegalType.terms ? 'terms' : 'privacy';
}

class LegalDoc {
  LegalDoc({
    required this.type,
    required this.lang,
    required this.title,
    required this.html,
    required this.updatedAt,
  });

  final String type;
  final String lang;
  final String title;
  final String html;
  final DateTime? updatedAt;

  factory LegalDoc.fromJson(Map<String, dynamic> j) => LegalDoc(
        type: (j['type'] ?? '') as String,
        lang: (j['lang'] ?? '') as String,
        title: (j['title'] ?? '') as String,
        html: (j['html'] ?? '') as String,
        updatedAt: j['updated_at'] == null
            ? null
            : DateTime.tryParse(j['updated_at'] as String),
      );
}

class LegalApi {
  LegalApi(this._dio);

  final Dio _dio;

  Future<LegalDoc> fetchLegal({
    required LegalType type,
    required String lang, // zh/ja/en
  }) async {
    final resp = await _dio.get(
      AppConfig.legal,
      queryParameters: {'type': type.apiValue, 'lang': lang},
      options: Options(responseType: ResponseType.json),
    );

    if (resp.data is! Map) {
      throw Exception('Invalid response: expected JSON object');
    }
    return LegalDoc.fromJson(Map<String, dynamic>.from(resp.data as Map));
  }
}