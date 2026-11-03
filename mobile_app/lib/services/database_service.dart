import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

/// Dịch vụ quản lý cơ sở dữ liệu SQLite cục bộ (Sqflite)
/// Chỉ lưu trữ kho truyện của thiết bị (chế độ Khách chưa đăng nhập).
/// Khi đăng nhập, dữ liệu tủ truyện được quản lý và lấy trực tiếp từ máy chủ Backend.
class DatabaseService {
  DatabaseService._();
  static final DatabaseService instance = DatabaseService._();

  static const String _dbName = 'novel_library.db';
  static const int _dbVersion = 3;

  // Bảng cho kho thiết bị (Local Store)
  static const String tableLocalHistory = 'local_reading_history';
  static const String tableLocalBookmarks = 'local_bookmarks';

  // Tên bảng legacy để di chuyển dữ liệu cũ nếu có
  static const String tableLegacyHistory = 'reading_history';
  static const String tableLegacyBookmarks = 'bookmarks';

  Database? _database;

  // Fallback in-memory map khi chạy trên môi trường test hoặc web không hỗ trợ sqflite native
  final Map<String, Map<String, dynamic>> _inMemoryLocalHistory = {};
  final Set<String> _inMemoryLocalBookmarks = {};
  bool _useFallback = false;

  Future<Database?> get database async {
    if (_useFallback || kIsWeb) return null;
    if (_database != null) return _database;
    try {
      _database = await _initDatabase();
      return _database;
    } catch (e) {
      debugPrint('Sqflite init failed, using in-memory fallback: $e');
      _useFallback = true;
      return null;
    }
  }

  Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, _dbName);

    return await openDatabase(
      path,
      version: _dbVersion,
      onCreate: (db, version) async {
        await _createTables(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        await _createTables(db);
        // Dọn dẹp các bảng account_* cũ nếu có từ version 2
        try {
          await db.execute('DROP TABLE IF EXISTS account_reading_history');
          await db.execute('DROP TABLE IF EXISTS account_bookmarks');
        } catch (_) {}
      },
      onOpen: (db) async {
        await _createTables(db);
        await _migrateLegacyData(db);
      },
    );
  }

  Future<void> _createTables(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $tableLocalHistory (
        comic_id TEXT PRIMARY KEY,
        current_chapter INTEGER NOT NULL,
        notify_enabled INTEGER NOT NULL DEFAULT 1,
        updated_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS $tableLocalBookmarks (
        comic_id TEXT PRIMARY KEY,
        created_at TEXT NOT NULL
      )
    ''');
  }

  Future<void> _migrateLegacyData(Database db) async {
    try {
      final localHCount = Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM $tableLocalHistory'),
      ) ?? 0;
      if (localHCount == 0) {
        final legacyH = await db.rawQuery(
          "SELECT name FROM sqlite_master WHERE type='table' AND name='$tableLegacyHistory'",
        );
        if (legacyH.isNotEmpty) {
          await db.execute('INSERT OR REPLACE INTO $tableLocalHistory SELECT * FROM $tableLegacyHistory');
        }
      }

      final localBCount = Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM $tableLocalBookmarks'),
      ) ?? 0;
      if (localBCount == 0) {
        final legacyB = await db.rawQuery(
          "SELECT name FROM sqlite_master WHERE type='table' AND name='$tableLegacyBookmarks'",
        );
        if (legacyB.isNotEmpty) {
          await db.execute('INSERT OR REPLACE INTO $tableLocalBookmarks SELECT * FROM $tableLegacyBookmarks');
        }
      }
    } catch (e) {
      debugPrint('Legacy migration note: $e');
    }
  }

  // ====================================================================
  // KHO TRUYỆN THIẾT BỊ (LOCAL STORE)
  // ====================================================================

  Future<List<Map<String, dynamic>>> getLocalHistory() async {
    final db = await database;
    if (db == null) {
      final list = _inMemoryLocalHistory.values.toList();
      list.sort((a, b) => (b['updated_at'] as String).compareTo(a['updated_at'] as String));
      return list;
    }

    try {
      return await db.query(tableLocalHistory, orderBy: 'updated_at DESC');
    } catch (e) {
      debugPrint('Lỗi đọc local history: $e');
      return [];
    }
  }

  Future<void> saveLocalHistory({
    required String comicId,
    required int currentChapter,
    bool notifyEnabled = true,
  }) async {
    final now = DateTime.now().toIso8601String();
    final row = {
      'comic_id': comicId,
      'current_chapter': currentChapter,
      'notify_enabled': notifyEnabled ? 1 : 0,
      'updated_at': now,
    };

    final db = await database;
    if (db == null) {
      _inMemoryLocalHistory[comicId] = row;
      return;
    }

    try {
      await db.insert(
        tableLocalHistory,
        row,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      debugPrint('Lỗi lưu local history: $e');
      _inMemoryLocalHistory[comicId] = row;
    }
  }

  Future<void> updateLocalNotify(String comicId, bool notifyEnabled) async {
    final db = await database;
    if (db == null) {
      if (_inMemoryLocalHistory.containsKey(comicId)) {
        _inMemoryLocalHistory[comicId]!['notify_enabled'] = notifyEnabled ? 1 : 0;
      }
      return;
    }

    try {
      await db.update(
        tableLocalHistory,
        {'notify_enabled': notifyEnabled ? 1 : 0},
        where: 'comic_id = ?',
        whereArgs: [comicId],
      );
    } catch (e) {
      debugPrint('Lỗi update local notify: $e');
    }
  }

  Future<void> deleteLocalHistory(String comicId) async {
    final db = await database;
    if (db == null) {
      _inMemoryLocalHistory.remove(comicId);
      return;
    }

    try {
      await db.delete(tableLocalHistory, where: 'comic_id = ?', whereArgs: [comicId]);
    } catch (e) {
      debugPrint('Lỗi delete local history: $e');
    }
  }

  Future<void> clearLocalHistory() async {
    final db = await database;
    if (db == null) {
      _inMemoryLocalHistory.clear();
      return;
    }

    try {
      await db.delete(tableLocalHistory);
    } catch (e) {
      debugPrint('Lỗi clear local history: $e');
    }
  }

  Future<Set<String>> getLocalBookmarks() async {
    final db = await database;
    if (db == null) {
      return Set.from(_inMemoryLocalBookmarks);
    }

    try {
      final rows = await db.query(tableLocalBookmarks);
      return rows.map((r) => r['comic_id'] as String).toSet();
    } catch (e) {
      debugPrint('Lỗi get local bookmarks: $e');
      return {};
    }
  }

  Future<void> addLocalBookmark(String comicId) async {
    final db = await database;
    if (db == null) {
      _inMemoryLocalBookmarks.add(comicId);
      return;
    }

    try {
      await db.insert(
        tableLocalBookmarks,
        {
          'comic_id': comicId,
          'created_at': DateTime.now().toIso8601String(),
        },
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    } catch (e) {
      debugPrint('Lỗi add local bookmark: $e');
      _inMemoryLocalBookmarks.add(comicId);
    }
  }

  Future<void> removeLocalBookmark(String comicId) async {
    final db = await database;
    if (db == null) {
      _inMemoryLocalBookmarks.remove(comicId);
      return;
    }

    try {
      await db.delete(tableLocalBookmarks, where: 'comic_id = ?', whereArgs: [comicId]);
    } catch (e) {
      debugPrint('Lỗi remove local bookmark: $e');
      _inMemoryLocalBookmarks.remove(comicId);
    }
  }

  Future<void> clearLocalBookmarks() async {
    final db = await database;
    if (db == null) {
      _inMemoryLocalBookmarks.clear();
      return;
    }

    try {
      await db.delete(tableLocalBookmarks);
    } catch (e) {
      debugPrint('Lỗi clear local bookmarks: $e');
    }
  }
}
