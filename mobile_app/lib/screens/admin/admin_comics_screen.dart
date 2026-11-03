import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/app_theme.dart';
import '../../models/comic.dart';
import '../../providers/comic_provider.dart';
import 'admin_chapters_screen.dart';
import 'admin_edit_comic_screen.dart';

class AdminComicsScreen extends StatefulWidget {
  const AdminComicsScreen({super.key});

  @override
  State<AdminComicsScreen> createState() => _AdminComicsScreenState();
}

class _AdminComicsScreenState extends State<AdminComicsScreen> {
  List<Comic> _allComics = [];
  bool _isLoading = true;
  String _searchQuery = '';
  int _selectedFilter = 0; // 0: Tất cả, 1: Công khai, 2: Đang ẩn

  @override
  void initState() {
    super.initState();
    _loadComics();
  }

  Future<void> _loadComics() async {
    setState(() => _isLoading = true);
    final comicProvider = context.read<ComicProvider>();
    final list = await comicProvider.getAdminComics();
    if (mounted) {
      setState(() {
        _allComics = list;
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleVisibility(Comic comic) async {
    final newHidden = !comic.isHidden;
    final comicProvider = context.read<ComicProvider>();
    final success = await comicProvider.toggleComicVisibility(comic.id, newHidden);

    if (!mounted) return;
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            newHidden
                ? 'Đã chuyển truyện "${comic.title}" sang trạng thái ẨN'
                : 'Đã chuyển truyện "${comic.title}" sang trạng thái CÔNG KHAI',
          ),
          backgroundColor: newHidden ? Colors.orange : Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
      _loadComics();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Không thể đổi trạng thái. Vui lòng kiểm tra lại kết nối mạng!'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _openAddComic() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const AdminEditComicScreen()),
    );
    if (result == true) {
      _loadComics();
    }
  }

  void _openEditComic(Comic comic) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => AdminEditComicScreen(comic: comic)),
    );
    if (result == true) {
      _loadComics();
    }
  }

  void _confirmDelete(Comic comic) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xác nhận xóa truyện'),
        content: Text('Bạn có chắc chắn muốn xóa bộ truyện "${comic.title}" không? Thao tác này sẽ xóa toàn bộ các chương liên quan.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Hủy'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(ctx);
              final provider = context.read<ComicProvider>();
              final success = await provider.deleteComic(comic.id);
              if (!mounted) return;
              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Đã xóa bộ truyện thành công'),
                    backgroundColor: Colors.green,
                  ),
                );
                _loadComics();
              }
            },
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }

  List<Comic> get _filteredComics {
    var list = _allComics;

    // Lọc theo từ khóa tìm kiếm
    if (_searchQuery.trim().isNotEmpty) {
      final q = _searchQuery.trim().toLowerCase();
      list = list
          .where(
            (c) =>
                c.title.toLowerCase().contains(q) ||
                c.author.toLowerCase().contains(q) ||
                c.genre.label.toLowerCase().contains(q),
          )
          .toList();
    }

    // Lọc theo trạng thái ẩn / công khai
    if (_selectedFilter == 1) {
      list = list.where((c) => !c.isHidden).toList();
    } else if (_selectedFilter == 2) {
      list = list.where((c) => c.isHidden).toList();
    }

    return list;
  }

  @override
  Widget build(BuildContext context) {
    final publicCount = _allComics.where((c) => !c.isHidden).length;
    final hiddenCount = _allComics.where((c) => c.isHidden).length;
    final displayedComics = _filteredComics;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản Lý Truyện'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Làm mới',
            onPressed: _loadComics,
          ),
        ],
      ),
      body: Column(
        children: [
          // 1. THANH TÌM KIẾM
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Tìm theo tên truyện, tác giả...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => setState(() => _searchQuery = ''),
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (val) => setState(() => _searchQuery = val),
            ),
          ),

          // 2. BỘ LỌC CHIPS (Cuộn ngang để tránh tràn màn hình)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                ChoiceChip(
                  label: Text('Tất cả (${_allComics.length})'),
                  selected: _selectedFilter == 0,
                  onSelected: (_) => setState(() => _selectedFilter = 0),
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: Text('Công khai ($publicCount)'),
                  selected: _selectedFilter == 1,
                  avatar: const Icon(Icons.visibility, size: 16, color: Colors.green),
                  onSelected: (_) => setState(() => _selectedFilter = 1),
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: Text('Đang ẩn ($hiddenCount)'),
                  selected: _selectedFilter == 2,
                  avatar: const Icon(Icons.visibility_off, size: 16, color: Colors.orange),
                  onSelected: (_) => setState(() => _selectedFilter = 2),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // 3. DANH SÁCH TRUYỆN
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : displayedComics.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.menu_book_outlined,
                              size: 56,
                              color: Theme.of(context).colorScheme.outline,
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'Không tìm thấy bộ truyện nào',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadComics,
                        child: ListView.separated(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
                          itemCount: displayedComics.length,
                          separatorBuilder: (_, _) => const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final comic = displayedComics[index];
                            final isHidden = comic.isHidden;

                            return Card(
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(
                                  color: isHidden
                                      ? Colors.orange.withValues(alpha: 0.5)
                                      : Theme.of(context).dividerColor,
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  children: [
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // Ảnh bìa
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(8),
                                          child: comic.coverUrl.isNotEmpty
                                              ? Image.network(
                                                  comic.coverUrl,
                                                  width: 55,
                                                  height: 75,
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (_, _, _) => Container(
                                                    width: 55,
                                                    height: 75,
                                                    color: Color(comic.coverColor),
                                                    alignment: Alignment.center,
                                                    child: Text(
                                                      comic.coverLabel,
                                                      textAlign: TextAlign.center,
                                                      style: const TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 9,
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                )
                                              : Container(
                                                  width: 55,
                                                  height: 75,
                                                  color: Color(comic.coverColor),
                                                  alignment: Alignment.center,
                                                  child: Text(
                                                    comic.coverLabel,
                                                    textAlign: TextAlign.center,
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 9,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                        ),
                                        const SizedBox(width: 12),

                                        // Thông tin truyện
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                comic.title,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                ),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                'Tác giả: ${comic.author}',
                                                style: const TextStyle(
                                                  fontSize: 13,
                                                  color: AppTheme.textSecondary,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Wrap(
                                                spacing: 6,
                                                children: [
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(
                                                      horizontal: 6,
                                                      vertical: 2,
                                                    ),
                                                    decoration: BoxDecoration(
                                                      color: Theme.of(context).colorScheme.primaryContainer,
                                                      borderRadius: BorderRadius.circular(4),
                                                    ),
                                                    child: Text(
                                                      comic.genre.label,
                                                      style: TextStyle(
                                                        fontSize: 11,
                                                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                                                      ),
                                                    ),
                                                  ),
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(
                                                      horizontal: 6,
                                                      vertical: 2,
                                                    ),
                                                    decoration: BoxDecoration(
                                                      color: Theme.of(context).colorScheme.surfaceContainerHighest,
                                                      borderRadius: BorderRadius.circular(4),
                                                    ),
                                                    child: Text(
                                                      '${comic.totalChapters} chương',
                                                      style: const TextStyle(fontSize: 11),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    const Divider(height: 1),
                                    const SizedBox(height: 6),

                                    // HÀNG QUẢN TRỊ TRẠNG THÁI & NÚT HÀNH ĐỘNG
                                    Row(
                                      children: [
                                        // Badge trạng thái & Toggle Switch
                                        InkWell(
                                          onTap: () => _toggleVisibility(comic),
                                          borderRadius: BorderRadius.circular(6),
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 4,
                                              vertical: 2,
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(
                                                  isHidden ? Icons.visibility_off : Icons.visibility,
                                                  size: 16,
                                                  color: isHidden ? Colors.orange.shade800 : Colors.green.shade800,
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  isHidden ? 'Đang Ẩn' : 'Công Khai',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.bold,
                                                    color: isHidden ? Colors.orange.shade900 : Colors.green.shade900,
                                                  ),
                                                ),
                                                const SizedBox(width: 4),
                                                Switch(
                                                  value: !isHidden,
                                                  activeTrackColor: Colors.green,
                                                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                                  onChanged: (_) => _toggleVisibility(comic),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        const Spacer(),

                                        // Nút Quản lý chương
                                        IconButton(
                                          icon: const Icon(Icons.playlist_add),
                                          tooltip: 'Quản lý chương',
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (_) => AdminChaptersScreen(comic: comic),
                                              ),
                                            ).then((_) => _loadComics());
                                          },
                                        ),

                                        // Nút Sửa truyện
                                        IconButton(
                                          icon: const Icon(Icons.edit_outlined),
                                          tooltip: 'Sửa thông tin',
                                          onPressed: () => _openEditComic(comic),
                                        ),

                                        // Nút Xóa truyện
                                        IconButton(
                                          icon: const Icon(Icons.delete_outline, color: Colors.red),
                                          tooltip: 'Xóa truyện',
                                          onPressed: () => _confirmDelete(comic),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddComic,
        icon: const Icon(Icons.add),
        label: const Text('Thêm truyện mới'),
      ),
    );
  }
}
