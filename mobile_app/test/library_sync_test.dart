import 'package:flutter_test/flutter_test.dart';
import 'package:prm393_project_g5/core/comic_enums.dart';
import 'package:prm393_project_g5/models/comic.dart';
import 'package:prm393_project_g5/providers/library_provider.dart';
import 'package:prm393_project_g5/repositories/comic_repository.dart';
import 'package:prm393_project_g5/services/database_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final db = DatabaseService.instance;
    await db.clearLocalHistory();
    await db.clearLocalBookmarks();
    await db.clearAccountHistory();
    await db.clearAccountBookmarks();
  });

  test('DatabaseService isolates Local Store and Account Store', () async {
    final db = DatabaseService.instance;

    // 1. Thêm truyện vào Local Store (khi người dùng dùng ở chế độ thiết bị)
    await db.saveLocalHistory(comicId: 'c_local', currentChapter: 10);
    await db.addLocalBookmark('c_local');

    // 2. Thêm truyện vào Account Store (khi người dùng đăng nhập tài khoản)
    await db.saveAccountHistory(comicId: 'c_account', currentChapter: 25);
    await db.addAccountBookmark('c_account');

    // Kiểm tra Local Store chỉ có truyện c_local
    final localH = await db.getLocalHistory();
    final localB = await db.getLocalBookmarks();
    expect(localH.any((r) => r['comic_id'] == 'c_local'), isTrue);
    expect(localH.any((r) => r['comic_id'] == 'c_account'), isFalse);
    expect(localB.contains('c_local'), isTrue);
    expect(localB.contains('c_account'), isFalse);

    // Kiểm tra Account Store chỉ có truyện c_account
    final accountH = await db.getAccountHistory();
    final accountB = await db.getAccountBookmarks();
    expect(accountH.any((r) => r['comic_id'] == 'c_account'), isTrue);
    expect(accountH.any((r) => r['comic_id'] == 'c_local'), isFalse);
    expect(accountB.contains('c_account'), isTrue);
    expect(accountB.contains('c_local'), isFalse);

    // 3. Xóa Account Store (như khi loadAccountLibrary dọn cache tài khoản)
    await db.clearAccountHistory();
    await db.clearAccountBookmarks();

    // Local Store vẫn nguyên vẹn 100%!
    final localHAfter = await db.getLocalHistory();
    final localBAfter = await db.getLocalBookmarks();
    expect(localHAfter.any((r) => r['comic_id'] == 'c_local'), isTrue);
    expect(localBAfter.contains('c_local'), isTrue);
  });

  test('LibraryProvider starts in Local Store mode and switches cleanly', () async {
    final repo = ComicRepository(initialComics: [
      const Comic(
        id: 'c2',
        title: 'Thanh Liên Chi Đỉnh',
        author: 'Mộng Nhập Thần Cơ',
        description: 'Desc',
        coverColor: 0,
        coverLabel: 'TL',
        coverUrl: '',
        totalChapters: 100,
        genre: ComicGenre.tienHiep,
        views: 100,
        status: ComicStatus.ongoing,
        rating: 5.0,
      ),
      const Comic(
        id: 'c8',
        title: 'Lãnh Chúa',
        author: 'Đông Hải',
        description: 'Desc',
        coverColor: 0,
        coverLabel: 'LC',
        coverUrl: '',
        totalChapters: 200,
        genre: ComicGenre.huyenHuyen,
        views: 200,
        status: ComicStatus.ongoing,
        rating: 4.8,
      ),
    ]);

    final provider = LibraryProvider(repo);
    expect(provider.isAccountScope, isFalse);

    // Đánh dấu truyện ở local
    await provider.toggleBookmark('c8');
    expect(provider.isBookmarked('c8'), isTrue);
    expect(provider.bookmarks.any((e) => e.comicId == 'c8'), isTrue);

    // Kiểm tra đã lưu vào Local Store trong SQLite
    final localB = await DatabaseService.instance.getLocalBookmarks();
    expect(localB.contains('c8'), isTrue);

    // Giả lập khi người dùng đăng xuất: gọi switchToLocal()
    await provider.switchToLocal();
    expect(provider.isAccountScope, isFalse);
    expect(provider.isBookmarked('c8'), isTrue);
    expect(provider.bookmarks.any((e) => e.comicId == 'c8'), isTrue);
  });

  test('removeFromHistory removes comic from both stores and does not reappear on logout/login', () async {
    final repo = ComicRepository(initialComics: [
      const Comic(
        id: 'c2',
        title: 'Thanh Liên Chi Đỉnh',
        author: 'Mộng Nhập Thần Cơ',
        description: 'Desc',
        coverColor: 0,
        coverLabel: 'TL',
        coverUrl: '',
        totalChapters: 100,
        genre: ComicGenre.tienHiep,
        views: 100,
        status: ComicStatus.ongoing,
        rating: 5.0,
      ),
    ]);

    final provider = LibraryProvider(repo);
    await provider.initFuture;

    // Đọc chương 5 của truyện c2
    await provider.updateProgress('c2', 5);
    expect(provider.history.any((e) => e.comicId == 'c2'), isTrue);

    // Xóa truyện c2 khỏi lịch sử
    await provider.removeFromHistory('c2');
    expect(provider.history.any((e) => e.comicId == 'c2'), isFalse);

    // Kiểm tra trong SQLite cả Local Store và Account Store đều không còn c2
    final localH = await DatabaseService.instance.getLocalHistory();
    final accountH = await DatabaseService.instance.getAccountHistory();
    expect(localH.any((r) => r['comic_id'] == 'c2'), isFalse);
    expect(accountH.any((r) => r['comic_id'] == 'c2'), isFalse);

    // Sau khi logout (chuyển về switchToLocal), c2 không bao giờ xuất hiện lại trong lịch sử!
    await provider.switchToLocal();
    expect(provider.history.any((e) => e.comicId == 'c2'), isFalse);
  });
}
