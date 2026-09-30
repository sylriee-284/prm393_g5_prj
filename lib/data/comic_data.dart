import '../models/chapter.dart';
import '../models/comic.dart';

class ComicData {
  static const List<Comic> comics = [
    Comic(
      id: 'c1',
      title: 'Tai Ách Phủ Xuống: Ta Là Toàn Cầu Duy Nhất Người Chơi',
      author: 'Ẩn danh',
      description:
          'Khi tai ách giáng xuống thế giới, hắn là người chơi duy nhất nắm giữ hệ thống.',
      coverColor: 0xFF2B2B2B,
      coverLabel: 'TAI ÁCH',
      totalChapters: 267,
      genre: 'Huyền huyễn',
    ),
    Comic(
      id: 'c2',
      title: 'Thanh Liên Chi Đỉnh',
      author: 'Mộng Nhập Thần Cơ',
      description: 'Con đường tu tiên khắc nghiệt dẫn tới đỉnh cao thanh liên.',
      coverColor: 0xFF3E2723,
      coverLabel: 'THANH LIÊN',
      totalChapters: 4900,
    ),
    Comic(
      id: 'c3',
      title: 'Đại Quản Gia Là Ma Hoàng',
      author: 'Dạ Vũ',
      description: 'Ma hoàng tái sinh thành đại quản gia của một gia tộc suy tàn.',
      coverColor: 0xFF4A148C,
      coverLabel: 'MA HOÀNG',
      totalChapters: 1312,
      genre: 'Huyền huyễn',
    ),
    Comic(
      id: 'c4',
      title: 'Trạch Thiên Ký',
      author: 'Thần Đông',
      description: 'Thiếu niên trạch thiên, nghịch mệnh đổi vận.',
      coverColor: 0xFF1A237E,
      coverLabel: 'TRẠCH THIÊN',
      totalChapters: 1193,
    ),
    Comic(
      id: 'c5',
      title: 'Vĩnh Hằng Thánh Vương',
      author: 'Thần Tọa',
      description: 'Từ phàm nhân bước tới ngôi vị thánh vương vĩnh hằng.',
      coverColor: 0xFF01579B,
      coverLabel: 'THÁNH VƯƠNG',
      totalChapters: 3379,
    ),
    Comic(
      id: 'c6',
      title: 'Nguyên Tôn',
      author: 'Thiên Tằm Thổ Đậu',
      description: 'Chu Nguyên bước lên con đường nguyên tôn, báo thù rửa hận.',
      coverColor: 0xFF212121,
      coverLabel: 'NGUYÊN TÔN',
      totalChapters: 1504,
    ),
    Comic(
      id: 'c7',
      title: 'Ngự Thú Gia Tộc: Ta Có Một Bản Vạn',
      author: 'Ngự Thú Sư',
      description: 'Với bản vạn năng, hắn dẫn dắt ngự thú gia tộc vươn tới đỉnh cao.',
      coverColor: 0xFF004D40,
      coverLabel: 'NGỰ THÚ',
      totalChapters: 860,
      genre: 'Ngự thú',
    ),
  ];

  static List<Chapter> chaptersOf(Comic comic) {
    return List.generate(comic.totalChapters.clamp(1, 40), (index) {
      final number = index + 1;
      return Chapter(
        id: '${comic.id}_ch_$number',
        comicId: comic.id,
        number: number,
        title: 'Chương $number',
        content:
            '${comic.title}\n\nChương $number\n\n'
            'Nội dung chương được tải từ dữ liệu mẫu. '
            'Nhân vật chính tiếp tục hành trình, đối mặt thử thách mới '
            'và từng bước mạnh lên.\n\n'
            'Bạn có thể vuốt hoặc dùng nút để chuyển chương tiếp theo.',
      );
    });
  }
}
