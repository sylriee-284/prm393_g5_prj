import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import '../models/comic.dart';
import 'comic_cover.dart';

class ComicDetailHeader extends StatelessWidget {
  const ComicDetailHeader({
    super.key,
    required this.comic,
  });

  final Comic comic;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ComicCover(comic: comic, width: 92, height: 124),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                comic.title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                comic.author,
                style: const TextStyle(color: AppTheme.textSecondary),
              ),
              const SizedBox(height: 4),
              Text(
                '${comic.genre.label} · ${comic.totalChapters} chương',
                style: const TextStyle(color: AppTheme.textSecondary),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
