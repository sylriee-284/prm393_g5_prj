import 'package:flutter/foundation.dart';

import '../models/comic.dart';
import '../repositories/comic_repository.dart';

class ComicProvider extends ChangeNotifier {
  ComicProvider(this._repository) {
    _comics = _repository.getAll();
  }

  final ComicRepository _repository;
  List<Comic> _comics = [];

  List<Comic> get comics => List.unmodifiable(_comics);

  Comic? byId(String id) => _repository.getById(id);

  List<Comic> search(String query) => _repository.search(query);

  List<Comic> get ranking {
    final list = [..._comics];
    list.sort((a, b) => b.totalChapters.compareTo(a.totalChapters));
    return list;
  }
}
