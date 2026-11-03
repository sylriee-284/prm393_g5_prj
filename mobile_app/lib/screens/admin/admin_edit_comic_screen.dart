import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/comic_enums.dart';
import '../../models/comic.dart';
import '../../providers/comic_provider.dart';
import 'admin_chapters_screen.dart';

class AdminEditComicScreen extends StatefulWidget {
  const AdminEditComicScreen({super.key, this.comic});

  final Comic? comic;

  @override
  State<AdminEditComicScreen> createState() => _AdminEditComicScreenState();
}

class _AdminEditComicScreenState extends State<AdminEditComicScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _titleController;
  late final TextEditingController _authorController;
  late final TextEditingController _descController;
  late final TextEditingController _coverUrlController;
  late final TextEditingController _coverLabelController;

  late ComicGenre _genre;
  late ComicStatus _status;
  late bool _isHidden;
  late int _coverColor;
  bool _isLoading = false;

  bool get isEditing => widget.comic != null;

  static const List<int> _presetColors = [
    0xFF1A365D, // Xanh đậm
    0xFF3E2723, // Nâu gỗ
    0xFF212121, // Xám đen
    0xFF1B5E20, // Xanh lục đậm
    0xFF4A148C, // Tím huyền ảo
    0xFF880E4F, // Đỏ mận
    0xFFB71C1C, // Đỏ tươi
    0xFF0D47A1, // Xanh biển
  ];

  @override
  void initState() {
    super.initState();
    final c = widget.comic;
    _titleController = TextEditingController(text: c?.title ?? '');
    _authorController = TextEditingController(text: c?.author ?? '');
    _descController = TextEditingController(text: c?.description ?? '');
    _coverUrlController = TextEditingController(text: c?.coverUrl ?? '');
    _coverLabelController = TextEditingController(text: c?.coverLabel ?? '');

    _genre = c?.genre ?? ComicGenre.tienHiep;
    _status = c?.status ?? ComicStatus.ongoing;
    _isHidden = c?.isHidden ?? false;
    _coverColor = c?.coverColor ?? _presetColors[0];
  }

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _descController.dispose();
    _coverUrlController.dispose();
    _coverLabelController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final comicProvider = context.read<ComicProvider>();

    final title = _titleController.text.trim();
    final author = _authorController.text.trim();
    final desc = _descController.text.trim();
    final coverUrl = _coverUrlController.text.trim();
    String coverLabel = _coverLabelController.text.trim();
    if (coverLabel.isEmpty) {
      coverLabel = title.length > 8 ? title.substring(0, 8).toUpperCase() : title.toUpperCase();
    }

    final data = <String, dynamic>{
      'title': title,
      'author': author,
      'description': desc,
      'coverUrl': coverUrl,
      'coverLabel': coverLabel,
      'coverColor': _coverColor,
      'genre': _genre.label,
      'status': _status.name,
      'isHidden': _isHidden,
    };

    final success = await comicProvider.saveComic(
      data,
      comicId: widget.comic?.id,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isEditing
                ? 'Đã cập nhật thông tin truyện thành công!'
                : 'Đã thêm truyện mới thành công!',
          ),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Không thể lưu truyện. Vui lòng kiểm tra lại kết nối mạng!'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Sửa Truyện' : 'Thêm Truyện Mới'),
        actions: [
          TextButton.icon(
            onPressed: _isLoading ? null : _save,
            icon: _isLoading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.check),
            label: const Text('Lưu'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Cảnh báo trạng thái hiển thị
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: _isHidden
                    ? Colors.orange.withValues(alpha: 0.15)
                    : Colors.green.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: _isHidden ? Colors.orange : Colors.green,
                  width: 1.2,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _isHidden ? Icons.visibility_off : Icons.visibility,
                    color: _isHidden ? Colors.orange.shade800 : Colors.green.shade800,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _isHidden
                              ? 'TRẠNG THÁI: ĐANG ẨN'
                              : 'TRẠNG THÁI: CÔNG KHAI',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: _isHidden ? Colors.orange.shade900 : Colors.green.shade900,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _isHidden
                              ? 'Độc giả sẽ không thấy truyện trong Khám Phá, Xếp Hạng hoặc Tìm Kiếm.'
                              : 'Tất cả độc giả đều có thể tìm thấy và đọc truyện bình thường.',
                          style: TextStyle(
                            fontSize: 12,
                            color: _isHidden ? Colors.orange.shade900 : Colors.green.shade900,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: !_isHidden,
                    activeTrackColor: Colors.green,
                    onChanged: (val) {
                      setState(() => _isHidden = !val);
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // TIÊU ĐỀ
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Tiêu đề truyện (*)',
                hintText: 'Nhập tên truyện...',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.book_outlined),
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Vui lòng nhập tên truyện' : null,
            ),
            const SizedBox(height: 16),

            // TÁC GIẢ
            TextFormField(
              controller: _authorController,
              decoration: const InputDecoration(
                labelText: 'Tác giả (*)',
                hintText: 'Nhập tên tác giả...',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person_outline),
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Vui lòng nhập tên tác giả' : null,
            ),
            const SizedBox(height: 16),

            // THỂ LOẠI & TRẠNG THÁI TIẾN ĐỘ
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<ComicGenre>(
                    initialValue: _genre,
                    decoration: const InputDecoration(
                      labelText: 'Thể loại',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.category_outlined),
                    ),
                    items: ComicGenre.values.map((g) {
                      return DropdownMenuItem(
                        value: g,
                        child: Text(g.label),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _genre = val);
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<ComicStatus>(
                    initialValue: _status,
                    decoration: const InputDecoration(
                      labelText: 'Tiến độ',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.timelapse),
                    ),
                    items: ComicStatus.values.map((s) {
                      return DropdownMenuItem(
                        value: s,
                        child: Text(s.label),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _status = val);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // LINK ẢNH BÌA
            TextFormField(
              controller: _coverUrlController,
              decoration: const InputDecoration(
                labelText: 'URL Ảnh bìa (Tùy chọn)',
                hintText: 'https://images.unsplash.com/...',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.image_outlined),
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 12),

            // PREVIEW BÌA
            if (_coverUrlController.text.trim().isNotEmpty) ...[
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    _coverUrlController.text.trim(),
                    height: 140,
                    width: 100,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => Container(
                      height: 140,
                      width: 100,
                      color: Color(_coverColor),
                      alignment: Alignment.center,
                      child: const Text('Lỗi ảnh', style: TextStyle(color: Colors.white70)),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // CHỌN MÀU NỀN BÌA
            const Text(
              'Màu nền bìa truyện (hiển thị khi không có ảnh hoặc lúc tải):',
              style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: _presetColors.map((colorVal) {
                final isSelected = _coverColor == colorVal;
                return InkWell(
                  onTap: () => setState(() => _coverColor = colorVal),
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: Color(colorVal),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? Colors.white : Colors.transparent,
                        width: 3,
                      ),
                      boxShadow: [
                        if (isSelected)
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.3),
                            blurRadius: 4,
                            spreadRadius: 1,
                          ),
                      ],
                    ),
                    child: isSelected
                        ? const Icon(Icons.check, color: Colors.white, size: 20)
                        : null,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // NHÃN BÌA
            TextFormField(
              controller: _coverLabelController,
              decoration: const InputDecoration(
                labelText: 'Chữ in trên bìa (Tùy chọn)',
                hintText: 'Ví dụ: LINH SỦNG, ĐẤU PHÁ...',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.label_outline),
              ),
            ),
            const SizedBox(height: 16),

            // MÔ TẢ TRUYỆN
            TextFormField(
              controller: _descController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Mô tả nội dung tóm tắt',
                hintText: 'Nhập tóm tắt cốt truyện...',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 24),

            // NÚT LƯU
            FilledButton.icon(
              onPressed: _isLoading ? null : _save,
              icon: const Icon(Icons.save),
              label: Text(
                isEditing ? 'Cập nhật truyện' : 'Thêm truyện mới',
                style: const TextStyle(fontSize: 16),
              ),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),

            if (isEditing) ...[
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AdminChaptersScreen(comic: widget.comic!),
                    ),
                  );
                },
                icon: const Icon(Icons.library_books_outlined),
                label: Text('Quản lý các chương (${widget.comic!.totalChapters} chương)'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
