import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/app_theme.dart';
import '../core/comic_enums.dart';
import '../core/constants.dart';
import '../models/comic.dart';
import '../providers/library_provider.dart';
import '../providers/reader_provider.dart';
import '../screens/comic_detail_screen.dart';
import '../screens/reader_screen.dart';
import 'comic_cover.dart';

class LibraryRow extends StatelessWidget {
  const LibraryRow({
    super.key,
    required this.comic,
    required this.entry,
  });

  final Comic comic;
  final LibraryEntry entry;

  void _onNotifyTap(BuildContext context, LibraryProvider library) {
    switch (library.notificationSetting) {
      case NotificationSetting.all:
        library.toggleNotify(comic.id);
        final enabled = library.entryOf(comic.id)?.notifyEnabled ?? false;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              enabled ? 'Đã bật thông báo chương mới' : 'Đã tắt thông báo',
            ),
            duration: const Duration(seconds: 1),
          ),
        );
        return;
      case NotificationSetting.favoriteOnly:
      case NotificationSetting.off:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(library.notificationSetting.label),
            duration: const Duration(seconds: 1),
          ),
        );
    }
  }

  void _showActions(BuildContext context, LibraryProvider library) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: const Text('Chi tiết truyện'),
                onTap: () {
                  Navigator.pop(ctx);
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => ComicDetailScreen(comicId: comic.id),
                    ),
                  );
                },
              ),
              ListTile(
                leading: Icon(
                  library.isBookmarked(comic.id)
                      ? Icons.bookmark
                      : Icons.bookmark_border,
                ),
                title: Text(
                  library.isBookmarked(comic.id)
                      ? 'Bỏ đánh dấu'
                      : 'Đánh dấu',
                ),
                onTap: () {
                  library.toggleBookmark(comic.id);
                  Navigator.pop(ctx);
                },
              ),
              ListTile(
                leading: Icon(
                  library.isNotifyEnabled(comic.id)
                      ? Icons.notifications_off_outlined
                      : Icons.notifications_none,
                ),
                title: Text(
                  library.isNotifyEnabled(comic.id)
                      ? 'Tắt thông báo'
                      : 'Bật thông báo',
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  _onNotifyTap(context, library);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete_outline),
                title: const Text('Xóa khỏi lịch sử'),
                onTap: () {
                  library.removeFromHistory(comic.id);
                  Navigator.pop(ctx);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final library = context.read<LibraryProvider>();

    return InkWell(
      onTap: () {
        context.read<ReaderProvider>().open(
          comic,
          chapterNumber: entry.currentChapter,
        );
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const ReaderScreen()),
        );
      },
      onLongPress: () {
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
            ComicCover(comic: comic),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    comic.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.textPrimary,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${AppConstants.readProgressPrefix} ${entry.currentChapter}/${comic.totalChapters}',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              visualDensity: VisualDensity.compact,
              icon: Icon(
                library.isNotifyEnabled(comic.id)
                    ? Icons.notifications_none
                    : Icons.notifications_off_outlined,
                color: AppTheme.textSecondary,
              ),
              onPressed: () => _onNotifyTap(context, library),
            ),
            IconButton(
              visualDensity: VisualDensity.compact,
              icon: const Icon(Icons.more_vert, color: AppTheme.textSecondary),
              onPressed: () => _showActions(context, library),
            ),
          ],
        ),
      ),
    );
  }
}
