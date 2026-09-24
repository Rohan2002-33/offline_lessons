import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/lesson.dart';
import '../models/completion.dart';

class LocalDbService {
  static final LocalDbService instance = LocalDbService._internal();
  LocalDbService._internal();
  Database? _db;

  Future<Database> get db async {
    _db ??= await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final path = join(await getDatabasesPath(), 'offline_lessons.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE lessons (
            id TEXT PRIMARY KEY,
            title TEXT,
            content TEXT,
            module TEXT,
            order_index INTEGER,
            updated_at TEXT
          )
        ''');
        await db.execute('''
          CREATE TABLE completions (
            id TEXT PRIMARY KEY,
            user_id TEXT,
            lesson_id TEXT,
            completed_at TEXT,
            client_updated_at TEXT,
            synced INTEGER DEFAULT 0
          )
        ''');
      },
    );
  }

  // ---- Lessons (read cache) ----
  Future<void> upsertLessons(List<Lesson> lessons) async {
    final database = await db;
    final batch = database.batch();
    for (final l in lessons) {
      batch.insert('lessons', l.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit(noResult: true);
  }

  Future<List<Lesson>> getCachedLessons() async {
    final database = await db;
    final rows = await database.query('lessons', orderBy: 'order_index ASC');
    return rows.map((r) => Lesson.fromMap(r)).toList();
  }

  // ---- Completions (mutation queue) ----
  Future<void> queueCompletion(Completion c) async {
    final database = await db;
    await database.insert('completions', c.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Completion>> getUnsyncedCompletions() async {
    final database = await db;
    final rows =
        await database.query('completions', where: 'synced = 0');
    return rows.map((r) => Completion.fromMap(r)).toList();
  }

  Future<void> markSynced(String id) async {
    final database = await db;
    await database.update('completions', {'synced': 1},
        where: 'id = ?', whereArgs: [id]);
  }

  Future<Set<String>> getCompletedLessonIds() async {
    final database = await db;
    final rows = await database.query('completions');
    return rows.map((r) => r['lesson_id'] as String).toSet();
  }
}