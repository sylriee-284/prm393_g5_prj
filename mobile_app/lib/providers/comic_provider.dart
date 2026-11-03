import 'package:flutter/foundation.dart';

import '../core/comic_enums.dart';
import '../models/chapter.dart';
import '../models/comic.dart';
import '../repositories/comic_repository.dart';

class ComicProvider extends ChangeNotifier {
  ComicProvider(this._repository) {
    _comics = _repository.getAll();
    refresh();
  }

  final ComicRepository _repository;
  List<Comic> _comics = [];
  ComicStatus? _statusFilter;
  bool _isLoading = false;

  List<Comic> get comics => List.unmodifiable(_comics);
  ComicStatus? get statusFilter => _statusFilter;
  bool get isLoading => _isLoading;

  Future<void> refresh() async {
    _isLoading = true;
    final updated = await _repository.refreshComicsFromBackend();
    _comics = updated;
    _isLoading = false;
    notifyListeners();
  }

  void setStatusFilter(ComicStatus? status) {
    _statusFilter = status;
    notifyListeners();
  }

  Comic? byId(String id) => _repository.getById(id);

  List<Comic> search(String query) => _repository.search(query);

  List<Comic> get ranking {
    final list = [..._comics];
    list.sort((a, b) => b.views.compareTo(a.views));
    return list;
  }

  /// Truyện mới nhất
  List<Comic> get latest => List.unmodifiable(_comics);

  /// Truyện đề cử theo lượt xem (views)
  List<Comic> get recommended {
    final list = [..._comics];
    list.sort((a, b) => b.views.compareTo(a.views));
    return list;
  }

  /// Truyện đã hoàn thành (trạng thái hoàn thành)
  List<Comic> get completed =>
      _comics.where((c) => c.status == ComicStatus.completed).toList();

  /// Lọc danh sách theo trạng thái hiện tại (nếu có)
  List<Comic> filterByStatus(List<Comic> list) {
    if (_statusFilter == null) return list;
    return list.where((c) => c.status == _statusFilter).toList();
  }

  // ====================================================================
  // NGHIỆP VỤ QUẢN TRỊ VIÊN (ADMIN)
  // ====================================================================

  /// Lấy danh sách truyện đầy đủ của Admin (gồm cả truyện bị ẩn)
  Future<List<Comic>> getAdminComics() async {
    return await _repository.fetchAdminComics();
  }

  /// Thêm truyện mới hoặc cập nhật thông tin truyện
  Future<bool> saveComic(Map<String, dynamic> comicData, {String? comicId}) async {
    final success = await _repository.saveComic(comicData, comicId: comicId);
    if (success) {
      await refresh();
    }
    return success;
  }

  /// Chuyển đổi trạng thái truyện qua Ẩn hoặc Công khai
  Future<bool> toggleComicVisibility(String comicId, bool isHidden) async {
    final success = await _repository.toggleComicVisibility(comicId, isHidden);
    if (success) {
      await refresh();
    }
    return success;
  }

  /// Thêm hoặc cập nhật chương truyện
  Future<bool> saveChapter(
    String comicId, {
    required int number,
    required String title,
    required String content,
  }) async {
    final success = await _repository.saveChapter(
      comicId,
      number: number,
      title: title,
      content: content,
    );
    if (success) {
      await refresh();
    }
    return success;
  }

  /// Tải chi tiết chương truyện
  Future<Chapter?> fetchChapterDetail(String comicId, int number) async {
    return await _repository.fetchChapterDetail(comicId, number);
  }

  /// Xóa truyện
  Future<bool> deleteComic(String comicId) async {
    final success = await _repository.deleteComic(comicId);
    if (success) {
      await refresh();
    }
    return success;
  }
}
