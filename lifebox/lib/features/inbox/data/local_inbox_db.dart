import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import '../domain/local_inbox_record.dart';

class LocalInboxDb {
  static const _dbName = 'lifebox_local.db';
  static const _table = 'inbox_items';

  Database? _db;

  Future<Database> _open() async {
    if (_db != null) return _db!;
    final dir = await getDatabasesPath();
    final path = p.join(dir, _dbName);

    _db = await openDatabase(
      path,
      version: 1,
      onCreate: (db, _) async {
        await db.execute('''
CREATE TABLE $_table (
  id TEXT PRIMARY KEY,
  raw_text TEXT NOT NULL,
  locale TEXT NOT NULL,
  source_hint TEXT NOT NULL,
  title TEXT NOT NULL,
  summary TEXT NOT NULL,
  due_at TEXT NULL,
  amount INTEGER NULL,
  currency TEXT NULL,
  risk TEXT NOT NULL,
  status TEXT NOT NULL,
  created_at TEXT NOT NULL
);
''');
        await db.execute('CREATE INDEX idx_inbox_status ON $_table(status);');
        await db.execute('CREATE INDEX idx_inbox_risk ON $_table(risk);');
      },
    );
    return _db!;
  }

  Future<void> upsert(LocalInboxRecord r) async {
    final db = await _open();
    await db.insert(
      _table,
      r.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<LocalInboxRecord>> listAll() async {
    final db = await _open();
    final rows = await db.query(
      _table,
      orderBy: 'created_at DESC',
    );
    return rows.map(LocalInboxRecord.fromMap).toList();
  }

  Future<List<LocalInboxRecord>> list({
    String? status, // 'pending' / 'done' 等
    String? risk, // 'high' / 'mid' / 'low'
    int? limit,
    int? offset,
  }) async {
    final db = await _open();

    final where = <String>[];
    final args = <Object?>[];

    if (status != null) {
      where.add('status = ?');
      args.add(status);
    }
    if (risk != null) {
      where.add('risk = ?');
      args.add(risk);
    }

    final rows = await db.query(
      _table,
      where: where.isEmpty ? null : where.join(' AND '),
      whereArgs: args.isEmpty ? null : args,
      orderBy: 'created_at DESC',
      limit: limit,
      offset: offset,
    );

    return rows.map(LocalInboxRecord.fromMap).toList();
  }

  /// ✅按 id 获取
  Future<LocalInboxRecord?> getById(String id) async {
    final db = await _open();
    final rows = await db.query(
      _table,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return LocalInboxRecord.fromMap(rows.first);
  }

  /// ✅ 批量 upsert（OCR 多条/队列很常用）
  Future<void> upsertMany(List<LocalInboxRecord> items) async {
    if (items.isEmpty) return;
    final db = await _open();
    await db.transaction((txn) async {
      final batch = txn.batch();
      for (final r in items) {
        batch.insert(
          _table,
          r.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
      await batch.commit(noResult: true);
    });
  }

  /// ✅ 删除（用于 Swipe 删除）
  Future<int> deleteById(String id) async {
    final db = await _open();
    return db.delete(_table, where: 'id = ?', whereArgs: [id]);
  }

  /// ✅ 批量删除
  Future<int> deleteMany(List<String> ids) async {
    if (ids.isEmpty) return 0;
    final db = await _open();
    final placeholders = List.filled(ids.length, '?').join(',');
    return db.delete(_table, where: 'id IN ($placeholders)', whereArgs: ids);
  }

  /// ✅ 更新 status（pending/done）
  Future<int> updateStatus(String id, String status) async {
    final db = await _open();
    return db.update(
      _table,
      {'status': status},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// ✅ 更新风险（high/mid/low）
  Future<int> updateRisk(String id, String risk) async {
    final db = await _open();
    return db.update(
      _table,
      {'risk': risk},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// ✅ 更新 due_at（yyyy-mm-dd 或 null）
  Future<int> updateDueAt(String id, String? dueAt) async {
    final db = await _open();
    return db.update(
      _table,
      {'due_at': dueAt},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// ✅ 清空已完成（用于“整理/释放空间”）
  Future<int> purgeDone() async {
    final db = await _open();
    return db.delete(_table, where: 'status = ?', whereArgs: ['done']);
  }

  /// ✅ 全部清空（调试用）
  Future<int> clearAll() async {
    final db = await _open();
    return db.delete(_table);
  }

  /// ✅ 统计（给 Tab 数字用）
  Future<Map<String, int>> countByStatus() async {
    final db = await _open();
    final rows = await db.rawQuery('''
SELECT status, COUNT(*) as cnt
FROM $_table
GROUP BY status
''');
    final map = <String, int>{};
    for (final r in rows) {
      map[(r['status'] as String?) ?? ''] = (r['cnt'] as int?) ?? 0;
    }
    return map;
  }

  /// ✅ 事务工具（需要时可用）
  Future<T> transaction<T>(Future<T> Function(Transaction txn) action) async {
    final db = await _open();
    return db.transaction(action);
  }

  Future<void> close() async {
    final db = _db;
    _db = null;
    await db?.close();
  }

  
}
