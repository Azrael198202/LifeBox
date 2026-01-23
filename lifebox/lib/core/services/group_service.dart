import 'dart:convert';
import 'dart:io';

import 'package:lifebox/core/network/app_config.dart';

/// =============================
/// API DTOs (match backend)
/// =============================

class GroupOutDto {
  final String id;
  final String name;
  final String groupType;
  final String ownerUserId;

  const GroupOutDto({
    required this.id,
    required this.name,
    required this.groupType,
    required this.ownerUserId,
  });

  factory GroupOutDto.fromJson(Map<String, dynamic> j) => GroupOutDto(
        id: (j['id'] ?? '').toString(),
        name: (j['name'] ?? '').toString(),
        groupType: (j['group_type'] ?? '').toString(),
        ownerUserId: (j['owner_user_id'] ?? '').toString(),
      );
}

class MembershipOutDto {
  final String userId;
  final String role; // owner | admin | member

  const MembershipOutDto({
    required this.userId,
    required this.role,
  });

  factory MembershipOutDto.fromJson(Map<String, dynamic> j) => MembershipOutDto(
        userId: (j['user_id'] ?? '').toString(),
        role: (j['role'] ?? 'member').toString(),
      );
}

class GroupDetailDto {
  final String id;
  final String name;
  final String groupType;
  final String ownerUserId;
  final List<MembershipOutDto> members;

  const GroupDetailDto({
    required this.id,
    required this.name,
    required this.groupType,
    required this.ownerUserId,
    required this.members,
  });

  factory GroupDetailDto.fromJson(Map<String, dynamic> j) => GroupDetailDto(
        id: (j['id'] ?? '').toString(),
        name: (j['name'] ?? '').toString(),
        groupType: (j['group_type'] ?? '').toString(),
        ownerUserId: (j['owner_user_id'] ?? '').toString(),
        members: ((j['members'] as List?) ?? const [])
            .map((e) => MembershipOutDto.fromJson(Map<String, dynamic>.from(e)))
            .toList(),
      );
}

class CreateInviteRespDto {
  final String inviteId;
  final String token;

  const CreateInviteRespDto({required this.inviteId, required this.token});

  factory CreateInviteRespDto.fromJson(Map<String, dynamic> j) =>
      CreateInviteRespDto(
        inviteId: (j['invite_id'] ?? '').toString(),
        token: (j['token'] ?? '').toString(),
      );
}

class AcceptInviteRespDto {
  final String groupId;
  final String role;

  const AcceptInviteRespDto({required this.groupId, required this.role});

  factory AcceptInviteRespDto.fromJson(Map<String, dynamic> j) =>
      AcceptInviteRespDto(
        groupId: (j['group_id'] ?? '').toString(),
        role: (j['role'] ?? 'member').toString(),
      );
}

/// =============================
/// Group API Service
/// =============================
class GroupService {
  GroupService({required this.getAccessToken});

  final Future<String?> Function() getAccessToken;

  Future<List<GroupOutDto>> listGroups() async {
    final decoded = await _getJsonAny(AppConfig.groups);
    if (decoded is! List) {
      throw Exception('Unexpected response: expected List');
    }
    return decoded
        .map((e) => GroupOutDto.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<GroupOutDto> createGroup({
    required String name,
    String groupType = 'family',
  }) async {
    final decoded = await _postJsonAny(AppConfig.groups, {
      'name': name,
      'group_type': groupType,
    });
    return GroupOutDto.fromJson(Map<String, dynamic>.from(decoded));
  }

  Future<GroupDetailDto> getGroupDetail(String groupId) async {
    final decoded = await _getJsonAny(AppConfig.groupDetail(groupId));
    return GroupDetailDto.fromJson(Map<String, dynamic>.from(decoded));
  }

  Future<CreateInviteRespDto> createInvite({
    required String groupId,
    String inviteeEmail = '',
    int expiresHours = 24,
  }) async {
    final decoded = await _postJsonAny(AppConfig.groupInvites(groupId), {
      'invitee_email': inviteeEmail,
      'expires_hours': expiresHours,
    });
    return CreateInviteRespDto.fromJson(Map<String, dynamic>.from(decoded));
  }

  Future<AcceptInviteRespDto> acceptInvite({required String token}) async {
    final decoded = await _postJsonAny(AppConfig.inviteAccept, {
      'token': token,
    });
    return AcceptInviteRespDto.fromJson(Map<String, dynamic>.from(decoded));
  }

  // =============================
  // Low-level HTTP helpers
  // =============================

  Future<dynamic> _getJsonAny(String url) async {
    final token = await getAccessToken();
    if (token == null || token.isEmpty) throw Exception('Not authenticated');

    final client = HttpClient();
    try {
      final req = await client.getUrl(Uri.parse(url));
      req.headers.set(HttpHeaders.acceptHeader, 'application/json');
      req.headers.set(HttpHeaders.authorizationHeader, 'Bearer $token');

      final res = await req.close();
      final body = await res.transform(utf8.decoder).join();

      if (res.statusCode < 200 || res.statusCode >= 300) {
        throw Exception('HTTP ${res.statusCode}: $body');
      }
      return jsonDecode(body);
    } finally {
      client.close(force: true);
    }
  }

  Future<dynamic> _postJsonAny(String url, Map<String, dynamic> payload) async {
    final token = await getAccessToken();
    if (token == null || token.isEmpty) throw Exception('Not authenticated');

    final client = HttpClient();
    try {
      final req = await client.postUrl(Uri.parse(url));
      req.headers.set(HttpHeaders.contentTypeHeader, 'application/json');
      req.headers.set(HttpHeaders.acceptHeader, 'application/json');
      req.headers.set(HttpHeaders.authorizationHeader, 'Bearer $token');

      req.add(utf8.encode(jsonEncode(payload)));

      final res = await req.close();
      final body = await res.transform(utf8.decoder).join();

      if (res.statusCode < 200 || res.statusCode >= 300) {
        throw Exception('HTTP ${res.statusCode}: $body');
      }
      return jsonDecode(body);
    } finally {
      client.close(force: true);
    }
  }
}
