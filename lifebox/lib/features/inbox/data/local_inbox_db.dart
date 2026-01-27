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
      version: 5, // ✅ bump version
      onCreate: (db, _) async {
        await db.execute('''
CREATE TABLE $_table (
  id TEXT PRIMARY KEY,
  owner_user_id TEXT NOT NULL,
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
  created_at TEXT NOT NULL,

  -- ✅ new columns
  group_id TEXT NULL,
  color_value INTEGER NULL,
  cloud_id TEXT NULL
);
''');
        await db.execute('CREATE INDEX idx_inbox_status ON $_table(status);');
        await db.execute('CREATE INDEX idx_inbox_risk ON $_table(risk);');
        await db
            .execute('CREATE INDEX idx_inbox_group_id ON $_table(group_id);');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db
              .execute('ALTER TABLE $_table ADD COLUMN group_id TEXT NULL;');
          await db.execute(
              'ALTER TABLE $_table ADD COLUMN color_value INTEGER NULL;');
          await db.execute(
            'CREATE INDEX IF NOT EXISTS idx_inbox_group_id ON $_table(group_id);',
          );
        }

        // v3: cloud_id
        if (oldVersion < 4) {
          await db
              .execute('ALTER TABLE $_table ADD COLUMN cloud_id TEXT NULL;');
        }

        if (oldVersion < 5) {
          await db.execute(
              'ALTER TABLE $_table ADD COLUMN owner_user_id TEXT NULL;');

          await db.execute(
              "UPDATE $_table SET owner_user_id = 'unknown' WHERE owner_user_id IS NULL;");

          await db.execute(
              'CREATE INDEX IF NOT EXISTS idx_inbox_owner ON $_table(owner_user_id);');
        }
      },
    );
    return _db!;
  }

  Future<void> upsert(LocalInboxRecord r) async {
    final db = await _open();
    final v = await db.getVersion();

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
    String? status,
    String? risk,
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

  Future<int> deleteById(String id) async {
    final db = await _open();
    return db.delete(_table, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteMany(List<String> ids) async {
    if (ids.isEmpty) return 0;
    final db = await _open();
    final placeholders = List.filled(ids.length, '?').join(',');
    return db.delete(_table, where: 'id IN ($placeholders)', whereArgs: ids);
  }

  Future<int> updateStatus(String id, String status) async {
    final db = await _open();
    return db.update(
      _table,
      {'status': status},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> updateRisk(String id, String risk) async {
    final db = await _open();
    return db.update(
      _table,
      {'risk': risk},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> updateDueAt(String id, String? dueAt) async {
    final db = await _open();
    return db.update(
      _table,
      {'due_at': dueAt},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ✅ 更新 group_id / color_value
  Future<int> updateGroupAndColor(String id,
      {String? groupId, int? colorValue}) async {
    final db = await _open();
    return db.update(
      _table,
      {
        'group_id': groupId,
        'color_value': colorValue,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> purgeDone() async {
    final db = await _open();
    return db.delete(_table, where: 'status = ?', whereArgs: ['done']);
  }

  Future<int> clearAll() async {
    final db = await _open();
    return db.delete(_table);
  }

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

  Future<T> transaction<T>(Future<T> Function(Transaction txn) action) async {
    final db = await _open();
    return db.transaction(action);
  }

  Future<void> close() async {
    final db = _db;
    _db = null;
    await db?.close();
  }

  Future<List<LocalInboxRecord>> listAllByOwner(String ownerUserId) async {
    final db = await _open();
    final rows = await db.query(
      _table,
      where: 'owner_user_id = ?',
      whereArgs: [ownerUserId],
      orderBy: 'created_at DESC',
    );
    return rows.map(LocalInboxRecord.fromMap).toList();
  }

  Future<List<LocalInboxRecord>> listByOwner({
    required String ownerUserId,
    String? status,
    String? risk,
    int? limit,
    int? offset,
  }) async {
    final db = await _open();

    final where = <String>['owner_user_id = ?'];
    final args = <Object?>[ownerUserId];

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
      where: where.join(' AND '),
      whereArgs: args,
      orderBy: 'created_at DESC',
      limit: limit,
      offset: offset,
    );

    return rows.map(LocalInboxRecord.fromMap).toList();
  }

  Future<void> upsertForOwner(String ownerUserId, LocalInboxRecord r) async {
    final db = await _open();
    await db.insert(
      _table,
      r.toMap()..['owner_user_id'] = ownerUserId,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}
