import 'package:flutter_riverpod/flutter_riverpod.dart';

enum ImportJobStatus { queued, ocr, uploading, parsing, done, failed }

class ImportJob {
  final String id;
  final String name;
  final ImportJobStatus status;

  ImportJob({required this.id, required this.name, required this.status});

  ImportJob copyWith({ImportJobStatus? status}) =>
      ImportJob(id: id, name: name, status: status ?? this.status);
}

class ImportController extends StateNotifier<List<ImportJob>> {
  ImportController() : super([]);

  Future<void> simulateImport(List<String> names) async {
    state = [
      for (var i = 0; i < names.length; i++)
        ImportJob(id: '${DateTime.now().millisecondsSinceEpoch}-$i', name: names[i], status: ImportJobStatus.queued),
    ];

    // 模拟状态机：queued -> ocr -> uploading -> parsing -> done
    for (var idx = 0; idx < state.length; idx++) {
      await Future.delayed(const Duration(milliseconds: 400));
      _set(idx, ImportJobStatus.ocr);
      await Future.delayed(const Duration(milliseconds: 500));
      _set(idx, ImportJobStatus.uploading);
      await Future.delayed(const Duration(milliseconds: 500));
      _set(idx, ImportJobStatus.parsing);
      await Future.delayed(const Duration(milliseconds: 500));
      _set(idx, ImportJobStatus.done);
    }
  }

  void _set(int idx, ImportJobStatus s) {
    final copy = [...state];
    copy[idx] = copy[idx].copyWith(status: s);
    state = copy;
  }

  void clear() => state = [];
}

final importControllerProvider =
    StateNotifierProvider<ImportController, List<ImportJob>>((ref) => ImportController());
