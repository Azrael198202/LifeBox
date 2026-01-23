import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:lifebox/core/network/api_exception.dart';
import 'package:lifebox/core/network/app_config.dart';
import 'package:lifebox/features/inbox/domain/local_inbox_record.dart';

class CloudInboxService {
  final http.Client _client;

  CloudInboxService({http.Client? client})
      : _client = client ?? http.Client();

  /// 保存一条 inbox 记录到云端
  /// - record: LocalInboxRecord
  /// - accessToken: JWT（从 AuthController 传入）
  Future<void> saveToCloud(
    LocalInboxRecord record, {
    required String accessToken,
  }) async {
    final payload = record.toJson();

    final res = await _client.post(
      Uri.parse(AppConfig.cloudSaveRecord), 
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken', // ✅ 认证
      },
      body: jsonEncode(payload),
    );

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw ApiException.fromHttp(
        statusCode: res.statusCode,
        body: res.body,
      );
    }
  }

Future<void> deleteRecordCloud(
  String recordId, {
  required String accessToken,
}) async {
  final res = await _client.delete(
    Uri.parse(AppConfig.cloudRecordDetail(recordId)),
    headers: {
      'Authorization': 'Bearer $accessToken',
      'Accept': 'application/json',
    },
  );

  if (res.statusCode < 200 || res.statusCode >= 300) {
    throw ApiException.fromHttp(
      statusCode: res.statusCode,
      body: res.body,
    );
  }
}

}
