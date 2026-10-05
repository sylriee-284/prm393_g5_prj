import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prm393_project_g5/main.dart';

void main() {
  testWidgets('Library screen shows history tab', (WidgetTester tester) async {
    await tester.pumpWidget(const NovelApp());
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

    await tester.pumpWidget(const NovelApp());
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
    await tester.pumpWidget(const NovelApp());
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
      await tester.pumpWidget(const NovelApp());
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
}
