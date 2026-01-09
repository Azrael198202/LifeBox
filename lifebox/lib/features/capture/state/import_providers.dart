import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'import_controller.dart';
import '../../../core/services/ocr_queue_manager.dart';

final importControllerProvider =
    ChangeNotifierProvider<ImportController>((ref) {
  final c = ImportController();
  // 也可以在这里触发 init（一次性），但建议在页面里触发更直观
  return c;
});

final ocrQueueManagerProvider =
    ChangeNotifierProvider<OcrQueueManager>((ref) {
  return OcrQueueManager();
});
