import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/app_theme.dart';
import '../core/constants.dart';
import '../models/comic.dart';
import '../providers/comic_provider.dart';
import '../providers/library_provider.dart';
import '../providers/reader_provider.dart';
import '../widgets/comic_cover.dart';
import 'comic_detail_screen.dart';
import 'reader_screen.dart';
import 'search_screen.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final library = context.watch<LibraryProvider>();
    final comics = context.watch<ComicProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppConstants.appName),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SearchScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                builder: (ctx) => const _LibrarySettingsSheet(),
              );
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(44),
          child: Align(
            alignment: Alignment.centerLeft,
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              labelColor: AppTheme.textPrimary,
              unselectedLabelColor: AppTheme.tabInactive,
              labelStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              unselectedLabelStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
              indicatorColor: AppTheme.textPrimary,
              indicatorWeight: 2.5,
              indicatorSize: TabBarIndicatorSize.label,
              dividerColor: Colors.transparent,
              tabs: const [
                Tab(text: AppConstants.tabHistory),
                Tab(text: AppConstants.tabBookmark),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _LibraryList(
            entries: library.history,
            comics: comics,
            emptyLabel: 'Chưa có lịch sử đọc',
          ),
          _LibraryList(
            entries: library.bookmarks,
            comics: comics,
            emptyLabel: 'Chưa có truyện đánh dấu',
          ),
        ],
      ),
    );
  }
}

class _LibraryList extends StatelessWidget {
  const _LibraryList({
    required this.entries,
    required this.comics,
    required this.emptyLabel,
  });

  final List<LibraryEntry> entries;
  final ComicProvider comics;
  final String emptyLabel;

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) {
      return Center(
        child: Text(
          emptyLabel,
          style: const TextStyle(color: AppTheme.textSecondary),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 8, 8, 16),
      itemCount: entries.length,
      separatorBuilder: (_, _) => const SizedBox(height: 4),
      itemBuilder: (context, index) {
        final entry = entries[index];
        final comic = comics.byId(entry.comicId);
        if (comic == null) return const SizedBox.shrink();
        return _LibraryRow(comic: comic, entry: entry);
      },
    );
  }
}

class _LibraryRow extends StatelessWidget {
  const _LibraryRow({required this.comic, required this.entry});

  final Comic comic;
  final LibraryEntry entry;

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
                entry.notifyEnabled
                    ? Icons.notifications_none
                    : Icons.notifications_off_outlined,
                color: AppTheme.textSecondary,
              ),
              onPressed: () {
                library.toggleNotify(comic.id);
                final enabled = library.entryOf(comic.id)?.notifyEnabled ?? false;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      enabled
                          ? 'Đã bật thông báo chương mới'
                          : 'Đã tắt thông báo',
                    ),
                    duration: const Duration(seconds: 1),
                  ),
                );
              },
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
                  entry.notifyEnabled
                      ? Icons.notifications_off_outlined
                      : Icons.notifications_none,
                ),
                title: Text(
                  entry.notifyEnabled ? 'Tắt thông báo' : 'Bật thông báo',
                ),
                onTap: () {
                  library.toggleNotify(comic.id);
                  Navigator.pop(ctx);
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
}

class _LibrarySettingsSheet extends StatelessWidget {
  const _LibrarySettingsSheet();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Cài đặt tủ truyện',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            const Text(
              'Nhấn vào truyện để tiếp tục đọc. Giữ để xem chi tiết. '
              'Chuông bật/tắt thông báo chương mới.',
              style: TextStyle(color: AppTheme.textSecondary, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }
}
