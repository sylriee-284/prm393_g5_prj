import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import '../models/comic.dart';
import '../screens/comic_detail_screen.dart';
import 'comic_cover.dart';

class ExploreCard extends StatelessWidget {
  const ExploreCard({
    super.key,
    required this.comic,
  });

  final Comic comic;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ComicDetailScreen(comicId: comic.id),
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ComicCover(comic: comic, width: 100, height: 140),
          const SizedBox(height: 8),
          Text(
            comic.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
