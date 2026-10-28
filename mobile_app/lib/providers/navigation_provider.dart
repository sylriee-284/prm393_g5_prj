import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'comic_provider.dart';
import 'library_provider.dart';

/// Global navigator key để hiển thị dialog từ root navigator
final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

/// Quản lý tab hiện tại của màn hình chính (MainShell)
class NavigationProvider extends ChangeNotifier {
  int _currentTab = 0;
  int get currentTab => _currentTab;

  void setTab(int index) {
    if (_currentTab != index) {
      _currentTab = index;
      notifyListeners();
    }
  }
}

/// Hiển thị bảng hỏi đồng bộ tủ truyện khi người dùng vừa đăng nhập hoặc đăng ký thành công
Future<void> showLoginSyncDialog(BuildContext context, {String? fullName}) async {
  final shouldSync = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (dialogCtx) => AlertDialog(
      title: const Text('Đồng bộ tủ truyện'),
      content: const Text(
        'Bạn có muốn đồng bộ tủ truyện hiện tại trên máy với tài khoản không?',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogCtx).pop(false),
          child: const Text('Hủy'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(dialogCtx).pop(true),
          child: const Text('Đồng ý'),
        ),
      ],
    ),
  );

  if (!context.mounted) return;

  final library = context.read<LibraryProvider>();
  final comics = context.read<ComicProvider>();

  if (shouldSync == true) {
    await library.mergeLocalWithAccount();
    if (!context.mounted) return;
    await comics.refresh();
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Chào mừng ${fullName ?? "bạn"} quay trở lại! Đã đồng bộ tủ truyện với tài khoản.',
        ),
        backgroundColor: Colors.green.shade700,
      ),
    );
  } else {
    await library.loadAccountLibrary();
    if (!context.mounted) return;
    await comics.refresh();
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Chào mừng ${fullName ?? "bạn"}! Đã tải tủ truyện của tài khoản.',
        ),
        backgroundColor: Colors.blue.shade700,
      ),
    );
  }
}
