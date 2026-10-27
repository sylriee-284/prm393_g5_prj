import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

/// Dịch vụ quản lý cơ sở dữ liệu SQLite cục bộ (Sqflite) cho ứng dụng di động
class DatabaseService {
  DatabaseService._();
  static final DatabaseService instance = DatabaseService._();

  static const String _dbName = 'novel_library.db';
  static const int _dbVersion = 1;

  static const String tableHistory = 'reading_history';
  static const String tableBookmarks = 'bookmarks';

  Database? _database;

  // Fallback in-memory map khi chạy trên môi trường test hoặc web không hỗ trợ sqflite native
  final Map<String, Map<String, dynamic>> _inMemoryHistory = {};
  final Set<String> _inMemoryBookmarks = {};
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
        // 1. Bảng lưu trữ lịch sử các truyện người dùng đã click vào và đọc chương
        await db.execute('''
          CREATE TABLE $tableHistory (
            comic_id TEXT PRIMARY KEY,
            current_chapter INTEGER NOT NULL,
            notify_enabled INTEGER NOT NULL DEFAULT 1,
            updated_at TEXT NOT NULL
          )
        ''');

        // 2. Bảng lưu trữ truyện đã đánh dấu yêu thích
        await db.execute('''
          CREATE TABLE $tableBookmarks (
            comic_id TEXT PRIMARY KEY,
            created_at TEXT NOT NULL
          )
        ''');
      },
    );
  }

  // ====================================================================
  // CÁC HÀM XỬ LÝ LỊCH SỬ ĐỌC (READING HISTORY)
  // ====================================================================

  /// Lấy toàn bộ lịch sử truyện đã từng đọc (sắp xếp mới đọc nhất lên đầu)
  Future<List<Map<String, dynamic>>> getHistory() async {
    final db = await database;
    if (db == null) {
      final list = _inMemoryHistory.values.toList();
      list.sort((a, b) => (b['updated_at'] as String).compareTo(a['updated_at'] as String));
      return list;
    }

    try {
      return await db.query(
        tableHistory,
        orderBy: 'updated_at DESC',
      );
    } catch (e) {
      debugPrint('Lỗi đọc lịch sử từ SQLite: $e');
      return [];
    }
  }

  /// Lưu hoặc cập nhật tiến độ khi người dùng click vào và đọc 1 chương
  Future<void> saveOrUpdateHistory({
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
      _inMemoryHistory[comicId] = row;
      return;
    }

    try {
      await db.insert(
        tableHistory,
        row,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      debugPrint('Lỗi lưu lịch sử đọc vào SQLite: $e');
      _inMemoryHistory[comicId] = row;
    }
  }

  /// Cập nhật trạng thái nhận thông báo cho truyện trong lịch sử
  Future<void> updateNotify(String comicId, bool notifyEnabled) async {
    final db = await database;
    if (db == null) {
      if (_inMemoryHistory.containsKey(comicId)) {
        _inMemoryHistory[comicId]!['notify_enabled'] = notifyEnabled ? 1 : 0;
      }
      return;
    }

    try {
      await db.update(
        tableHistory,
        {'notify_enabled': notifyEnabled ? 1 : 0},
        where: 'comic_id = ?',
        whereArgs: [comicId],
      );
    } catch (e) {
      debugPrint('Lỗi cập nhật notify trong SQLite: $e');
    }
  }

  /// Xóa một truyện khỏi lịch sử đọc
  Future<void> deleteHistory(String comicId) async {
    final db = await database;
    if (db == null) {
      _inMemoryHistory.remove(comicId);
      return;
    }

    try {
      await db.delete(
        tableHistory,
        where: 'comic_id = ?',
        whereArgs: [comicId],
      );
    } catch (e) {
      debugPrint('Lỗi xóa lịch sử trong SQLite: $e');
    }
  }

  /// Xóa toàn bộ lịch sử đọc
  Future<void> clearAllHistory() async {
    final db = await database;
    if (db == null) {
      _inMemoryHistory.clear();
      return;
    }

    try {
      await db.delete(tableHistory);
    } catch (e) {
      debugPrint('Lỗi dọn sạch lịch sử trong SQLite: $e');
    }
  }

  // ====================================================================
  // CÁC HÀM XỬ LÝ ĐÁNH DẤU (BOOKMARKS)
  // ====================================================================

  /// Lấy danh sách ID các truyện đã đánh dấu
  Future<Set<String>> getBookmarks() async {
    final db = await database;
    if (db == null) {
      return Set.from(_inMemoryBookmarks);
    }

    try {
      final rows = await db.query(tableBookmarks);
      return rows.map((r) => r['comic_id'] as String).toSet();
    } catch (e) {
      debugPrint('Lỗi đọc bookmarks từ SQLite: $e');
      return {};
    }
  }

  /// Thêm truyện vào danh sách đánh dấu
  Future<void> addBookmark(String comicId) async {
    final db = await database;
    if (db == null) {
      _inMemoryBookmarks.add(comicId);
      return;
    }

    try {
      await db.insert(
        tableBookmarks,
        {
          'comic_id': comicId,
          'created_at': DateTime.now().toIso8601String(),
        },
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    } catch (e) {
      debugPrint('Lỗi thêm bookmark vào SQLite: $e');
      _inMemoryBookmarks.add(comicId);
    }
  }

  /// Xóa truyện khỏi danh sách đánh dấu
  Future<void> removeBookmark(String comicId) async {
    final db = await database;
    if (db == null) {
      _inMemoryBookmarks.remove(comicId);
      return;
    }

    try {
      await db.delete(
        tableBookmarks,
        where: 'comic_id = ?',
        whereArgs: [comicId],
      );
    } catch (e) {
      debugPrint('Lỗi xóa bookmark khỏi SQLite: $e');
      _inMemoryBookmarks.remove(comicId);
    }
  }
}
