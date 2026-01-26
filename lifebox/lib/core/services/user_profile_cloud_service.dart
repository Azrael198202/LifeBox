import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:lifebox/core/network/app_config.dart';

class UserProfileCloudService {
  UserProfileCloudService({required this.getAccessToken});

  final Future<String?> Function() getAccessToken;

  Future<Map<String, dynamic>> patchMe({
    String? displayName,
    String? avatarUrl,
  }) async {
    final token = await getAccessToken();
    if (token == null || token.isEmpty) {
      throw Exception('Not logged in');
    }

    final body = <String, dynamic>{};
    if (displayName != null) body['display_name'] = displayName;
    if (avatarUrl != null) body['avatar_url'] = avatarUrl;

    if (body.isEmpty) {
      throw Exception('No fields to update');
    }

    final resp = await http.patch(
      Uri.parse(AppConfig.authMe),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );

    if (resp.statusCode >= 400) {
      throw Exception('patchMe failed: ${resp.statusCode} ${resp.body}');
    }
    return jsonDecode(resp.body) as Map<String, dynamic>;
  }
}