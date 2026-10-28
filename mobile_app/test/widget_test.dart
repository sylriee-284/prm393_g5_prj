import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prm393_project_g5/core/comic_enums.dart';
import 'package:prm393_project_g5/main.dart';
import 'package:prm393_project_g5/models/comic.dart';
import 'package:prm393_project_g5/repositories/comic_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

final _testComics = [
  const Comic(
    id: 'c2',
    title: 'Thanh Liên Chi Đỉnh',
    author: 'Mộng Nhập Thần Cơ',
    description: 'Con đường tu tiên khắc nghiệt dẫn tới đỉnh cao thanh liên.',
    coverColor: 0xFF3E2723,
    coverLabel: 'THANH LIÊN',
    coverUrl: '',
    totalChapters: 4900,
    genre: ComicGenre.tienHiep,
    views: 1250000,
    status: ComicStatus.completed,
    rating: 4.9,
  ),
  const Comic(
    id: 'c7',
    title: 'Nguyên Tôn',
    author: 'Thiên Tằm Thổ Đậu',
    description: 'Thiên địa vi lô...',
    coverColor: 0xFF212121,
    coverLabel: 'NGUYÊN TÔN',
    coverUrl: '',
    totalChapters: 1497,
    genre: ComicGenre.huyenHuyen,
    views: 4500000,
    status: ComicStatus.ongoing,
    rating: 4.9,
  ),
  const Comic(
    id: 'c0',
    title: 'Linh Sủng Của Ta Có Được Bảng Trò Chơi',
    author: 'Tiểu Hà Hướng Tây Lưu',
    description: 'Đại Tây Dương chỗ sâu...',
    coverColor: 0xFF1A365D,
    coverLabel: 'LINH SỦNG',
    coverUrl: '',
    totalChapters: 680,
    genre: ComicGenre.kyAo,
    views: 1900000,
    status: ComicStatus.ongoing,
    rating: 5.0,
  ),
];

Widget _buildTestApp() {
  return NovelApp(comicRepository: ComicRepository(initialComics: _testComics));
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('Library screen shows history tab', (WidgetTester tester) async {
    await tester.pumpWidget(_buildTestApp());
    await tester.pumpAndSettle();

    expect(find.text('Tủ Truyện'), findsWidgets);
    expect(find.text('Lịch sử'), findsOneWidget);
    expect(find.text('Đánh dấu'), findsOneWidget);
    expect(find.textContaining('Thanh Liên Chi Đỉnh'), findsOneWidget);
  });

  testWidgets('Explore screen shows 3 columns in portrait and 5 in landscape', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(_buildTestApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Khám Phá'));
    await tester.pumpAndSettle();

    GridView grid = tester.widget(find.byType(GridView));
    var delegate =
        grid.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount;
    expect(delegate.crossAxisCount, 3);

    // Rotate to landscape
    tester.view.physicalSize = const Size(800, 400);
    await tester.pumpAndSettle();

    grid = tester.widget(find.byType(GridView));
    delegate = grid.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount;
    expect(delegate.crossAxisCount, 5);
  });

  testWidgets('Ranking screen ranks comics by views descending', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_buildTestApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Xếp Hạng'));
    await tester.pumpAndSettle();

    // Check top ranked item is Nguyên Tôn with 4.5M lượt đọc
    expect(find.text('Nguyên Tôn'), findsOneWidget);
    expect(find.textContaining('4.5M lượt đọc'), findsOneWidget);
  });

  testWidgets(
    'Explore screen displays Mới nhất, Đề cử, and Hoàn thành status',
    (WidgetTester tester) async {
      await tester.pumpWidget(_buildTestApp());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Khám Phá'));
      await tester.pumpAndSettle();

      // Verify sections
      expect(find.text('Mới nhất'), findsOneWidget);
      expect(find.text('Đề cử'), findsOneWidget);
      expect(find.text('Hoàn thành'), findsOneWidget);
      expect(find.text('Đọc'), findsOneWidget);
    },
  );

  testWidgets('Account tab opens Login and Register screens', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_buildTestApp());
    await tester.pumpAndSettle();

    // Chuyển sang tab Tài Khoản
    await tester.tap(find.text('Tài Khoản'));
    await tester.pumpAndSettle();

    expect(find.text('Khách'), findsOneWidget);
    expect(find.text('Đăng nhập / Đăng ký'), findsOneWidget);

    // Bấm Đăng nhập / Đăng ký
    await tester.tap(find.text('Đăng nhập / Đăng ký'));
    await tester.pumpAndSettle();

    // Xác nhận mở màn hình Đăng nhập
    expect(find.text('Đăng nhập'), findsWidgets);
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Mật khẩu'), findsOneWidget);
    expect(find.text('Đăng ký ngay'), findsOneWidget);

    // Chuyển sang màn hình Đăng ký
    await tester.tap(find.text('Đăng ký ngay'));
    await tester.pumpAndSettle();

    expect(find.text('Đăng ký tài khoản'), findsOneWidget);
    expect(find.text('Xác nhận mật khẩu'), findsOneWidget);
    expect(find.text('Đăng Ký Tài Khoản'), findsOneWidget);
  });

  testWidgets(
    'Account tab gear icon opens settings sheet with profile, password, and dark mode options',
    (WidgetTester tester) async {
      await tester.pumpWidget(_buildTestApp());
      await tester.pumpAndSettle();

      // Mở tab Tài Khoản
      await tester.tap(find.text('Tài Khoản'));
      await tester.pumpAndSettle();

      // Kiểm tra nút bánh răng (settings) trên AppBar
      final gearIcon = find.byIcon(Icons.settings_outlined);
      expect(gearIcon, findsOneWidget);

      // Bấm nút bánh răng
      await tester.tap(gearIcon);
      await tester.pumpAndSettle();

      // Kiểm tra hiện ra modal với 3 lựa chọn
      expect(find.text('Cài đặt & Tùy chọn'), findsOneWidget);
      expect(find.text('Chỉnh sửa hồ sơ'), findsOneWidget);
      expect(find.text('Đổi mật khẩu'), findsOneWidget);
      expect(find.text('Chế độ ban đêm (Dark Mode)'), findsOneWidget);

      // Bấm "Chỉnh sửa hồ sơ" khi chưa đăng nhập
      await tester.tap(find.text('Chỉnh sửa hồ sơ'));
      await tester.pumpAndSettle();

      // Kiểm tra SnackBar yêu cầu đăng nhập xuất hiện
      expect(find.text('Vui lòng đăng nhập để chỉnh sửa hồ sơ!'), findsOneWidget);
    },
  );
}
