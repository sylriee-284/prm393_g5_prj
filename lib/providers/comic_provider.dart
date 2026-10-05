import 'package:flutter/foundation.dart';

import '../core/comic_enums.dart';
import '../models/comic.dart';
import '../repositories/comic_repository.dart';

class ComicProvider extends ChangeNotifier {
  ComicProvider(this._repository) {
    _comics = _repository.getAll();
  }

  final ComicRepository _repository;
  List<Comic> _comics = [];
  ComicStatus? _statusFilter;

  List<Comic> get comics => List.unmodifiable(_comics);

  ComicStatus? get statusFilter => _statusFilter;

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
}
