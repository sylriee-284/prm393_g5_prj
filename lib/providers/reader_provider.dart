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

  Comic? get comic => _comic;
  Chapter? get chapter => _chapter;
  double get fontSize => _fontSize;

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

  void open(Comic comic, {int chapterNumber = 1}) {
    _comic = comic;
    _chapter = _repository.getChapter(comic, chapterNumber);
    notifyListeners();
  }

  void next() {
    if (!hasNext || _comic == null || _chapter == null) return;
    _chapter = _repository.getChapter(_comic!, _chapter!.number + 1);
    notifyListeners();
  }

  void previous() {
    if (!hasPrevious || _comic == null || _chapter == null) return;
    _chapter = _repository.getChapter(_comic!, _chapter!.number - 1);
    notifyListeners();
  }

  void setFontSize(double size) {
    _fontSize = size.clamp(14, 28);
    notifyListeners();
  }
}
