import 'package:flutter/foundation.dart';

import '../models/chapter.dart';
import '../models/comic.dart';
import '../repositories/comic_repository.dart';

class ReaderProvider extends ChangeNotifier {
  ReaderProvider(this._repository);

  final ComicRepository _repository;

  Comic? _comic;
  Chapter? _chapter;
  double _fontSize = 18;
  bool _isLoading = false;

  Comic? get comic => _comic;
  Chapter? get chapter => _chapter;
  double get fontSize => _fontSize;
  bool get isLoading => _isLoading;

  List<Chapter> get chapters {
    if (_comic == null) return const [];
    return _repository.getChapters(_comic!);
  }

  bool get hasNext {
    if (_comic == null || _chapter == null) return false;
    return _chapter!.number < chapters.length;
  }

  bool get hasPrevious {
    if (_chapter == null) return false;
    return _chapter!.number > 1;
  }

  Future<void> open(Comic comic, {int chapterNumber = 1}) async {
    _comic = comic;
    _chapter = _repository.getChapter(comic, chapterNumber);
    notifyListeners();

    if (_chapter == null || _chapter!.content.isEmpty) {
      _isLoading = true;
      notifyListeners();
      final loaded = await _repository.fetchChapterDetail(comic.id, chapterNumber);
      if (loaded != null) {
        _chapter = loaded;
      }
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> next() async {
    if (!hasNext || _comic == null || _chapter == null) return;
    await open(_comic!, chapterNumber: _chapter!.number + 1);
  }

  Future<void> previous() async {
    if (!hasPrevious || _comic == null || _chapter == null) return;
    await open(_comic!, chapterNumber: _chapter!.number - 1);
  }

  void setFontSize(double size) {
    _fontSize = size.clamp(14, 28);
    notifyListeners();
  }
}
