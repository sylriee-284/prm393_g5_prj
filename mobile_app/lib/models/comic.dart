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
    this.status = ComicStatus.ongoing,
    this.rating = 5.0,
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
  final ComicStatus status;
  final double rating;

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

  factory Comic.fromJson(Map<String, dynamic> json) {
    ComicGenre parsedGenre = ComicGenre.tienHiep;
    final genreStr = json['genre'] as String? ?? '';
    for (final g in ComicGenre.values) {
      if (g.label == genreStr || g.name == genreStr) {
        parsedGenre = g;
        break;
      }
    }

    final statusStr = json['status'] as String? ?? 'ongoing';
    final parsedStatus = statusStr.toLowerCase() == 'completed'
        ? ComicStatus.completed
        : ComicStatus.ongoing;

    return Comic(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      author: json['author'] as String? ?? '',
      description: json['description'] as String? ?? '',
      coverColor: (json['coverColor'] as num?)?.toInt() ?? 0xFF1A365D,
      coverLabel: json['coverLabel'] as String? ?? '',
      coverUrl: json['coverUrl'] as String? ?? '',
      totalChapters: (json['totalChapters'] as num?)?.toInt() ?? 0,
      genre: parsedGenre,
      views: (json['views'] as num?)?.toInt() ?? 0,
      status: parsedStatus,
      rating: (json['rating'] as num?)?.toDouble() ?? 5.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'author': author,
      'description': description,
      'coverColor': coverColor,
      'coverLabel': coverLabel,
      'coverUrl': coverUrl,
      'totalChapters': totalChapters,
      'genre': genre.label,
      'views': views,
      'status': status.name,
      'rating': rating,
    };
  }
}

