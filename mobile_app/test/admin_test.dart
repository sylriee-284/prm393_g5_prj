import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prm393_project_g5/core/comic_enums.dart';
import 'package:prm393_project_g5/models/comic.dart';
import 'package:prm393_project_g5/providers/comic_provider.dart';
import 'package:prm393_project_g5/repositories/comic_repository.dart';
import 'package:prm393_project_g5/screens/admin/admin_comics_screen.dart';
import 'package:prm393_project_g5/screens/admin/admin_edit_comic_screen.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

final _testComics = [
  const Comic(
    id: 'c_public',
    title: 'Truyện Đang Công Khai',
    author: 'Tác Giả A',
    description: 'Mô tả truyện công khai',
    coverColor: 0xFF1A365D,
    coverLabel: 'CÔNG KHAI',
    totalChapters: 10,
    genre: ComicGenre.tienHiep,
    isHidden: false,
  ),
  const Comic(
    id: 'c_hidden',
    title: 'Truyện Đang Bị Ẩn',
    author: 'Tác Giả B',
    description: 'Mô tả truyện bị ẩn',
    coverColor: 0xFF3E2723,
    coverLabel: 'BỊ ẨN',
    totalChapters: 5,
    genre: ComicGenre.huyenHuyen,
    isHidden: true,
  ),
];

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('AdminComicsScreen hiển thị danh sách truyện công khai và ẩn cùng badge', (tester) async {
    final repo = ComicRepository(initialComics: _testComics);
    final provider = ComicProvider(repo);

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider.value(value: repo),
          ChangeNotifierProvider.value(value: provider),
        ],
        child: const MaterialApp(
          home: AdminComicsScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Quản Lý Truyện'), findsOneWidget);
    expect(find.text('Truyện Đang Công Khai'), findsOneWidget);
    expect(find.text('Truyện Đang Bị Ẩn'), findsOneWidget);
    expect(find.text('Công Khai'), findsOneWidget);
    expect(find.text('Đang Ẩn'), findsOneWidget);
    expect(find.text('Thêm truyện mới'), findsOneWidget);
  });

  testWidgets('AdminEditComicScreen hiển thị switch chuyển trạng thái Ẩn/Công khai', (tester) async {
    final repo = ComicRepository(initialComics: _testComics);
    final provider = ComicProvider(repo);

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider.value(value: repo),
          ChangeNotifierProvider.value(value: provider),
        ],
        child: MaterialApp(
          home: AdminEditComicScreen(comic: _testComics[0]),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Sửa Truyện'), findsOneWidget);
    expect(find.text('TRẠNG THÁI: CÔNG KHAI'), findsOneWidget);
    expect(find.text('Lưu'), findsOneWidget);
    expect(find.byType(Switch), findsOneWidget);
  });
}
