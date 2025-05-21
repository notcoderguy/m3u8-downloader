import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    try {
      final path = await getDatabasesPath();
      final databasePath = join(path, 'downloads.db');
      return await openDatabase(databasePath, version: 1, onCreate: _onCreate);
    } catch (e) {
      rethrow;
    }
  }

  Future<String> getDatabasePath() async {
    final path = await getDatabasesPath();
    return join(path, 'downloads.db');
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE downloads(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        url TEXT NOT NULL,
        file_path TEXT NOT NULL,
        created_at TEXT NOT NULL,
        status TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE settings(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        key TEXT NOT NULL UNIQUE,
        value TEXT NOT NULL
      )
    ''');

    await _initializeDefaultSettings(db);
  }

  Future<void> _initializeDefaultSettings(Database db) async {
    final downloadsDir = await getDownloadsDirectory();
    final defaultOutputFolder =
        downloadsDir != null
            ? join(downloadsDir.path, 'm3u8-downloader')
            : join(await getDatabasesPath(), 'm3u8-downloader');

    await db.insert('settings', {
      'key': 'file_extension',
      'value': '.mp4',
    }, conflictAlgorithm: ConflictAlgorithm.replace);

    await db.insert('settings', {
      'key': 'thread_count',
      'value': '4',
    }, conflictAlgorithm: ConflictAlgorithm.replace);

    await db.insert('settings', {
      'key': 'output_folder',
      'value': defaultOutputFolder,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // Download methods
  Future<int> insertDownload(Map<String, dynamic> download) async {
    final db = await database;
    return await db.insert('downloads', download);
  }

  Future<List<Map<String, dynamic>>> getDownloads() async {
    final db = await database;
    return await db.query('downloads', orderBy: 'created_at DESC');
  }

  Future<int> updateDownloadStatus(int id, String status) async {
    final db = await database;
    return await db.update(
      'downloads',
      {'status': status},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<Map<String, dynamic>?> getFirstQueuedDownload() async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.query(
      'downloads',
      where: 'status = ?',
      whereArgs: ['queued'],
      orderBy: 'created_at ASC',
      limit: 1,
    );

    return result.isNotEmpty ? result.first : null;
  }

  Future<void> clearDownloads() async {
    final db = await database;
    await db.delete('downloads');
  }

  Future<void> deleteDownload(int id) async {
    final db = await database;
    await db.delete(
      'downloads',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Settings methods
  Future<int> insertSetting(String key, String value) async {
    final db = await database;
    return await db.insert('settings', {
      'key': key,
      'value': value,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<String?> getSetting(String key) async {
    final db = await database;
    final result = await db.query(
      'settings',
      where: 'key = ?',
      whereArgs: [key],
      limit: 1,
    );
    return result.isNotEmpty ? result.first['value'] as String? : null;
  }
}
