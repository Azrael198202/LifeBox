import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// Nager.Date holiday model
class Holiday {
  Holiday({
    required this.date,
    required this.localName,
    required this.name,
    required this.countryCode,
    this.types = const [],
  });

  final DateTime date; // yyyy-MM-dd (00:00 local)
  final String localName;
  final String name;
  final String countryCode;
  final List<String> types;

  String displayName(Locale locale) {
    // ✅ “按 locale 自动选 name/localName”
    // - 英文界面：显示 name（英文）
    // - 非英文：优先 localName（本地语言）
    // 说明：Nager.Date 对 CN 通常 localName=中文，对 JP localName=日文
    return (locale.languageCode.toLowerCase() == 'en') ? name : localName;
  }

  Map<String, dynamic> toJson() => {
        'date': _ymd(date),
        'localName': localName,
        'name': name,
        'countryCode': countryCode,
        'types': types,
      };

  static Holiday fromJson(Map<String, dynamic> j) {
    final d = DateTime.parse(j['date'] as String);
    return Holiday(
      date: DateTime(d.year, d.month, d.day),
      localName: (j['localName'] ?? '') as String,
      name: (j['name'] ?? '') as String,
      countryCode: (j['countryCode'] ?? '') as String,
      types: (j['types'] as List?)?.map((e) => e.toString()).toList() ?? const [],
    );
  }

  static String _ymd(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}

class HolidayService {
  HolidayService({
    http.Client? client,
    SharedPreferences? prefs,
    this.cacheTtl = const Duration(days: 30),
  })  : _client = client ?? http.Client(),
        _prefsFuture = prefs != null ? Future.value(prefs) : SharedPreferences.getInstance();

  final http.Client _client;
  final Future<SharedPreferences> _prefsFuture;

  /// Duration for cache validity defaults to 30 days
  final Duration cacheTtl;

  static const _base = 'https://date.nager.at/api/v3/PublicHolidays';

  String _cacheKey(int year, String countryCode) => 'holidays_v1_${countryCode}_$year';
  String _cacheTimeKey(int year, String countryCode) => 'holidays_v1_${countryCode}_${year}_ts';

  /// get public holidays for a specific year and country code
  Future<List<Holiday>> getPublicHolidays({
    required int year,
    required String countryCode, // e.g. "JP", "CN"
    bool forceRefresh = false,
  }) async {
    final prefs = await _prefsFuture;

    // 1) 读缓存
    if (!forceRefresh) {
      final cached = prefs.getString(_cacheKey(year, countryCode));
      final ts = prefs.getInt(_cacheTimeKey(year, countryCode));
      if (cached != null && ts != null) {
        final age = DateTime.now().millisecondsSinceEpoch - ts;
        if (age <= cacheTtl.inMilliseconds) {
          try {
            final arr = (jsonDecode(cached) as List).cast<Map<String, dynamic>>();
            return arr.map(Holiday.fromJson).toList();
          } catch (_) {
            // exception ignored
          }
        }
      }
    }

    // 2) request
    final url = Uri.parse('$_base/$year/$countryCode');
    final resp = await _client.get(url);
    if (resp.statusCode < 200 || resp.statusCode >= 300) {
      // 3) requst failture, and read cache as fallback
      final cached = prefs.getString(_cacheKey(year, countryCode));
      if (cached != null) {
        try {
          final arr = (jsonDecode(cached) as List).cast<Map<String, dynamic>>();
          return arr.map(Holiday.fromJson).toList();
        } catch (_) {}
      }
      throw Exception('Holiday API failed: ${resp.statusCode}');
    }

    final data = jsonDecode(resp.body) as List;
    final list = data.map((e) {
      final m = (e as Map).cast<String, dynamic>();
      final d = DateTime.parse(m['date'] as String);
      return Holiday(
        date: DateTime(d.year, d.month, d.day),
        localName: (m['localName'] ?? '') as String,
        name: (m['name'] ?? '') as String,
        countryCode: (m['countryCode'] ?? '') as String,
        types: (m['types'] as List?)?.map((x) => x.toString()).toList() ?? const [],
      );
    }).toList();

    // 4) write cache
    await prefs.setString(
      _cacheKey(year, countryCode),
      jsonEncode(list.map((e) => e.toJson()).toList()),
    );
    await prefs.setInt(
      _cacheTimeKey(year, countryCode),
      DateTime.now().millisecondsSinceEpoch,
    );

    return list;
  }

  /// combine：get CN and JP holidays for a specific year, grouped by day
  Future<Map<DateTime, List<Holiday>>> getCnJpHolidaysByDay({
    required int year,
    bool forceRefresh = false,
  }) async {
    final results = await Future.wait([
      getPublicHolidays(year: year, countryCode: 'JP', forceRefresh: forceRefresh),
      getPublicHolidays(year: year, countryCode: 'CN', forceRefresh: forceRefresh),
    ]);

    final all = <Holiday>[...results[0], ...results[1]];

    final map = <DateTime, List<Holiday>>{};
    for (final h in all) {
      final key = DateTime(h.date.year, h.date.month, h.date.day);
      map.putIfAbsent(key, () => []).add(h);
    }
    // get sorted list: JP first, then by country code
    for (final e in map.entries) {
      e.value.sort((a, b) => a.countryCode.compareTo(b.countryCode)); // "CN" < "JP"
      // jp is the first
      e.value.sort((a, b) => (a.countryCode == 'JP' ? -1 : 1));
    }
    return map;
  }
}
