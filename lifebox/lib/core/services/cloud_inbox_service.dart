import 'dart:convert';
import 'package:http/http.dart' as http;

// 你项目里已有 record 类型就 import 你自己的
// import 'package:lifebox/domain/local_inbox_record.dart';

class CloudInboxService {
  final http.Client _client;
  final String baseUrl;

  CloudInboxService({
    http.Client? client,
    this.baseUrl = 'http://192.168.1.199:8000',
  }) : _client = client ?? http.Client();

  Future<void> saveToCloud(dynamic record) async {
    // TODO: record.toJson() 如果你有模型
    final payload = record is Map<String, dynamic>
        ? record
        : (record.toJson() as Map<String, dynamic>);

    final res = await _client.post(
      Uri.parse('$baseUrl/api/inbox/save'), // <= 按你真实后端路由改
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    );

    if (res.statusCode != 200) {
      throw Exception('saveToCloud failed: HTTP ${res.statusCode} ${res.body}');
    }
  }
}
