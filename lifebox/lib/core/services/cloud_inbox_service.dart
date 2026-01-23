import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:lifebox/core/network/api_exception.dart';
import 'package:lifebox/core/network/app_config.dart';
import 'package:lifebox/features/inbox/domain/cloud_detail.dart';
import 'package:lifebox/features/inbox/domain/local_inbox_record.dart';
import 'package:lifebox/features/inbox/domain/cloud_models.dart';

class CloudInboxService {
  final http.Client _client;

  CloudInboxService({http.Client? client}) : _client = client ?? http.Client();

  // =============================
  // Helpers
  // =============================

  Map<String, String> _authHeaders(String accessToken) => {
        'Authorization': 'Bearer $accessToken',
        'Accept': 'application/json',
      };

  Map<String, String> _jsonHeaders(String accessToken) => {
        ..._authHeaders(accessToken),
        'Content-Type': 'application/json',
      };

  void _throwIfNot2xx(http.Response res) {
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw ApiException.fromHttp(
        statusCode: res.statusCode,
        body: res.body,
      );
    }
  }

  // =============================
  // 1) 保存一条 inbox 记录到云端
  // POST /api/cloud/records
  // =============================
  Future<void> saveToCloud(
    LocalInboxRecord record, {
    required String accessToken,
  }) async {
    final payload = record.toJson();

    final res = await _client.post(
      Uri.parse(AppConfig.cloudSaveRecord),
      headers: _jsonHeaders(accessToken),
      body: jsonEncode(payload),
    );

    _throwIfNot2xx(res);
  }

  // =============================
  // 2) 删除云端记录
  // DELETE /api/cloud/records/{id}
  // =============================
  Future<void> deleteRecordCloud(
    String recordId, {
    required String accessToken,
  }) async {
    final res = await _client.delete(
      Uri.parse(AppConfig.cloudRecordDetail(recordId)),
      headers: _authHeaders(accessToken),
    );

    _throwIfNot2xx(res);
  }

  // =============================
  // 3) 获取本人云端记录（个人）
  // GET /api/cloud/records?limit=xx
  // （后端逻辑：owner_user_id = me AND group_id is null）
  // =============================
  Future<List<CloudListItem>> listMyRecords({
    required String accessToken,
    int limit = 50,
  }) async {
    final uri = Uri.parse(AppConfig.cloudRecord).replace(
      queryParameters: {
        'limit': '$limit',
      },
    );

    final res = await _client.get(uri, headers: _authHeaders(accessToken));
    _throwIfNot2xx(res);

    final data = jsonDecode(res.body);
    if (data is! List) return const [];

    return data
        .map((e) => CloudListItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // =============================
  // 4) 获取群组云端记录（含非本人创建）
  // GET /api/cloud/records?group_id=xxx&limit=xx
  // =============================
  Future<List<CloudListItem>> listGroupRecords({
    required String accessToken,
    required String groupId,
    int limit = 50,
  }) async {
    final uri = Uri.parse(AppConfig.cloudRecord).replace(
      queryParameters: {
        'group_id': groupId,
        'limit': '$limit',
      },
    );

    final res = await _client.get(uri, headers: _authHeaders(accessToken));
    _throwIfNot2xx(res);

    final data = jsonDecode(res.body);
    if (data is! List) return const [];

    return data
        .map((e) => CloudListItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // =============================
  // 5) 获取记录详情
  // GET /api/cloud/records/{id}
  // =============================
  Future<CloudDetail> getRecordDetail({
    required String accessToken,
    required String recordId,
  }) async {
    final res = await _client.get(
      Uri.parse(AppConfig.cloudRecordDetail(recordId)),
      headers: _authHeaders(accessToken),
    );

    _throwIfNot2xx(res);

    final map = jsonDecode(res.body) as Map<String, dynamic>;
    return CloudDetail.fromJson(map);
  }

  // =============================
  // 6) 聚合列表（个人 + 所有群组）
  // GET /api/cloud/records/all?limit=xx
  //
  // ⚠️ 需要后端你新增 /api/cloud/records/all
  // 我前面给了 py 代码
  // =============================
  Future<List<CloudListItem>> listAllVisibleRecords({
    required String accessToken,
    int limit = 50,
  }) async {
    final uri = Uri.parse(AppConfig.cloudRecords)
        .replace(queryParameters: {'limit': '$limit'});

    final res = await _client.get(uri, headers: _authHeaders(accessToken));
    _throwIfNot2xx(res);

    final data = jsonDecode(res.body);
    if (data is! List) return const [];

    return data
        .map((e) => CloudListItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  void dispose() {
    _client.close();
  }
}
