import 'dart:convert';
import 'package:flutter/foundation.dart';

import '../core/comic_enums.dart';
import '../models/comic.dart';
import '../repositories/comic_repository.dart';
import '../services/api_service.dart';
import '../services/database_service.dart';

class LibraryEntry {
  LibraryEntry({
    required this.comicId,
    required this.currentChapter,
    this.notifyEnabled = true,
  });

  final String comicId;
  int currentChapter;
  bool notifyEnabled;
}

class LibraryProvider extends ChangeNotifier {
  LibraryProvider(this._repository) {
    _initLocalData();
  }

  final ComicRepository _repository;

  final List<LibraryEntry> _history = [];
  final Set<String> _bookmarks = {};
  NotificationSetting _notificationSetting = NotificationSetting.all;
  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;

  /// Khởi tạo dữ liệu từ bảng SQLite cục bộ (sqflite)
  Future<void> _initLocalData() async {
    try {
      final historyRows = await DatabaseService.instance.getHistory();
      final bookmarkIds = await DatabaseService.instance.getBookmarks();

      _history.clear();
      for (final row in historyRows) {
        _history.add(
          LibraryEntry(
            comicId: row['comic_id'] as String,
            currentChapter: row['current_chapter'] as int,
            notifyEnabled: (row['notify_enabled'] as int) == 1,
          ),
        );
      }

      _bookmarks.clear();
      _bookmarks.addAll(bookmarkIds);

      // Nếu lần đầu mở ứng dụng và chưa có lịch sử, thêm 1 truyện mẫu đã đọc (Thanh Liên Chi Đỉnh)
      if (_history.isEmpty && _bookmarks.isEmpty) {
        await updateProgress('c2', 3);
        await toggleBookmark('c2');
      }

      _isInitialized = true;
      notifyListeners();

      // Đồng bộ với backend nếu người dùng đã đăng nhập
      await syncWithBackend();
    } catch (e) {
      debugPrint('Lỗi nạp dữ liệu từ sqflite: $e');
    }
  }

  List<LibraryEntry> get history => List.unmodifiable(_history);

  List<LibraryEntry> get bookmarks {
    return _history.where((e) => _bookmarks.contains(e.comicId)).toList();
  }

  bool isBookmarked(String comicId) => _bookmarks.contains(comicId);

  NotificationSetting get notificationSetting => _notificationSetting;

  void setNotificationSetting(NotificationSetting setting) {
    _notificationSetting = setting;
    notifyListeners();
  }

  bool isNotifyEnabled(String comicId) {
    switch (_notificationSetting) {
      case NotificationSetting.off:
        return false;
      case NotificationSetting.favoriteOnly:
        return isBookmarked(comicId);
      case NotificationSetting.all:
        return entryOf(comicId)?.notifyEnabled ?? false;
    }
  }

  LibraryEntry? entryOf(String comicId) {
    for (final entry in _history) {
      if (entry.comicId == comicId) return entry;
    }
    return null;
  }

  int currentChapterOf(Comic comic) {
    return entryOf(comic.id)?.currentChapter ?? 1;
  }

  /// Đồng bộ hai chiều (2-way sync) giữa Local (SQLite) và Backend API (MySQL)
  Future<bool> syncWithBackend() async {
    if (!ApiService.instance.hasToken) {
      debugPrint('Chưa đăng nhập, không thể đồng bộ với máy chủ');
      return false;
    }

    try {
      // 1. Tải dữ liệu hiện có từ backend để đối chiếu
      final historyRes = await ApiService.instance.get('/api/library/history', requiresAuth: true);
      final bookmarkRes = await ApiService.instance.get('/api/library/bookmarks', requiresAuth: true);

      if (historyRes.statusCode != 200 || bookmarkRes.statusCode != 200) {
        debugPrint('Lỗi tải dữ liệu từ backend (History: ${historyRes.statusCode}, Bookmark: ${bookmarkRes.statusCode})');
        return false;
      }

      final historyBody = jsonDecode(utf8.decode(historyRes.bodyBytes));
      final bookmarkBody = jsonDecode(utf8.decode(bookmarkRes.bodyBytes));

      final serverHistoryList = (historyBody['data'] as List?) ?? [];
      final serverBookmarkList = (bookmarkBody['data'] as List?) ?? [];

      // Map dữ liệu lịch sử từ Server
      final Map<String, int> serverHistoryMap = {};
      final Map<String, bool> serverNotifyMap = {};
      for (final item in serverHistoryList) {
        final cid = item['comicId'] as String;
        final chap = (item['currentChapter'] as num).toInt();
        final noti = item['notifyEnabled'] as bool? ?? true;
        serverHistoryMap[cid] = chap;
        serverNotifyMap[cid] = noti;
      }

      final Set<String> serverBookmarkSet = {};
      for (final item in serverBookmarkList) {
        final id = item['id'] as String;
        serverBookmarkSet.add(id);
      }

      // 2. CHIỀU ĐẨY LÊN: Gửi lịch sử đọc từ Local lên Server
      for (final localEntry in _history) {
        final serverChapter = serverHistoryMap[localEntry.comicId];
        if (serverChapter == null || localEntry.currentChapter > serverChapter) {
          // Local mới hơn hoặc server chưa có -> Lưu lên server
          await ApiService.instance.post(
            '/api/library/progress',
            body: {'comicId': localEntry.comicId, 'currentChapter': localEntry.currentChapter},
            requiresAuth: true,
          );
        }
      }

      // 3. CHIỀU KÉO VỀ: Hợp nhất lịch sử từ Server vào Local
      for (final entry in serverHistoryMap.entries) {
        final localEntry = entryOf(entry.key);
        if (localEntry == null) {
          // Server có mà Local chưa có -> Thêm vào Local
          final newEntry = LibraryEntry(
            comicId: entry.key,
            currentChapter: entry.value,
            notifyEnabled: serverNotifyMap[entry.key] ?? true,
          );
          _history.add(newEntry);
          await DatabaseService.instance.saveOrUpdateHistory(
            comicId: entry.key,
            currentChapter: entry.value,
            notifyEnabled: serverNotifyMap[entry.key] ?? true,
          );
        } else if (entry.value > localEntry.currentChapter) {
          // Server có tiến độ cao hơn -> Cập nhật Local
          localEntry.currentChapter = entry.value;
          await DatabaseService.instance.saveOrUpdateHistory(
            comicId: entry.key,
            currentChapter: entry.value,
            notifyEnabled: localEntry.notifyEnabled,
          );
        }
      }

      // 4. ĐỒNG BỘ ĐÁNH DẤU (BOOKMARKS)
      // 4a. Đẩy các bookmark có ở local mà server chưa có lên server
      for (final localBmk in _bookmarks) {
        if (!serverBookmarkSet.contains(localBmk)) {
          await ApiService.instance.post('/api/library/bookmarks/$localBmk', requiresAuth: true);
        }
      }

      // 4b. Thêm các bookmark từ server vào local
      for (final sBmk in serverBookmarkSet) {
        if (!_bookmarks.contains(sBmk)) {
          _bookmarks.add(sBmk);
          await DatabaseService.instance.addBookmark(sBmk);
          _ensureHistory(sBmk);
        }
      }

      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Lỗi đồng bộ tủ truyện với backend: $e');
      return false;
    }
  }

  void _fireAndForget(Future<dynamic> future) async {
    try {
      await future;
    } catch (_) {}
  }

  Future<void> toggleNotify(String comicId) async {
    final entry = entryOf(comicId);
    if (entry == null) return;
    entry.notifyEnabled = !entry.notifyEnabled;
    notifyListeners();

    // Cập nhật trong SQLite
    await DatabaseService.instance.updateNotify(comicId, entry.notifyEnabled);

    // Đồng bộ lên backend nếu có token
    if (ApiService.instance.hasToken) {
      _fireAndForget(ApiService.instance.post('/api/library/notify/$comicId', requiresAuth: true));
    }
  }

  Future<void> toggleBookmark(String comicId) async {
    if (_bookmarks.contains(comicId)) {
      _bookmarks.remove(comicId);
      await DatabaseService.instance.removeBookmark(comicId);
    } else {
      _bookmarks.add(comicId);
      await DatabaseService.instance.addBookmark(comicId);
      _ensureHistory(comicId);
    }
    notifyListeners();

    if (ApiService.instance.hasToken) {
      _fireAndForget(ApiService.instance.post('/api/library/bookmarks/$comicId', requiresAuth: true));
    }
  }

  Future<void> removeFromHistory(String comicId) async {
    _history.removeWhere((e) => e.comicId == comicId);
    notifyListeners();

    // Xóa trong SQLite
    await DatabaseService.instance.deleteHistory(comicId);

    // Đồng bộ xóa lên backend
    if (ApiService.instance.hasToken) {
      _fireAndForget(ApiService.instance.delete('/api/library/history/$comicId', requiresAuth: true));
    }
  }

  /// Khi người dùng click vào và đọc một chương, ghi nhận vào SQLite và Backend
  Future<void> updateProgress(String comicId, int chapter) async {
    _ensureHistory(comicId);
    final entry = entryOf(comicId)!;
    entry.currentChapter = chapter;
    _history.remove(entry);
    _history.insert(0, entry);
    notifyListeners();

    // Lưu vào bảng reading_history trong SQLite
    await DatabaseService.instance.saveOrUpdateHistory(
      comicId: comicId,
      currentChapter: chapter,
      notifyEnabled: entry.notifyEnabled,
    );

    // Đồng bộ lên backend API
    if (ApiService.instance.hasToken) {
      _fireAndForget(
        ApiService.instance.post(
          '/api/library/progress',
          body: {'comicId': comicId, 'currentChapter': chapter},
          requiresAuth: true,
        ),
      );
    }
  }

  void _ensureHistory(String comicId) {
    if (entryOf(comicId) != null) return;
    _history.insert(0, LibraryEntry(comicId: comicId, currentChapter: 1));
  }
}
