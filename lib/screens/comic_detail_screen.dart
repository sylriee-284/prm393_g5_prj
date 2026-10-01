import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/app_theme.dart';
import '../providers/comic_provider.dart';
import '../providers/library_provider.dart';
import '../providers/reader_provider.dart';
import '../repositories/comic_repository.dart';
import '../widgets/comic_detail_header.dart';
import 'reader_screen.dart';

class ComicDetailScreen extends StatelessWidget {
  const ComicDetailScreen({super.key, required this.comicId});

  final String comicId;

  @override
  Widget build(BuildContext context) {
    final comic = context.watch<ComicProvider>().byId(comicId);
    if (comic == null) {
      return const Scaffold(body: Center(child: Text('Không tìm thấy truyện')));
    }

    final library = context.watch<LibraryProvider>();
    final chapters = context.read<ComicRepository>().getChapters(comic);
    final current = library.currentChapterOf(comic);
    final bookmarked = library.isBookmarked(comic.id);

    return Scaffold(
      appBar: AppBar(
        title: Text(comic.title, maxLines: 1, overflow: TextOverflow.ellipsis),
        actions: [
          IconButton(
            icon: Icon(bookmarked ? Icons.bookmark : Icons.bookmark_border),
            onPressed: () => library.toggleBookmark(comic.id),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ComicDetailHeader(comic: comic),
          const SizedBox(height: 16),
          Text(comic.description, style: const TextStyle(height: 1.45)),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () {
              context.read<ReaderProvider>().open(
                comic,
                chapterNumber: current,
              );
              library.updateProgress(comic.id, current);
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ReaderScreen()),
              );
            },
            child: Text('Đọc tiếp chương $current'),
          ),
          const SizedBox(height: 16),
          Text(
            'Danh sách chương (${chapters.length} chương mẫu)',
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
          ),
          const SizedBox(height: 8),
          ...chapters.map(
            (chapter) => ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(chapter.title),
              trailing: chapter.number == current
                  ? const Text(
                      'Đang đọc',
                      style: TextStyle(color: AppTheme.textSecondary),
                    )
                  : null,
              onTap: () {
                context.read<ReaderProvider>().open(
                  comic,
                  chapterNumber: chapter.number,
                );
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ReaderScreen()),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
