import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/chapter.dart';
import '../../models/comic.dart';
import '../../providers/comic_provider.dart';

class AdminEditChapterScreen extends StatefulWidget {
  const AdminEditChapterScreen({
    super.key,
    required this.comic,
    this.chapter,
    this.suggestedNumber = 1,
  });

  final Comic comic;
  final Chapter? chapter;
  final int suggestedNumber;

  @override
  State<AdminEditChapterScreen> createState() => _AdminEditChapterScreenState();
}

class _AdminEditChapterScreenState extends State<AdminEditChapterScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _numberController;
  late final TextEditingController _titleController;
  late final TextEditingController _contentController;
  bool _isLoading = false;

  bool get isEditing => widget.chapter != null;

  @override
  void initState() {
    super.initState();
    final numVal = widget.chapter?.number ?? widget.suggestedNumber;
    _numberController = TextEditingController(text: numVal.toString());
    _titleController = TextEditingController(
      text: widget.chapter?.title ?? 'Chương $numVal: ',
    );
    _contentController = TextEditingController(
      text: widget.chapter?.content ?? '',
    );

    // Nếu đang sửa mà chưa có nội dung đầy đủ (nội dung mới chỉ có tiêu đề từ danh sách), tải từ backend
    if (isEditing && (widget.chapter!.content.isEmpty)) {
      _loadFullChapterContent();
    }
  }

  Future<void> _loadFullChapterContent() async {
    setState(() => _isLoading = true);
    final comicProvider = context.read<ComicProvider>();
    final fullChapter = await comicProvider.fetchChapterDetail(
      widget.comic.id,
      widget.chapter!.number,
    );
    if (fullChapter != null && mounted) {
      _contentController.text = fullChapter.content;
    }
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  void dispose() {
    _numberController.dispose();
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final number = int.tryParse(_numberController.text.trim()) ?? 1;
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();

    setState(() => _isLoading = true);
    final comicProvider = context.read<ComicProvider>();

    final success = await comicProvider.saveChapter(
      widget.comic.id,
      number: number,
      title: title,
      content: content,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isEditing
                ? 'Đã cập nhật Chương $number thành công!'
                : 'Đã thêm Chương $number thành công!',
          ),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Không thể lưu chương. Vui lòng kiểm tra lại kết nối mạng!'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Sửa Chương ${widget.chapter!.number}' : 'Thêm Chương Mới'),
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
      body: _isLoading && _contentController.text.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.menu_book, color: Colors.blue),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            widget.comic.title,
                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _numberController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Số thứ tự chương (*)',
                      hintText: 'Ví dụ: 1, 2, 3...',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.tag),
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Vui lòng nhập số chương';
                      if (int.tryParse(v.trim()) == null) return 'Số chương phải là số nguyên';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'Tiêu đề chương (*)',
                      hintText: 'Ví dụ: Chương 1: Bảng trò chơi thức tỉnh',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.title),
                    ),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Vui lòng nhập tiêu đề chương' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _contentController,
                    maxLines: 14,
                    decoration: const InputDecoration(
                      labelText: 'Nội dung chương (*)',
                      hintText: 'Nhập hoặc dán nội dung chữ của chương truyện tại đây...',
                      border: OutlineInputBorder(),
                      alignLabelWithHint: true,
                    ),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Vui lòng nhập nội dung chương truyện' : null,
                  ),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: _isLoading ? null : _save,
                    icon: const Icon(Icons.save),
                    label: Text(
                      isEditing ? 'Cập nhật chương truyện' : 'Đăng chương truyện',
                      style: const TextStyle(fontSize: 16),
                    ),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
