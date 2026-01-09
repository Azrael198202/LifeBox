typedef OcrProgress = void Function(double p);

class OcrExecutor {
  static Future<String> run({
    required String assetId,
    required OcrProgress onProgress,
  }) async {
    // TODO：替换成真实 OCR：
    // - iOS Vision OCR（platform channel）
    // - 或上传服务端排队 OCR
    onProgress(0.10);
    await Future.delayed(const Duration(milliseconds: 250));

    onProgress(0.35);
    await Future.delayed(const Duration(milliseconds: 450));

    onProgress(0.70);
    await Future.delayed(const Duration(milliseconds: 500));

    onProgress(0.95);
    await Future.delayed(const Duration(milliseconds: 200));

    return 'OCR_RESULT_TEXT($assetId)';
  }
}
