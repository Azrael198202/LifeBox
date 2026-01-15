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

  Future<void> close() async {
    await _db?.close();
    _db = null;
  }
}
