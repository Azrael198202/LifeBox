import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:lifebox/features/inbox/domain/analyze_models.dart';

class AnalyzeService {
  static const _endpoint = 'http://192.168.1.199:8000/api/ai/analyze';

  final http.Client _client;
  AnalyzeService({http.Client? client}) : _client = client ?? http.Client();

  Future<AnalyzeResponse> analyze(AnalyzeRequest req) async {
    // ✅ payload 用 Map，不要 String?
    final payload = <String, dynamic>{
      "text": req.text,
      "locale": req.locale,
      "source_hint": req.sourceHint,
    };

    final res = await _client.post(
      Uri.parse(_endpoint),
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    );

    if (res.statusCode != 200) {
      throw Exception('Analyze failed: HTTP ${res.statusCode} ${res.body}');
    }

    final json = jsonDecode(res.body) as Map<String, dynamic>;
    return AnalyzeResponse.fromJson(json);
  }
}
