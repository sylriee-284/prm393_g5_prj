import 'package:flutter/foundation.dart';

import '../core/comic_enums.dart';
import '../models/comic.dart';
import '../repositories/comic_repository.dart';

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
    _seed();
  }

  final ComicRepository _repository;

  final List<LibraryEntry> _history = [];
  final Set<String> _bookmarks = {};
  NotificationSetting _notificationSetting = NotificationSetting.all;

  void _seed() {
    final comics = _repository.getAll();
    final progress = <String, int>{
      'c1': 1,
      'c2': 3,
      'c3': 224,
      'c4': 120,
      'c5': 3379,
      'c6': 1504,
      'c7': 12,
    };
    for (final comic in comics) {
      _history.add(
        LibraryEntry(
          comicId: comic.id,
          currentChapter: progress[comic.id] ?? 1,
        ),
      );
    }
    _bookmarks.addAll({'c1', 'c3', 'c6'});
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

  void toggleNotify(String comicId) {
    final entry = entryOf(comicId);
    if (entry == null) return;
    entry.notifyEnabled = !entry.notifyEnabled;
    notifyListeners();
  }

  void toggleBookmark(String comicId) {
    if (_bookmarks.contains(comicId)) {
      _bookmarks.remove(comicId);
    } else {
      _bookmarks.add(comicId);
      _ensureHistory(comicId);
    }
    notifyListeners();
  }

  void removeFromHistory(String comicId) {
    _history.removeWhere((e) => e.comicId == comicId);
    notifyListeners();
  }

  void updateProgress(String comicId, int chapter) {
    _ensureHistory(comicId);
    final entry = entryOf(comicId)!;
    entry.currentChapter = chapter;
    _history.remove(entry);
    _history.insert(0, entry);
    notifyListeners();
  }

  void _ensureHistory(String comicId) {
    if (entryOf(comicId) != null) return;
    _history.insert(
      0,
      LibraryEntry(comicId: comicId, currentChapter: 1),
    );
  }
}
