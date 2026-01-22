import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:lifebox/core/network/app_config.dart';

import 'package:lifebox/features/inbox/domain/analyze_models.dart';
import 'package:lifebox/core/network/api_exception.dart';

class AnalyzeService {
  final http.Client _client;

  AnalyzeService({http.Client? client})
      : _client = client ?? http.Client();

  Future<AnalyzeResponse> analyze(AnalyzeRequest req) async {
    final payload = <String, dynamic>{
      'text': req.text,
      'locale': req.locale,
      'source_hint': req.sourceHint,
    };

    final res = await _client.post(
      Uri.parse(AppConfig.aiAnalyze),
      headers: const {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(payload),
    );

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw ApiException.fromHttp(
        statusCode: res.statusCode,
        body: res.body,
      );
    }

    final json = jsonDecode(res.body) as Map<String, dynamic>;
    return AnalyzeResponse.fromJson(json);
  }
}
