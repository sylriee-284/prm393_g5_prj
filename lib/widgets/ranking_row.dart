import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import '../models/comic.dart';
import '../screens/comic_detail_screen.dart';
import 'comic_cover.dart';

class RankingRow extends StatelessWidget {
  const RankingRow({
    super.key,
    required this.comic,
    required this.rankIndex,
  });

  final Comic comic;
  final int rankIndex;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ComicDetailScreen(comicId: comic.id),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            SizedBox(
              width: 28,
              child: Text(
                '$rankIndex',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: rankIndex <= 3
                      ? Colors.orange
                      : AppTheme.textSecondary,
                ),
              ),
            ),
            ComicCover(comic: comic, width: 44, height: 60),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    comic.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${comic.totalChapters} chương · ${comic.genre.label}',
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
