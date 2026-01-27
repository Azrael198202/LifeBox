import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:photo_manager/photo_manager.dart';

typedef OcrProgress = void Function(double p);

class OcrExecutor {
  static final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();

  /// Perform local OCR (ML Kit) based on PhotoManager assetId.
  ///
  /// Platform behavior:
  /// - Android Emulator:
  /// Fallback to Latin script only
  /// (to avoid crashes caused by missing Chinese/Japanese script classes).
  /// - Physical device:
  /// Use multi-script recognition with scoring and select the best result
  /// (CJK scripts are preferred).
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

    // 2) AssetEntity -> File（ first select the originFile）
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

    // 3) Determine whether fallback is required (Android Emulator).
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

    // 4) Try multiple scripts and select the best result by score.
    /// - If a script is unavailable, catch the exception and continue.
    String bestText = '';
    double bestScore = -1;

    for (int i = 0; i < scripts.length; i++) {
      final script = scripts[i];
      final base = 0.18 + i * (0.72 / scripts.length); // 0.18 ~ 0.90
      onProgress((base + 0.03).clamp(0.0, 0.95));

      TextRecognizer? recognizer;
      try {
        /// Important notes:
        /// - On Android Emulator, `google_mlkit_text_recognition` may lack
        /// Chinese/Japanese related classes, which causes a hard crash.
        /// Therefore, falling back to Latin is mandatory.
        /// - On iOS Simulator / physical devices, multi-script recognition
        /// generally works.
        /// Even if a script is unavailable, it will be safely handled by try/catch.
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

    // 5) return best result
    final result = bestText.trim();
    if (result.isEmpty) {
      throw Exception('OCR: empty result (no match) for assetId=$assetId');
    }

    onProgress(1.0);
    return result;
  }

  /// Emulator detection strategy:
  /// - Most reliable: `isPhysicalDevice == false` → emulator.
  /// - Fallback: check device info keywords
  /// (fingerprint / model / brand / device).
  /// - If device info cannot be read, do NOT fallback conservatively
  /// (this case is rare).
  static Future<bool> _shouldDegradeToLatinOnly() async {
    if (!Platform.isAndroid) return false;

    try {
      final android = await _deviceInfo.androidInfo;

      if (android.isPhysicalDevice == false) return true;

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

  /// Scoring strategy for Chinese / Japanese screenshots:
  /// - More CJK characters → higher score.
  /// - Penalize excessive garbled or invalid symbols.
  /// - Penalize text that is too short.
  static double _scoreForCjk(String text) {
    if (text.isEmpty) return -1;

    final len = text.length;

    /// - CJK: Unified CJK ideographs + Japanese kana.
    final cjkCount = RegExp(r'[\u4E00-\u9FFF\u3400-\u4DBF\u3040-\u30FF]')
        .allMatches(text)
        .length;

    /// - Latin: letters and digits.
    final latinCount = RegExp(r'[A-Za-z0-9]').allMatches(text).length;

    /// - Garbage symbols: characters that are
    /// not whitespace, not CJK, and not Latin/digits.
    final garbleCount = RegExp(
            r'[^\s\u4E00-\u9FFF\u3400-\u4DBF\u3040-\u30FFA-Za-z0-9，。！？：；、（）【】《》“”‘’…\-–—,.!?:"'
            '()【】\[\]]')
        .allMatches(text)
        .length;

    /// - Base score: strong weight for CJK characters.
    double score = cjkCount * 10 + latinCount * 1.5 - garbleCount * 6;

    /// - Length penalty for very short text.
    if (len < 15) score -= 50;

    /// - Bonus for higher CJK ratio.
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
