import 'dart:convert';
import '../models/chapter.dart';
import '../models/comic.dart';
import '../services/api_service.dart';

class ComicRepository {
  ComicRepository({List<Comic>? initialComics})
      : _cachedComics = initialComics ?? [];

  List<Comic> _cachedComics;
  final Map<String, List<Chapter>> _cachedChapters = {};
  final Map<String, Chapter> _chapterDetailCache = {};

  List<Comic> getAll() => _cachedComics;

  Future<List<Comic>> refreshComicsFromBackend() async {
    try {
      final response = await ApiService.instance.get('/api/comics');
      if (response.statusCode == 200) {
        final body = jsonDecode(utf8.decode(response.bodyBytes));
        if (body['success'] == true && body['data'] is List) {
          final list = (body['data'] as List)
              .map((item) => Comic.fromJson(item as Map<String, dynamic>))
              .toList();
          if (list.isNotEmpty) {
            _cachedComics = list;
          }
        }
      }
    } catch (_) {}
    return _cachedComics;
  }

  Comic? getById(String id) {
    for (final comic in _cachedComics) {
      if (comic.id == id) return comic;
    }
    return null;
  }

  List<Comic> search(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return getAll();
    return _cachedComics
        .where(
          (c) =>
              c.title.toLowerCase().contains(q) ||
              c.author.toLowerCase().contains(q) ||
              c.genre.label.toLowerCase().contains(q),
        )
        .toList();
  }

  List<Chapter> getChapters(Comic comic) {
    return _cachedChapters[comic.id] ?? const [];
  }

  Future<List<Chapter>> fetchChaptersFromBackend(Comic comic) async {
    try {
      final response = await ApiService.instance.get(
        '/api/comics/${comic.id}/chapters',
        requiresAuth: ApiService.instance.hasToken,
      );
      if (response.statusCode == 200) {
        final body = jsonDecode(utf8.decode(response.bodyBytes));
        if (body['success'] == true && body['data'] is List) {
          final list = (body['data'] as List)
              .map((item) => Chapter.fromJson(item as Map<String, dynamic>))
              .toList();
          _cachedChapters[comic.id] = list;
          return list;
        }
      }
    } catch (_) {}
    return _cachedChapters[comic.id] ?? const [];
  }

  Future<Chapter?> fetchChapterDetail(String comicId, int number) async {
    final cacheKey = '${comicId}_$number';
    if (_chapterDetailCache.containsKey(cacheKey)) {
      return _chapterDetailCache[cacheKey];
    }
    try {
      final response = await ApiService.instance.get(
        '/api/comics/$comicId/chapters/$number',
        requiresAuth: ApiService.instance.hasToken,
      );
      if (response.statusCode == 200) {
        final body = jsonDecode(utf8.decode(response.bodyBytes));
        if (body['success'] == true && body['data'] != null) {
          final chapter = Chapter.fromJson(body['data'] as Map<String, dynamic>);
          _chapterDetailCache[cacheKey] = chapter;
          return chapter;
        }
      }
    } catch (_) {}
    return null;
  }

  Chapter? getChapter(Comic comic, int number) {
    final chapters = getChapters(comic);
    for (final chapter in chapters) {
      if (chapter.number == number) return chapter;
    }
    return chapters.isEmpty ? null : chapters.last;
  }

  // ====================================================================
  // NGHIỆP VỤ QUẢN TRỊ VIÊN (ADMIN)
  // ====================================================================

  /// Lấy toàn bộ danh sách truyện dành cho Admin (bao gồm cả truyện bị ẩn)
  Future<List<Comic>> fetchAdminComics() async {
    try {
      final response = await ApiService.instance.get(
        '/api/admin/comics',
        requiresAuth: true,
      );
      if (response.statusCode == 200) {
        final body = jsonDecode(utf8.decode(response.bodyBytes));
        if (body['success'] == true && body['data'] is List) {
          return (body['data'] as List)
              .map((item) => Comic.fromJson(item as Map<String, dynamic>))
              .toList();
        }
      }
    } catch (_) {}
    return _cachedComics;
  }

  /// Thêm truyện mới hoặc cập nhật truyện
  Future<bool> saveComic(Map<String, dynamic> comicData, {String? comicId}) async {
    try {
      final isUpdating = comicId != null && comicId.isNotEmpty;
      final response = isUpdating
          ? await ApiService.instance.put(
              '/api/admin/comics/$comicId',
              body: comicData,
              requiresAuth: true,
            )
          : await ApiService.instance.post(
              '/api/admin/comics',
              body: comicData,
              requiresAuth: true,
            );
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  /// Chuyển đổi trạng thái truyện qua Ẩn hoặc Công khai
  Future<bool> toggleComicVisibility(String comicId, bool isHidden) async {
    try {
      final response = await ApiService.instance.patch(
        '/api/admin/comics/$comicId/visibility',
        body: {'isHidden': isHidden},
        requiresAuth: true,
      );
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  /// Thêm hoặc cập nhật chương truyện
  Future<bool> saveChapter(
    String comicId, {
    required int number,
    required String title,
    required String content,
  }) async {
    try {
      final response = await ApiService.instance.post(
        '/api/admin/comics/$comicId/chapters',
        body: {
          'number': number,
          'title': title,
          'content': content,
        },
        requiresAuth: true,
      );
      if (response.statusCode == 200) {
        // Xóa cache để tải nội dung mới nhất
        _chapterDetailCache.remove('${comicId}_$number');
        _cachedChapters.remove(comicId);
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  /// Xóa truyện (nếu cần)
  Future<bool> deleteComic(String comicId) async {
    try {
      final response = await ApiService.instance.delete(
        '/api/admin/comics/$comicId',
        requiresAuth: true,
      );
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}
