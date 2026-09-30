class Comic {
  const Comic({
    required this.id,
    required this.title,
    required this.author,
    required this.description,
    required this.coverColor,
    required this.coverLabel,
    required this.totalChapters,
    this.genre = 'Tiên hiệp',
  });

  final String id;
  final String title;
  final String author;
  final String description;
  final int coverColor;
  final String coverLabel;
  final int totalChapters;
  final String genre;
}
