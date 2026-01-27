import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lifebox/features/auth/state/auth_providers.dart';

import '../../../core/services/analyze_service.dart';
import '../data/local_inbox_db.dart';
import '../domain/local_inbox_record.dart';

final analyzeServiceProvider = Provider((ref) => AnalyzeService());
final localInboxDbProvider = Provider((ref) => LocalInboxDb());

final localInboxListProvider =
    FutureProvider<List<LocalInboxRecord>>((ref) async {
  final auth = ref.watch(authControllerProvider);
  final uid = auth.user?.id;

  if (uid == null || uid.isEmpty) return [];

  final db = ref.watch(localInboxDbProvider);
  return db.listAllByOwner(uid);
});
