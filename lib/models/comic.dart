import '../core/comic_enums.dart';

class Comic {
  const Comic({
    required this.id,
    required this.title,
    required this.author,
    required this.description,
    required this.coverColor,
    required this.coverLabel,
    required this.totalChapters,
    this.genre = ComicGenre.tienHiep,
    this.coverUrl = '',
  });

  final String id;
  final String title;
  final String author;
  final String description;
  final int coverColor;
  final String coverLabel;
  final int totalChapters;
  final ComicGenre genre;
  final String coverUrl;
}
