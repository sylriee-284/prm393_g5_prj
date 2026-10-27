class Chapter {
  const Chapter({
    required this.id,
    required this.comicId,
    required this.number,
    required this.title,
    required this.content,
  });

  final String id;
  final String comicId;
  final int number;
  final String title;
  final String content;

  factory Chapter.fromJson(Map<String, dynamic> json) {
    return Chapter(
      id: json['id'] as String? ?? '',
      comicId: json['comicId'] as String? ?? '',
      number: (json['number'] as num?)?.toInt() ?? 1,
      title: json['title'] as String? ?? '',
      content: json['content'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'comicId': comicId,
      'number': number,
      'title': title,
      'content': content,
    };
  }
}

