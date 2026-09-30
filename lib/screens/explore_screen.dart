import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/app_theme.dart';
import '../core/constants.dart';
import '../providers/comic_provider.dart';
import '../widgets/comic_cover.dart';
import 'comic_detail_screen.dart';

class ExploreScreen extends StatelessWidget {
  const ExploreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final comics = context.watch<ComicProvider>().comics;

    return Scaffold(
      appBar: AppBar(title: const Text(AppConstants.navExplore)),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 16,
          crossAxisSpacing: 12,
          childAspectRatio: 0.55,
        ),
        itemCount: comics.length,
        itemBuilder: (context, index) {
          final comic = comics[index];
          return GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ComicDetailScreen(comicId: comic.id),
                ),
              );
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                LayoutBuilder(
                  builder: (context, constraints) {
                    return ComicCover(
                      comic: comic,
                      width: constraints.maxWidth,
                      height: 140,
                    );
                  },
                ),
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
        },
      ),
    );
  }
}
