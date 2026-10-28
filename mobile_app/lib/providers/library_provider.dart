import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    _initFuture = _initData();
  }

  // ignore: unused_field
  final ComicRepository _repository;
  Future<void>? _initFuture;
  Future<void> get initFuture => _initFuture ??= _initData();

  final List<LibraryEntry> _history = [];
  final Set<String> _bookmarks = {};
  NotificationSetting _notificationSetting = NotificationSetting.all;
  bool _isInitialized = false;

  /// true: Đang ở phạm vi tài khoản đã đăng nhập (Account Store)
  /// false: Đang ở phạm vi thiết bị/khách chưa đăng nhập (Local Store)
  bool _isAccountScope = false;

  bool get isInitialized => _isInitialized;
  bool get isAccountScope => _isAccountScope;

  /// Khởi tạo dữ liệu khi ứng dụng mở lên
  Future<void> _initData() async {
    try {
      if (ApiService.instance.hasToken) {
        _isAccountScope = true;
        final historyRows = await DatabaseService.instance.getAccountHistory();
        final bookmarkIds = await DatabaseService.instance.getAccountBookmarks();

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

        // Nếu cache tài khoản trong SQLite còn trống, nạp trực tiếp từ máy chủ
        if (_history.isEmpty && _bookmarks.isEmpty) {
          await loadAccountLibrary();
        }
      } else {
        _isAccountScope = false;
        final historyRows = await DatabaseService.instance.getLocalHistory();
        final bookmarkIds = await DatabaseService.instance.getLocalBookmarks();

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

        // Chỉ thêm dữ liệu mẫu đúng 1 lần duy nhất khi lần đầu tiên cài app
        // Tránh tự ý thêm lại khi người dùng đã chủ động xóa sạch lịch sử
        final prefs = await SharedPreferences.getInstance();
        final sampleInitialized = prefs.getBool('library_sample_initialized') ?? false;
        if (!sampleInitialized && _history.isEmpty && _bookmarks.isEmpty) {
          await prefs.setBool('library_sample_initialized', true);
          await updateProgress('c2', 3);
          await toggleBookmark('c2');
        }
      }

      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Lỗi khởi tạo dữ liệu tủ truyện: $e');
    }
  }

  /// Danh sách các truyện trong Lịch Sử đọc (tab Lịch Sử)
  List<LibraryEntry> get history => List.unmodifiable(_history);

  /// Danh sách các truyện đã Đánh Dấu (tab Đánh Dấu)
  /// Trả về các truyện nằm trong _bookmarks mà không bắt buộc phải tồn tại trong _history
  List<LibraryEntry> get bookmarks {
    return _bookmarks.map((id) {
      final existing = entryOf(id);
      if (existing != null) return existing;
      return LibraryEntry(comicId: id, currentChapter: 1);
    }).toList();
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

  // ====================================================================
  // CÁC HÀM XỬ LÝ ĐỒNG BỘ THEO THIẾT KẾ
  // ====================================================================

  /// 1. TẢI TỦ TRUYỆN CỦA TÀI KHOẢN (Khi người dùng Hủy đồng bộ)
  /// - Chuyển sang scope Account.
  /// - Nạp tủ truyện từ Server vào Account Store.
  /// - TUYỆT ĐỐI KHÔNG chạm vào Local Store (giữ nguyên vẹn 100% truyện trên thiết bị).
  Future<bool> loadAccountLibrary() async {
    if (!ApiService.instance.hasToken) {
      debugPrint('Chưa đăng nhập, không thể tải dữ liệu tài khoản');
      return false;
    }

    try {
      _isAccountScope = true;

      final historyRes = await ApiService.instance.get('/api/library/history', requiresAuth: true);
      final bookmarkRes = await ApiService.instance.get('/api/library/bookmarks', requiresAuth: true);

      if (historyRes.statusCode != 200 || bookmarkRes.statusCode != 200) {
        debugPrint('Lỗi tải dữ liệu tài khoản từ backend (History: ${historyRes.statusCode}, Bookmark: ${bookmarkRes.statusCode})');
        return false;
      }

      final historyBody = jsonDecode(utf8.decode(historyRes.bodyBytes));
      final bookmarkBody = jsonDecode(utf8.decode(bookmarkRes.bodyBytes));

      final serverHistoryList = (historyBody['data'] as List?) ?? [];
      final serverBookmarkList = (bookmarkBody['data'] as List?) ?? [];

      // Dọn dẹp cache của Account Store, KHÔNG chạm vào Local Store
      _history.clear();
      _bookmarks.clear();
      await DatabaseService.instance.clearAccountHistory();
      await DatabaseService.instance.clearAccountBookmarks();

      for (final item in serverHistoryList) {
        final cid = item['comicId'] as String;
        final chap = (item['currentChapter'] as num).toInt();
        final noti = item['notifyEnabled'] as bool? ?? true;
        _history.add(LibraryEntry(comicId: cid, currentChapter: chap, notifyEnabled: noti));
        await DatabaseService.instance.saveAccountHistory(
          comicId: cid,
          currentChapter: chap,
          notifyEnabled: noti,
        );
      }

      for (final item in serverBookmarkList) {
        final id = item['id'] as String;
        _bookmarks.add(id);
        await DatabaseService.instance.addAccountBookmark(id);
      }

      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Lỗi tải tủ truyện tài khoản: $e');
      return false;
    }
  }

  /// 2. MERGE SERVICE: HỢP NHẤT TRUYỆN THIẾT BỊ VÀO TÀI KHOẢN (Khi Đồng ý đồng bộ hoặc ấn nút Đồng bộ)
  /// - Lấy toàn bộ truyện từ Local Store trên thiết bị.
  /// - Đẩy và hợp nhất các truyện đó lên máy chủ vào tài khoản hiện tại.
  /// - Nạp lại toàn bộ tủ truyện đã hợp nhất từ Server vào Account Store.
  /// - Giữ nguyên Local Store trên thiết bị để khi đăng xuất vẫn có đủ truyện.
  Future<bool> mergeLocalWithAccount() async {
    if (!ApiService.instance.hasToken) {
      debugPrint('Chưa đăng nhập, không thể hợp nhất tủ truyện');
      return false;
    }

    try {
      _isAccountScope = true;

      // a. Lấy dữ liệu từ Local Store trên máy
      final localHistory = await DatabaseService.instance.getLocalHistory();
      final localBookmarks = await DatabaseService.instance.getLocalBookmarks();

      // b. Lấy dữ liệu hiện tại trên Server
      final historyRes = await ApiService.instance.get('/api/library/history', requiresAuth: true);
      final bookmarkRes = await ApiService.instance.get('/api/library/bookmarks', requiresAuth: true);

      if (historyRes.statusCode != 200 || bookmarkRes.statusCode != 200) {
        debugPrint('Lỗi tải dữ liệu server để merge');
        return false;
      }

      final historyBody = jsonDecode(utf8.decode(historyRes.bodyBytes));
      final bookmarkBody = jsonDecode(utf8.decode(bookmarkRes.bodyBytes));

      final serverHistoryList = (historyBody['data'] as List?) ?? [];
      final serverBookmarkList = (bookmarkBody['data'] as List?) ?? [];

      final Map<String, int> serverHistoryMap = {};
      for (final item in serverHistoryList) {
        serverHistoryMap[item['comicId'] as String] = (item['currentChapter'] as num).toInt();
      }

      final Set<String> serverBookmarkSet = {};
      for (final item in serverBookmarkList) {
        serverBookmarkSet.add(item['id'] as String);
      }

      // c. Đẩy lịch sử đọc từ Local lên Server
      for (final row in localHistory) {
        final cid = row['comic_id'] as String;
        final chap = row['current_chapter'] as int;
        final sChap = serverHistoryMap[cid];
        if (sChap == null || chap > sChap) {
          await ApiService.instance.post(
            '/api/library/progress',
            body: {'comicId': cid, 'currentChapter': chap},
            requiresAuth: true,
          );
        }
      }

      // d. Đẩy bookmark từ Local lên Server
      for (final cid in localBookmarks) {
        if (!serverBookmarkSet.contains(cid)) {
          final res = await ApiService.instance.put('/api/library/bookmarks/$cid', requiresAuth: true);
          if (res.statusCode == 404 || res.statusCode == 405) {
            await ApiService.instance.post('/api/library/bookmarks/$cid', requiresAuth: true);
          }
        }
      }

      // e. Tải lại toàn bộ dữ liệu tài khoản từ máy chủ sau khi đã merge
      await loadAccountLibrary();
      return true;
    } catch (e) {
      debugPrint('Lỗi merge tủ truyện thiết bị với tài khoản: $e');
      return false;
    }
  }

  /// 3. CHUYỂN VỀ CHẾ ĐỘ THIẾT BỊ (Khi người dùng Đăng xuất)
  /// - Chuyển sang scope Local.
  /// - Đọc lại toàn bộ truyện lưu trữ tại Local Store trên máy.
  /// - Người dùng đăng xuất sẽ chỉ thấy truyện của máy.
  Future<void> switchToLocal() async {
    _isAccountScope = false;
    _history.clear();
    _bookmarks.clear();

    final historyRows = await DatabaseService.instance.getLocalHistory();
    final bookmarkIds = await DatabaseService.instance.getLocalBookmarks();

    for (final row in historyRows) {
      _history.add(
        LibraryEntry(
          comicId: row['comic_id'] as String,
          currentChapter: row['current_chapter'] as int,
          notifyEnabled: (row['notify_enabled'] as int) == 1,
        ),
      );
    }

    _bookmarks.addAll(bookmarkIds);

    notifyListeners();
  }

  // Alias tương thích
  Future<bool> syncWithBackend() => mergeLocalWithAccount();
  Future<bool> loadFromServerOnly() => loadAccountLibrary();
  Future<void> onLogout() => switchToLocal();

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

    if (_isAccountScope) {
      await DatabaseService.instance.updateAccountNotify(comicId, entry.notifyEnabled);
      if (ApiService.instance.hasToken) {
        _fireAndForget(ApiService.instance.post('/api/library/notify/$comicId', requiresAuth: true));
      }
    } else {
      await DatabaseService.instance.updateLocalNotify(comicId, entry.notifyEnabled);
    }
  }

  Future<void> toggleBookmark(String comicId) async {
    if (_bookmarks.contains(comicId)) {
      _bookmarks.remove(comicId);
      if (_isAccountScope) {
        await DatabaseService.instance.removeAccountBookmark(comicId);
      } else {
        await DatabaseService.instance.removeLocalBookmark(comicId);
      }
    } else {
      _bookmarks.add(comicId);
      if (_isAccountScope) {
        await DatabaseService.instance.addAccountBookmark(comicId);
      } else {
        await DatabaseService.instance.addLocalBookmark(comicId);
      }
    }
    notifyListeners();

    if (_isAccountScope && ApiService.instance.hasToken) {
      _fireAndForget(ApiService.instance.post('/api/library/bookmarks/$comicId', requiresAuth: true));
    }
  }

  /// Xóa truyện khỏi lịch sử đọc:
  /// - Xóa khỏi danh sách đang hiển thị trong RAM.
  /// - Xóa khỏi CẢ Local Store và Account Store trong SQLite trên thiết bị (để tránh bị khôi phục khi logout hoặc re-merge).
  /// - Gọi API xóa trên backend nếu đang đăng nhập tài khoản.
  Future<void> removeFromHistory(String comicId) async {
    _history.removeWhere((e) => e.comicId == comicId);
    notifyListeners();

    // Xóa trong SQLite ở cả 2 Store để đồng bộ triệt để
    await DatabaseService.instance.deleteLocalHistory(comicId);
    await DatabaseService.instance.deleteAccountHistory(comicId);

    // Đồng bộ xóa trên máy chủ (chờ phản hồi thay vì fire-and-forget để đảm bảo hoàn tất trước khi logout)
    if (_isAccountScope && ApiService.instance.hasToken) {
      try {
        await ApiService.instance.delete('/api/library/history/$comicId', requiresAuth: true);
      } catch (e) {
        debugPrint('Lỗi gọi API xóa lịch sử: $e');
      }
    }
  }

  /// Khi người dùng click vào và đọc một chương, ghi nhận vào Store tương ứng
  Future<void> updateProgress(String comicId, int chapter) async {
    _ensureHistory(comicId);
    final entry = entryOf(comicId)!;
    entry.currentChapter = chapter;
    _history.remove(entry);
    _history.insert(0, entry);
    notifyListeners();

    if (_isAccountScope) {
      await DatabaseService.instance.saveAccountHistory(
        comicId: comicId,
        currentChapter: chapter,
        notifyEnabled: entry.notifyEnabled,
      );
      if (ApiService.instance.hasToken) {
        _fireAndForget(
          ApiService.instance.post(
            '/api/library/progress',
            body: {'comicId': comicId, 'currentChapter': chapter},
            requiresAuth: true,
          ),
        );
      }
    } else {
      await DatabaseService.instance.saveLocalHistory(
        comicId: comicId,
        currentChapter: chapter,
        notifyEnabled: entry.notifyEnabled,
      );
    }
  }

  void _ensureHistory(String comicId) {
    if (entryOf(comicId) != null) return;
    _history.insert(0, LibraryEntry(comicId: comicId, currentChapter: 1));
  }
}
