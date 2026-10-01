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
    this.views = 0,
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
  final int views;

  String get formattedViews {
    if (views >= 1000000) {
      final val = views / 1000000;
      return '${val.toStringAsFixed(val.truncateToDouble() == val ? 0 : 1)}M';
    } else if (views >= 1000) {
      final val = views / 1000;
      return '${val.toStringAsFixed(val.truncateToDouble() == val ? 0 : 1)}K';
    }
    return '$views';
  }
}
