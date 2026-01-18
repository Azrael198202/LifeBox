import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:photo_manager/photo_manager.dart';

typedef OcrProgress = void Function(double p);

class OcrExecutor {
  static final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();

  /// 基于 PhotoManager assetId 执行本地 OCR（ML Kit）。
  /// - Android 模拟器：降级为 latin（避免 chinese/japanese 类缺失崩溃）
  /// - 真机：多脚本识别 + 评分选优（优先 CJK）
  static Future<String> run({
    required String assetId,
    required OcrProgress onProgress,
  }) async {
    onProgress(0.02);

    // 1) assetId -> AssetEntity
    final asset = await AssetEntity.fromId(assetId);
    if (asset == null) {
      throw Exception('OCR: AssetEntity not found for id=$assetId');
    }

    onProgress(0.10);

    // 2) AssetEntity -> File（优先 originFile）
    File? file;
    try {
      file = await asset.originFile;
    } catch (_) {
      // ignore
    }
    file ??= await asset.file;

    if (file == null || !file.existsSync()) {
      throw Exception('OCR: cannot resolve file from assetId=$assetId');
    }

    onProgress(0.18);

    final inputImage = InputImage.fromFilePath(file.path);

    // 3) 判断是否需要降级（Android Emulator）
    final degradeToLatinOnly = await _shouldDegradeToLatinOnly();
    final scripts = degradeToLatinOnly
        ? <TextRecognitionScript>[TextRecognitionScript.latin]
        : <TextRecognitionScript>[
            TextRecognitionScript.chinese,
            TextRecognitionScript.japanese,
            TextRecognitionScript.latin,
            TextRecognitionScript.korean,
          ];

    if (kDebugMode) {
      debugPrint('OCR: platform=${Platform.operatingSystem} '
          'degradeLatinOnly=$degradeToLatinOnly scripts=${scripts.map((e) => e.name).toList()}');
    }

    // 4) 多脚本尝试 + 评分选优（遇到不可用脚本，catch 后继续）
    String bestText = '';
    double bestScore = -1;

    for (int i = 0; i < scripts.length; i++) {
      final script = scripts[i];
      final base = 0.18 + i * (0.72 / scripts.length); // 0.18 ~ 0.90
      onProgress((base + 0.03).clamp(0.0, 0.95));

      TextRecognizer? recognizer;
      try {
        // ✅ 这里有些平台/架构脚本类可能不存在，必须 try/catch
        recognizer = TextRecognizer(script: script);

        onProgress((base + 0.10).clamp(0.0, 0.95));
        final recognized = await recognizer.processImage(inputImage);

        onProgress((base + 0.16).clamp(0.0, 0.95));
        final text = _flatten(recognized).trim();

        final score = _scoreForCjk(text);

        if (kDebugMode) {
          debugPrint('OCR try script=${script.name} len=${text.length} '
              'cjkScore=$score sample="${_sample(text)}"');
        }

        if (score > bestScore) {
          bestScore = score;
          bestText = text;
        }
      } catch (e, st) {
        // ✅ 关键：某脚本不可用时不要崩，跳过即可
        if (kDebugMode) {
          debugPrint('OCR script=${script.name} failed: $e');
          debugPrint('$st');
        }
      } finally {
        try {
          await recognizer?.close();
        } catch (_) {}
      }
    }

    onProgress(0.95);

    // 5) 返回最优结果
    final result = bestText.trim();
    if (result.isEmpty) {
      throw Exception('OCR: empty result (no match) for assetId=$assetId');
    }

    onProgress(1.0);
    return result;
  }

  /// Android Emulator 上，google_mlkit_text_recognition 的 chinese/japanese
  /// 可能缺少对应 class，直接崩溃，所以必须降级为 latin。
  /// iOS Simulator/Device 一般可正常跑多脚本；即使某脚本不可用，也会被 try/catch 吃掉。
  static Future<bool> _shouldDegradeToLatinOnly() async {
    if (!Platform.isAndroid) return false;

    try {
      final android = await _deviceInfo.androidInfo;

      // ✅ 最稳：isPhysicalDevice=false 基本就是模拟器
      if (android.isPhysicalDevice == false) return true;

      // ✅ 兜底：看 fingerprint / model / brand / device 关键词
      final fingerprint = android.fingerprint.toLowerCase();
      final model = android.model.toLowerCase();
      final brand = android.brand.toLowerCase();
      final device = android.device.toLowerCase();
      final product = android.product.toLowerCase();

      final flags = '$fingerprint $model $brand $device $product';
      final isEmu = flags.contains('generic') ||
          flags.contains('emulator') ||
          flags.contains('sdk') ||
          flags.contains('x86');

      return isEmu;
    } catch (_) {
      // 如果读取不到 device info，就保守不降级（但一般不会）
      return false;
    }
  }

  static String _flatten(RecognizedText recognized) {
    final buf = StringBuffer();
    for (final block in recognized.blocks) {
      for (final line in block.lines) {
        final t = line.text.trim();
        if (t.isNotEmpty) buf.writeln(t);
      }
      buf.writeln();
    }
    return buf.toString();
  }

  /// 针对中文/日文截图的评分：
  /// - CJK 字符越多越好
  /// - 太多乱码符号扣分
  /// - 太短扣分
  static double _scoreForCjk(String text) {
    if (text.isEmpty) return -1;

    final len = text.length;

    // CJK（中日韩统一表意文字 + 日文假名）
    final cjkCount = RegExp(r'[\u4E00-\u9FFF\u3400-\u4DBF\u3040-\u30FF]')
        .allMatches(text)
        .length;

    // 拉丁字母数字
    final latinCount = RegExp(r'[A-Za-z0-9]').allMatches(text).length;

    // “疑似乱码/符号”数量（既不是空白，也不是CJK，也不是拉丁数字）
    final garbleCount = RegExp(
            r'[^\s\u4E00-\u9FFF\u3400-\u4DBF\u3040-\u30FFA-Za-z0-9，。！？：；、（）【】《》“”‘’…\-–—,.!?:"'
            '()【】\[\]]')
        .allMatches(text)
        .length;

    // 基础分：CJK 强权重
    double score = cjkCount * 10 + latinCount * 1.5 - garbleCount * 6;

    // 太短惩罚
    if (len < 15) score -= 50;

    // CJK 比例奖励
    final cjkRatio = cjkCount / len;
    score += cjkRatio * 80;

    return score;
  }

  static String _sample(String text, {int max = 30}) {
    final t = text.replaceAll('\n', ' ').trim();
    if (t.length <= max) return t;
    return '${t.substring(0, max)}…';
  }
}
