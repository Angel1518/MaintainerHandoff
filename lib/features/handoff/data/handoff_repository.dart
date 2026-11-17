import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import '../models/handoff_models.dart';

class HandoffRepository {
  HandoffRepository({Database? testDb}) : _db = testDb;

  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    final dir = await getDatabasesPath();
    _db = await openDatabase(
      p.join(dir, 'maintainer_handoff.db'),
      version: 1,
      onCreate: createSchema,
    );
    return _db!;
  }

  static Future<void> createSchema(Database db, int version) async {
    await db.execute('''
      CREATE TABLE proyectos (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        repo_url TEXT NOT NULL DEFAULT '',
        license TEXT NOT NULL DEFAULT 'MIT',
        created_at TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE items (
        id TEXT PRIMARY KEY,
        project_id TEXT NOT NULL,
        category TEXT NOT NULL,
        title TEXT NOT NULL,
        notes TEXT NOT NULL DEFAULT '',
        evidence TEXT NOT NULL DEFAULT '',
        status TEXT NOT NULL DEFAULT 'pendiente'
      )
    ''');
  }

  Future<List<Proyecto>> listProjects() async {
    final db = await database;
    final rows = await db.query('proyectos', orderBy: 'created_at DESC');
    return rows.map(Proyecto.fromMap).toList();
  }

  Future<List<HandoffItem>> listItems() async {
    final db = await database;
    final rows = await db.query('items');
    return rows.map(HandoffItem.fromMap).toList();
  }

  Future<void> saveProjectWithItems({
    required Proyecto project,
    required List<HandoffItem> items,
  }) async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.insert('proyectos', project.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace);
      for (final item in items) {
        await txn.insert('items', item.toMap(),
            conflictAlgorithm: ConflictAlgorithm.replace);
      }
    });
  }

  Future<void> upsertItem(HandoffItem item) async {
    final db = await database;
    await db.insert('items', item.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }
}

