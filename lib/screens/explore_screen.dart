import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/app_theme.dart';
import '../core/comic_enums.dart';
import '../models/comic.dart';
import '../providers/comic_provider.dart';
import '../providers/library_provider.dart';
import '../providers/reader_provider.dart';
import '../widgets/comic_cover.dart';
import '../widgets/explore_card.dart';
import 'comic_detail_screen.dart';
import 'reader_screen.dart';
import 'search_screen.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  String? _selectedFeaturedId;

  void _showFilterSheet(BuildContext context) {
    final comicProvider = context.read<ComicProvider>();
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Lọc theo trạng thái',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  children: [
                    FilterChip(
                      label: const Text('Tất cả'),
                      selected: comicProvider.statusFilter == null,
                      onSelected: (_) {
                        comicProvider.setStatusFilter(null);
                        Navigator.pop(ctx);
                      },
                    ),
                    FilterChip(
                      label: const Text('Đang ra'),
                      selected:
                          comicProvider.statusFilter == ComicStatus.ongoing,
                      onSelected: (_) {
                        comicProvider.setStatusFilter(ComicStatus.ongoing);
                        Navigator.pop(ctx);
                      },
                    ),
                    FilterChip(
                      label: const Text('Hoàn thành'),
                      selected:
                          comicProvider.statusFilter == ComicStatus.completed,
                      onSelected: (_) {
                        comicProvider.setStatusFilter(ComicStatus.completed);
                        Navigator.pop(ctx);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppTheme.textPrimary,
        ),
      ),
    );
  }

  Widget _buildFeaturedCard(BuildContext context, Comic comic) {
    final isBookmarked = context.watch<LibraryProvider>().isBookmarked(
      comic.id,
    );

    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ComicDetailScreen(comicId: comic.id),
          ),
        );
      },
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  comic.genre.label,
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  comic.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  comic.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 12,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    ...List.generate(
                      5,
                      (i) =>
                          const Icon(Icons.star, size: 16, color: Colors.amber),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      comic.rating.toStringAsFixed(1),
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppTheme.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        shape: const StadiumBorder(),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 8,
                        ),
                        minimumSize: const Size(0, 36),
                      ),
                      onPressed: () {
                        context.read<ReaderProvider>().open(comic);
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const ReaderScreen(),
                          ),
                        );
                      },
                      child: const Text(
                        'Đọc',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                    const SizedBox(width: 10),
                    InkWell(
                      onTap: () {
                        final lib = context.read<LibraryProvider>();
                        final willBookmark = !lib.isBookmarked(comic.id);
                        lib.toggleBookmark(comic.id);
                        ScaffoldMessenger.of(context).clearSnackBars();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              willBookmark
                                  ? 'Đã thêm vào Tủ Truyện'
                                  : 'Đã xóa khỏi Tủ Truyện',
                            ),
                            duration: const Duration(seconds: 1),
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: const BoxDecoration(
                          color: Color(0xFF1E3A5F),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isBookmarked ? Icons.check : Icons.add,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          ComicCover(comic: comic, width: 120, height: 165, borderRadius: 10),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final comicProvider = context.watch<ComicProvider>();
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    final latestComics = comicProvider.filterByStatus(comicProvider.latest);
    final recommendedComics = comicProvider
        .filterByStatus(comicProvider.recommended)
        .take(6)
        .toList();
    final completedComics = comicProvider.completed;

    final featuredComic = latestComics.firstWhere(
      (c) => c.id == _selectedFeaturedId,
      orElse: () => latestComics.isNotEmpty
          ? latestComics.first
          : comicProvider.comics.first,
    );

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 16,
        title: Row(
          children: [
            PopupMenuButton<ComicStatus?>(
              initialValue: comicProvider.statusFilter,
              onSelected: (status) {
                comicProvider.setStatusFilter(status);
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    comicProvider.statusFilter?.label ?? 'Tất cả',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const Icon(
                    Icons.keyboard_arrow_down,
                    size: 20,
                    color: AppTheme.textPrimary,
                  ),
                ],
              ),
              itemBuilder: (context) => [
                const PopupMenuItem(value: null, child: Text('Tất cả')),
                const PopupMenuItem(
                  value: ComicStatus.ongoing,
                  child: Text('Đang ra'),
                ),
                const PopupMenuItem(
                  value: ComicStatus.completed,
                  child: Text('Hoàn thành'),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: AppTheme.textPrimary),
            onPressed: () {
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const SearchScreen()));
            },
          ),
          IconButton(
            icon: const Icon(Icons.tune_outlined, color: AppTheme.textPrimary),
            onPressed: () => _showFilterSheet(context),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (latestComics.isNotEmpty) ...[
              _buildSectionHeader('Mới nhất'),
              const SizedBox(height: 10),
              SizedBox(
                height: 72,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: latestComics.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final comic = latestComics[index];
                    final isSelected = comic.id == featuredComic.id;
                    return GestureDetector(
                      onTap: () =>
                          setState(() => _selectedFeaturedId = comic.id),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(6),
                          border: isSelected
                              ? Border.all(color: Colors.blueAccent, width: 2)
                              : null,
                        ),
                        child: ComicCover(
                          comic: comic,
                          width: 48,
                          height: 68,
                          borderRadius: 4,
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              _buildFeaturedCard(context, featuredComic),
              const SizedBox(height: 24),
            ],

            _buildSectionHeader('Đề cử'),
            const SizedBox(height: 12),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.zero,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: isLandscape ? 5 : 3,
                mainAxisSpacing: 16,
                crossAxisSpacing: 12,
                childAspectRatio: 0.58,
              ),
              itemCount: recommendedComics.length,
              itemBuilder: (context, index) {
                return ExploreCard(
                  comic: recommendedComics[index],
                  showGenre: index >= (isLandscape ? 5 : 3),
                );
              },
            ),
            const SizedBox(height: 24),

            if (comicProvider.statusFilter == null &&
                completedComics.isNotEmpty) ...[
              _buildSectionHeader('Hoàn thành'),
              const SizedBox(height: 12),
              SizedBox(
                height: 180,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: completedComics.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    final comic = completedComics[index];
                    return SizedBox(
                      width: 105,
                      child: ExploreCard(comic: comic),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
            ],
          ],
        ),
      ),
    );
  }
}
