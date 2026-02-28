import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import '../../../core/utils/logger.dart';

class DatabaseHelper {
  static const String _dbName = 'syntropy_health.db';
  static const int _dbVersion = 2;

  Database? _database;

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<void> initialize() async {
    await database;
    AppLogger.info('Database initialized', 'DatabaseHelper');
  }

  Future<Database> _initDatabase() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, _dbName);

    return openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE voice_notes (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        audio_path TEXT NOT NULL,
        duration_ms INTEGER NOT NULL,
        transcription TEXT,
        transcription_status TEXT NOT NULL DEFAULT 'pending',
        created_at TEXT,
        transcribed_at TEXT,
        error_message TEXT,
        is_processed_for_health INTEGER DEFAULT 0,
        health_entry_id TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE health_journal_entries (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        entry_type TEXT NOT NULL,
        content TEXT NOT NULL,
        transcription TEXT,
        audio_path TEXT,
        entry_date TEXT,
        sync_status TEXT NOT NULL DEFAULT 'pending',
        created_at TEXT,
        updated_at TEXT,
        is_processed INTEGER DEFAULT 0,
        metadata TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE health_recommendations (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        type TEXT NOT NULL,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        rationale TEXT,
        priority TEXT NOT NULL DEFAULT 'medium',
        related_symptoms TEXT,
        suggested_products TEXT,
        created_at TEXT,
        is_dismissed INTEGER DEFAULT 0,
        is_actioned INTEGER DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE products (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        description TEXT NOT NULL,
        category TEXT NOT NULL,
        price REAL NOT NULL,
        image_url TEXT,
        affiliate_url TEXT,
        rating REAL,
        review_count INTEGER,
        tags TEXT,
        health_benefits TEXT,
        is_available INTEGER DEFAULT 1
      )
    ''');

    await db.execute('''
      CREATE TABLE notifications (
        id TEXT PRIMARY KEY,
        type TEXT NOT NULL,
        title TEXT NOT NULL,
        message TEXT NOT NULL,
        created_at TEXT,
        scheduled_at TEXT,
        is_read INTEGER DEFAULT 0,
        is_dismissed INTEGER DEFAULT 0,
        action_route TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE sync_queue (
        id TEXT PRIMARY KEY,
        table_name TEXT NOT NULL,
        record_id TEXT NOT NULL,
        operation TEXT NOT NULL,
        data TEXT NOT NULL,
        created_at TEXT,
        retry_count INTEGER DEFAULT 0,
        last_error TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS quick_log_presets (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        entry_type TEXT NOT NULL,
        content TEXT NOT NULL,
        display_name TEXT NOT NULL DEFAULT '',
        use_count INTEGER NOT NULL DEFAULT 0,
        is_pinned INTEGER NOT NULL DEFAULT 0,
        created_at TEXT NOT NULL,
        last_used_at TEXT
      )
    ''');

    await db.execute(
        'CREATE INDEX idx_journal_sync ON health_journal_entries(sync_status)');
    await db.execute(
        'CREATE INDEX idx_journal_user ON health_journal_entries(user_id)');
    await db.execute(
        'CREATE INDEX idx_voice_notes_user ON voice_notes(user_id)');
    await db.execute(
        'CREATE INDEX idx_recommendations_user ON health_recommendations(user_id)');

    AppLogger.info('Database tables created', 'DatabaseHelper');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    AppLogger.info(
      'Database upgrade from $oldVersion to $newVersion',
      'DatabaseHelper',
    );

    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS quick_log_presets (
          id TEXT PRIMARY KEY,
          user_id TEXT NOT NULL,
          entry_type TEXT NOT NULL,
          content TEXT NOT NULL,
          display_name TEXT NOT NULL DEFAULT '',
          use_count INTEGER NOT NULL DEFAULT 0,
          is_pinned INTEGER NOT NULL DEFAULT 0,
          created_at TEXT NOT NULL,
          last_used_at TEXT
        )
      ''');
    }
  }

  Future<int> insert(String table, Map<String, dynamic> data) async {
    final db = await database;
    return db.insert(table, data, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Map<String, dynamic>>> query(
    String table, {
    String? where,
    List<Object?>? whereArgs,
    String? orderBy,
    int? limit,
    int? offset,
  }) async {
    final db = await database;
    return db.query(
      table,
      where: where,
      whereArgs: whereArgs,
      orderBy: orderBy,
      limit: limit,
      offset: offset,
    );
  }

  Future<int> update(
    String table,
    Map<String, dynamic> data, {
    String? where,
    List<Object?>? whereArgs,
  }) async {
    final db = await database;
    return db.update(table, data, where: where, whereArgs: whereArgs);
  }

  Future<int> delete(
    String table, {
    String? where,
    List<Object?>? whereArgs,
  }) async {
    final db = await database;
    return db.delete(table, where: where, whereArgs: whereArgs);
  }

  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}
