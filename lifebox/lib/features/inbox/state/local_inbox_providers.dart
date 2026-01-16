import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/analyze_service.dart';
import '../data/local_inbox_db.dart';
import '../domain/local_inbox_record.dart';

final analyzeServiceProvider = Provider((ref) => AnalyzeService());
final localInboxDbProvider = Provider((ref) => LocalInboxDb());

final localInboxListProvider =
    FutureProvider<List<LocalInboxRecord>>((ref) async {
  final db = ref.watch(localInboxDbProvider);
  return db.listAll();
});
