import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import '../core/comic_enums.dart';
import '../models/comic.dart';
import '../screens/comic_detail_screen.dart';
import 'comic_cover.dart';

class ExploreCard extends StatelessWidget {
  const ExploreCard({super.key, required this.comic, this.showGenre = false});

  final Comic comic;
  final bool showGenre;

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
          if (showGenre) ...[
            Text(
              comic.genre.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 11,
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 4),
          ],
          Expanded(
            child: Stack(
              children: [
                Positioned.fill(
                  child: ComicCover(
                    comic: comic,
                    width: double.infinity,
                    height: double.infinity,
                    borderRadius: 8,
                  ),
                ),
                if (comic.status == ComicStatus.completed)
                  Positioned(
                    top: 6,
                    right: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 5,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xE62E7D32),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'Full',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Text(
            comic.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppTheme.textPrimary,
              height: 1.25,
            ),
          ),
        ],
      ),
    );
  }
}
