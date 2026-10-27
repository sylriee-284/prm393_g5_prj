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
      final response = await ApiService.instance.get('/api/comics/${comic.id}/chapters');
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
      final response = await ApiService.instance.get('/api/comics/$comicId/chapters/$number');
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
}
