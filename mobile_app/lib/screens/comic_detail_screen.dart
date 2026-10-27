import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/app_theme.dart';
import '../models/chapter.dart';
import '../providers/comic_provider.dart';
import '../providers/library_provider.dart';
import '../providers/reader_provider.dart';
import '../repositories/comic_repository.dart';
import '../widgets/comic_detail_header.dart';
import 'reader_screen.dart';

class ComicDetailScreen extends StatefulWidget {
  const ComicDetailScreen({super.key, required this.comicId});

  final String comicId;

  @override
  State<ComicDetailScreen> createState() => _ComicDetailScreenState();
}

class _ComicDetailScreenState extends State<ComicDetailScreen> {
  List<Chapter>? _apiChapters;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadChapters());
  }

  Future<void> _loadChapters() async {
    final comic = context.read<ComicProvider>().byId(widget.comicId);
    if (comic != null) {
      final chapters = await context.read<ComicRepository>().fetchChaptersFromBackend(comic);
      if (mounted) {
        setState(() => _apiChapters = chapters);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final comic = context.watch<ComicProvider>().byId(widget.comicId);
    if (comic == null) {
      return const Scaffold(body: Center(child: Text('Không tìm thấy truyện')));
    }

    final library = context.watch<LibraryProvider>();
    final chapters = _apiChapters ?? context.read<ComicRepository>().getChapters(comic);
    final isLoadingChapters = _apiChapters == null && chapters.isEmpty;
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
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const ReaderScreen()));
            },
            child: Text('Đọc tiếp chương $current'),
          ),
          const SizedBox(height: 16),
          Text(
            isLoadingChapters
                ? 'Danh sách chương (Đang tải...)'
                : 'Danh sách chương (${chapters.length} chương)',
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
          ),
          const SizedBox(height: 8),
          if (isLoadingChapters)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
          else if (chapters.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Text(
                'Truyện chưa có chương nào trên hệ thống.',
                style: TextStyle(color: AppTheme.textSecondary),
              ),
            )
          else
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
                library.updateProgress(comic.id, chapter.number);
                Navigator.of(
                  context,
                ).push(MaterialPageRoute(builder: (_) => const ReaderScreen()));
              },
            ),
          ),
        ],
      ),
    );
  }
}
