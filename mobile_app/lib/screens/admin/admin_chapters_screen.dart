import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/app_theme.dart';
import '../../models/chapter.dart';
import '../../models/comic.dart';
import '../../repositories/comic_repository.dart';
import 'admin_edit_chapter_screen.dart';

class AdminChaptersScreen extends StatefulWidget {
  const AdminChaptersScreen({super.key, required this.comic});

  final Comic comic;

  @override
  State<AdminChaptersScreen> createState() => _AdminChaptersScreenState();
}

class _AdminChaptersScreenState extends State<AdminChaptersScreen> {
  List<Chapter> _chapters = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadChapters();
  }

  Future<void> _loadChapters() async {
    setState(() => _isLoading = true);
    final repo = context.read<ComicRepository>();
    final list = await repo.fetchChaptersFromBackend(widget.comic);
    if (mounted) {
      setState(() {
        _chapters = list;
        _isLoading = false;
      });
    }
  }

  void _openAddChapter() async {
    final nextNumber = _chapters.isEmpty
        ? 1
        : (_chapters.map((c) => c.number).fold(0, (max, n) => n > max ? n : max) + 1);

    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => AdminEditChapterScreen(
          comic: widget.comic,
          suggestedNumber: nextNumber,
        ),
      ),
    );

    if (result == true) {
      _loadChapters();
    }
  }

  void _openEditChapter(Chapter chapter) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => AdminEditChapterScreen(
          comic: widget.comic,
          chapter: chapter,
        ),
      ),
    );

    if (result == true) {
      _loadChapters();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chương: ${widget.comic.title}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Tải lại',
            onPressed: _loadChapters,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadChapters,
              child: _chapters.isEmpty
                  ? ListView(
                      children: [
                        const SizedBox(height: 100),
                        Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.auto_stories_outlined,
                                size: 64,
                                color: Theme.of(context).colorScheme.outline,
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'Truyện chưa có chương nào',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Bấm nút "+" bên dưới để đăng chương đầu tiên!',
                                style: TextStyle(color: AppTheme.textSecondary),
                              ),
                            ],
                          ),
                        ),
                      ],
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
                      itemCount: _chapters.length,
                      separatorBuilder: (_, _) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final ch = _chapters[index];
                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          leading: CircleAvatar(
                            radius: 18,
                            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                            child: Text(
                              '${ch.number}',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.onPrimaryContainer,
                              ),
                            ),
                          ),
                          title: Text(
                            ch.title,
                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                          ),
                          subtitle: ch.content.isNotEmpty
                              ? Text(
                                  ch.content.replaceAll('\n', ' '),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppTheme.textSecondary,
                                  ),
                                )
                              : null,
                          trailing: const Icon(Icons.edit_outlined, size: 20),
                          onTap: () => _openEditChapter(ch),
                        );
                      },
                    ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddChapter,
        icon: const Icon(Icons.add),
        label: const Text('Thêm chương mới'),
      ),
    );
  }
}

