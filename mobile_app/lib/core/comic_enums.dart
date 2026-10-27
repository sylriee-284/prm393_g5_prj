enum ComicGenre {
  tienHiep('Tiên hiệp'),
  huyenHuyen('Huyền huyễn'),
  ngonTinh('Ngôn tình'),
  trongSinh('Trọng sinh'),
  xuyenKhong('Xuyên không'),
  doThi('Đô thị'),
  khoaHuyen('Khoa huyễn'),
  vongDu('Võng du'),
  linhDi('Linh dị'),
  action('Hành động'),
  romance('Lãng mạn'),
  kyAo('Kỳ ảo');

  const ComicGenre(this.label);
  final String label;
}

enum ComicStatus {
  ongoing('Đang ra'),
  completed('Hoàn thành');

  const ComicStatus(this.label);
  final String label;
}

enum NotificationSetting {
  all('Tất cả chương mới'),
  favoriteOnly('Chỉ truyện yêu thích'),
  off('Tắt tất cả');

  const NotificationSetting(this.label);
  final String label;
}
