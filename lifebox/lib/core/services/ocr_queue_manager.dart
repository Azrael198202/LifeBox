import 'dart:collection';
import 'package:flutter/foundation.dart';
import 'ocr_executor.dart';

enum OcrJobStatus { queued, running, success, failed }

class OcrJob {
  final String assetId;
  final DateTime createdAt;

  OcrJobStatus status;
  double progress;
  String? resultText;
  String? error;

  OcrJob({
    required this.assetId,
    required this.createdAt,
    this.status = OcrJobStatus.queued,
    this.progress = 0,
    this.resultText,
    this.error,
  });
}

class OcrQueueManager extends ChangeNotifier {
  final Queue<OcrJob> _queue = Queue<OcrJob>();
  final List<OcrJob> _completed = <OcrJob>[];
  OcrJob? _current;
  bool _working = false;

  OcrJob? get current => _current;
  List<OcrJob> get queuedJobs => List.unmodifiable(_queue);
  List<OcrJob> get allJobs {
    final list = <OcrJob>[];
    if (_current != null) list.add(_current!);
    list.addAll(_queue);
    return List.unmodifiable(list);
  }

  /// ✅ 已完成（success/failed）的任务（最新在前）
  List<OcrJob> get completedJobs => List.unmodifiable(_completed);

  int get queuedCount => _queue.length;
  int get completedCount => _completed.length;

  void enqueueMany(List<String> assetIds) {
    final now = DateTime.now();

    for (final id in assetIds) {
      final existsInQueue = _queue.any((j) => j.assetId == id);
      final isCurrent = _current?.assetId == id;
      final existsInCompleted =
          _completed.any((j) => j.assetId == id); // ✅ 可选：避免重复跑
      if (existsInQueue || isCurrent || existsInCompleted) continue;

      _queue.add(OcrJob(assetId: id, createdAt: now));
    }

    notifyListeners();
    _startIfNeeded();
  }

  void clearQueued() {
    _queue.clear();
    notifyListeners();
  }

  /// ✅ 清空历史结果
  void clearCompleted() {
    _completed.clear();
    notifyListeners();
  }

  void _startIfNeeded() {
    if (_working) return;
    _working = true;
    _pump();
  }

  Future<void> _pump() async {
    while (_queue.isNotEmpty) {
      _current = _queue.removeFirst();
      _current!.status = OcrJobStatus.running;
      _current!.progress = 0;
      notifyListeners();

      try {
        final text = await OcrExecutor.run(
          assetId: _current!.assetId,
          onProgress: (p) {
            _current!.progress = p.clamp(0, 1);
            notifyListeners();
          },
        );

        _current!.status = OcrJobStatus.success;
        _current!.progress = 1;
        _current!.resultText = text;
      } catch (e) {
        _current!.status = OcrJobStatus.failed;
        _current!.error = e.toString();
      }

      // ✅ 放入历史列表（最新在前）
      _completed.insert(0, _current!);

      // ✅ 可选：限制历史数量，避免无限增长
      if (_completed.length > 300) {
        _completed.removeRange(300, _completed.length);
      }

      notifyListeners();
      _current = null;
    }

    _working = false;
    notifyListeners();
  }
}
