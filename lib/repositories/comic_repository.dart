import '../data/comic_data.dart';
import '../models/chapter.dart';
import '../models/comic.dart';

class ComicRepository {
  List<Comic> getAll() => ComicData.comics;

  Comic? getById(String id) {
    for (final comic in ComicData.comics) {
      if (comic.id == id) return comic;
    }
    return null;
  }

  List<Comic> search(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return getAll();
    return ComicData.comics
        .where(
          (c) =>
              c.title.toLowerCase().contains(q) ||
              c.author.toLowerCase().contains(q) ||
              c.genre.label.toLowerCase().contains(q),
        )
        .toList();
  }

  List<Chapter> getChapters(Comic comic) => ComicData.chaptersOf(comic);

  Chapter? getChapter(Comic comic, int number) {
    final chapters = getChapters(comic);
    for (final chapter in chapters) {
      if (chapter.number == number) return chapter;
    }
    return chapters.isEmpty ? null : chapters.last;
  }
}
