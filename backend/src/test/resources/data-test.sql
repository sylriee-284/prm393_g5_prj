INSERT INTO users (id, email, password, full_name, avatar_url, role, created_at, updated_at) VALUES
(1, 'user@novel.com', '$2a$10$fQlFBC00nqRLct7w8CE.KesghDDcmEPfRXOhuh6On2amdLfwzgTsm', 'Nguyễn Văn Đọc', 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=150&auto=format&fit=crop&q=80', 'ROLE_USER', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(2, 'admin@novel.com', '$2a$10$2K4vy6rgZvLuxZ9nheS4e.U/hVV/Ej/4tvhxYEWU7z8aGHl8bY3i6', 'Quản Trị Viên', 'https://images.unsplash.com/photo-1570295999919-56ceb5ecca61?w=150&auto=format&fit=crop&q=80', 'ROLE_ADMIN', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

INSERT INTO comics (id, title, author, description, cover_color, cover_label, cover_url, total_chapters, genre, views, status, rating) VALUES
('c0', 'Linh Sủng Của Ta Có Được Bảng Trò Chơi', 'Tiểu Hà Hướng Tây Lưu', 'Đại Tây Dương chỗ sâu...', 4279973469, 'LINH SỦNG', 'https://images.unsplash.com/photo-1518709268805-4e9042af9f23?w=500&auto=format&fit=crop&q=80', 680, 'Kỳ ảo', 1900000, 'ongoing', 5.0),
('c1', 'Tai Ách Phủ Xuống: Ta Là Toàn Cầu Duy Nhất Người Chơi', 'Ẩn danh', 'Khi tai ách giáng xuống thế giới...', 4281019179, 'TAI ÁCH', 'https://images.unsplash.com/photo-1578632767115-351597cf2477?w=500&auto=format&fit=crop&q=80', 267, 'Võng du', 520000, 'ongoing', 4.8),
('c2', 'Thanh Liên Chi Đỉnh', 'Mộng Nhập Thần Cơ', 'Con đường tu tiên khắc nghiệt...', 4282263331, 'THANH LIÊN', 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRU6v9fJCm0c7djEz5w7fEpcrrF9mw42d9MTPReOkkRuw&s=10', 4900, 'Tiên hiệp', 1250000, 'completed', 4.9);
