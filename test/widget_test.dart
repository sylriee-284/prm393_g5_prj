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
}
