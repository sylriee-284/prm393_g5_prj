import '../core/comic_enums.dart';
import '../models/chapter.dart';
import '../models/comic.dart';

class ComicData {
  static const List<Comic> comics = [
    Comic(
      id: 'c0',
      title: 'Linh Sủng Của Ta Có Được Bảng Trò Chơi',
      author: 'Tiểu Hà Hướng Tây Lưu',
      description:
          'Đại Tây Dương chỗ sâu, du động thôn phệ vạn vật Hãn Hải Kinh Hoà...',
      coverColor: 0xFF1A365D,
      coverLabel: 'LINH SỦNG',
      coverUrl: 'https://images.unsplash.com/photo-1518709268805-4e9042af9f23?w=500&auto=format&fit=crop&q=80',
      totalChapters: 680,
      genre: ComicGenre.kyAo,
      views: 1900000,
      status: ComicStatus.ongoing,
      rating: 5.0,
    ),
    Comic(
      id: 'c2',
      title: 'Thanh Liên Chi Đỉnh',
      author: 'Mộng Nhập Thần Cơ',
      description: 'Con đường tu tiên khắc nghiệt dẫn tới đỉnh cao thanh liên.',
      coverColor: 0xFF3E2723,
      coverLabel: 'THANH LIÊN',
      coverUrl: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRU6v9fJCm0c7djEz5w7fEpcrrF9mw42d9MTPReOkkRuw&s=10',
      totalChapters: 4900,
      genre: ComicGenre.tienHiep,
      views: 1250000,
      status: ComicStatus.completed,
      rating: 4.9,
    ),
    Comic(
      id: 'c1',
      title: 'Tai Ách Phủ Xuống: Ta Là Toàn Cầu Duy Nhất Người Chơi',
      author: 'Ẩn danh',
      description: 'Khi tai ách giáng xuống thế giới, hắn là người chơi duy nhất nắm giữ hệ thống.',
      coverColor: 0xFF2B2B2B,
      coverLabel: 'TAI ÁCH',
      coverUrl: 'https://images.unsplash.com/photo-1578632767115-351597cf2477?w=500&auto=format&fit=crop&q=80',
      totalChapters: 267,
      genre: ComicGenre.vongDu,
      views: 520000,
      status: ComicStatus.ongoing,
      rating: 4.8,
    ),
    Comic(
      id: 'c8',
      title:
          'Mọi Người Đều Là Lãnh Chúa, Bằng Cái Gì Ngươi Có Ức Cái Thiên Phú',
      author: 'Đông Hải',
      description: 'Toàn dân xuyên không làm lãnh chúa vạn giới tranh phong.',
      coverColor: 0xFFB71C1C,
      coverLabel: 'LÃNH CHÚA',
      coverUrl: 'https://images.unsplash.com/photo-1534447677768-be436bb09401?w=500&auto=format&fit=crop&q=80',
      totalChapters: 850,
      genre: ComicGenre.huyenHuyen,
      views: 2800000,
      status: ComicStatus.ongoing,
      rating: 4.9,
    ),
    Comic(
      id: 'c9',
      title: 'Dòng Tu Tiên, Một Năm Rút Ra Một Dòng',
      author: 'Bạch Vân',
      description:
          'Mỗi năm thức tỉnh một dòng thuộc tính tu tiên nghịch thiên.',
      coverColor: 0xFF263238,
      coverLabel: 'TU TIÊN',
      coverUrl: 'https://images.unsplash.com/photo-1509198397868-475647b2a1e5?w=500&auto=format&fit=crop&q=80',
      totalChapters: 540,
      genre: ComicGenre.tienHiep,
      views: 1500000,
      status: ComicStatus.ongoing,
      rating: 4.8,
    ),
    Comic(
      id: 'c10',
      title: 'Kiếm Chúc Đại Hoang',
      author: 'Cửu Kiếm',
      description: 'Nhất kiếm định càn khôn, dẹp yên đại hoang.',
      coverColor: 0xFF0D47A1,
      coverLabel: 'KIẾM CHÚC',
      coverUrl: 'https://images.unsplash.com/photo-1514533450685-4493e01d1fdc?w=500&auto=format&fit=crop&q=80',
      totalChapters: 420,
      genre: ComicGenre.tienHiep,
      views: 950000,
      status: ComicStatus.ongoing,
      rating: 4.7,
    ),
    Comic(
      id: 'c3',
      title: 'Đại Quản Gia Là Ma Hoàng',
      author: 'Dạ Vũ',
      description:
          'Ma hoàng tái sinh thành đại quản gia của một gia tộc suy tàn.',
      coverColor: 0xFF4A148C,
      coverLabel: 'MA HOÀNG',
      coverUrl: 'https://dai-quan-gia-la-ma-hoang.com/wp-content/uploads/2026/06/dai-quan-gia-1.jpg',
      totalChapters: 1312,
      genre: ComicGenre.huyenHuyen,
      views: 3400000,
      status: ComicStatus.ongoing,
      rating: 4.9,
    ),
    Comic(
      id: 'c4',
      title: 'Trạch Thiên Ký',
      author: 'Thần Đông',
      description: 'Thiếu niên trạch thiên, nghịch mệnh đổi vận.',
      coverColor: 0xFF1A237E,
      coverLabel: 'TRẠCH THIÊN',
      coverUrl: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSS0nHGN75rz4KirWfaB28JdOkKGyKQCAhnNPu5Py70xA&s=10',
      totalChapters: 1193,
      genre: ComicGenre.xuyenKhong,
      views: 890000,
      status: ComicStatus.completed,
      rating: 4.7,
    ),
    Comic(
      id: 'c5',
      title: 'Vĩnh Hằng Thánh Vương',
      author: 'Thần Tọa',
      description: 'Từ phàm nhân bước tới ngôi vị thánh vương vĩnh hằng.',
      coverColor: 0xFF01579B,
      coverLabel: 'THÁNH VƯƠNG',
      coverUrl: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQw_XE4QQl_GhC8b_zH5jx9KunGiharrEpKyxETnkRv0Q&s=10',
      totalChapters: 3379,
      genre: ComicGenre.trongSinh,
      views: 2100000,
      status: ComicStatus.completed,
      rating: 4.8,
    ),
    Comic(
      id: 'c6',
      title: 'Nguyên Tôn',
      author: 'Thiên Tằm Thổ Đậu',
      description: 'Chu Nguyên bước lên con đường nguyên tôn, báo thù rửa hận.',
      coverColor: 0xFF212121,
      coverLabel: 'NGUYÊN TÔN',
      coverUrl: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRBoDyBy8AhTGPNn3GcJnh73oO2Qk8iJ4fLasPv9vzx5Q&s=10',
      totalChapters: 1504,
      genre: ComicGenre.action,
      views: 4500000,
      status: ComicStatus.ongoing,
      rating: 5.0,
    ),
    Comic(
      id: 'c7',
      title: 'Ngự Thú Gia Tộc: Ta Có Một Bản Vạn',
      author: 'Ngự Thú Sư',
      description:
          'Với bản vạn năng, hắn dẫn dắt ngự thú gia tộc vươn tới đỉnh cao.',
      coverColor: 0xFF004D40,
      coverLabel: 'NGỰ THÚ',
      coverUrl: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQ-mKsgsjkan4hnKCfM9wjiphcZyJUVRDcjb-4e_8iSgg&s=10',
      totalChapters: 860,
      genre: ComicGenre.khoaHuyen,
      views: 310000,
      status: ComicStatus.ongoing,
      rating: 4.6,
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
