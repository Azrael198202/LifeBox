import 'dart:math';

import '../domain/analyze_models.dart';
import '../domain/local_inbox_record.dart';

class AnalyzeService {
  /// ✅ 现在先做 mock：模拟调用 192.168.1.199:8000/api/ai/analyze
  Future<AnalyzeResponse> analyze(AnalyzeRequest req) async {
    await Future.delayed(const Duration(milliseconds: 650)); // 模拟网络耗时

    // ---- 超简易解析（你之后接真 API 时直接替换这里）----
    // final text = req.text;
    String text = "銀行より：クレジットカードのお支払い期限は1/20です。金額3万円。";

    // amount
    int? amount;
    if (text.contains('3万円')) amount = 30000;
    // due date "1/20" -> "2026-01-20"（示例：用当前年）
    String? dueAt;
    final m = RegExp(r'(\d{1,2})/(\d{1,2})').firstMatch(text);
    if (m != null) {
      final mm = int.parse(m.group(1)!);
      final dd = int.parse(m.group(2)!);
      final now = DateTime.now();
      dueAt =
          '${now.year.toString().padLeft(4, '0')}-${mm.toString().padLeft(2, '0')}-${dd.toString().padLeft(2, '0')}';
    }

    final risk = () {
      if (text.contains('期限') || text.contains('支払い')) return 'high';
      final r = Random().nextInt(10);
      if (r < 3) return 'mid';
      return 'low';
    }();

    return AnalyzeResponse(
      title: '${req.sourceHint}：支払い期限の通知',
      summary: text,
      dueAt: dueAt,
      amount: amount,
      currency: amount != null ? 'JPY' : null,
      risk: risk,
      source: req.sourceHint,
    );
  }

  /// ✅ 云保存（收费）——先做 mock
  Future<void> saveToCloud(LocalInboxRecord record) async {
    await Future.delayed(const Duration(milliseconds: 550));
    // TODO: 未来接真实 API：POST /api/inbox/save
  }
}
