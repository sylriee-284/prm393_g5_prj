-- ====================================================================
-- SCRIPT KHỞI TẠO CƠ SỞ DỮ LIỆU MYSQL - DỰ ÁN ỨNG DỤNG ĐỌC TRUYỆN (PRM393 G5)
-- Database: novel_db
-- Encoding: utf8mb4 (Hỗ trợ tiếng Việt đầy đủ và emoji)
-- ====================================================================

SET NAMES utf8mb4;
SET CHARACTER SET utf8mb4;

-- 1. Tạo database nếu chưa tồn tại
CREATE DATABASE IF NOT EXISTS `novel_db` 
    DEFAULT CHARACTER SET utf8mb4 
    DEFAULT COLLATE utf8mb4_unicode_ci;

USE `novel_db`;

SET NAMES utf8mb4;
SET CHARACTER SET utf8mb4;

-- Tạm tắt ràng buộc khóa ngoại để drop/create bảng sạch sẽ
SET FOREIGN_KEY_CHECKS = 0;

DROP TABLE IF EXISTS `bookmarks`;
DROP TABLE IF EXISTS `reading_history`;
DROP TABLE IF EXISTS `chapters`;
DROP TABLE IF EXISTS `comics`;
DROP TABLE IF EXISTS `refresh_tokens`;
DROP TABLE IF EXISTS `users`;

SET FOREIGN_KEY_CHECKS = 1;

-- ====================================================================
-- 2. CẤU TRÚC CÁC BẢNG (DDL)
-- ====================================================================

-- Bảng người dùng (users)
CREATE TABLE `users` (
    `id` BIGINT AUTO_INCREMENT PRIMARY KEY,
    `email` VARCHAR(255) NOT NULL UNIQUE,
    `password` VARCHAR(255) NOT NULL,
    `full_name` VARCHAR(255) NOT NULL,
    `avatar_url` VARCHAR(1000) NULL,
    `role` VARCHAR(50) NOT NULL DEFAULT 'ROLE_USER',
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX `idx_users_email` (`email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Bảng refresh tokens cho xác thực JWT (refresh_tokens)
CREATE TABLE `refresh_tokens` (
    `id` BIGINT AUTO_INCREMENT PRIMARY KEY,
    `user_id` BIGINT NOT NULL,
    `token` VARCHAR(255) NOT NULL UNIQUE,
    `expiry_date` DATETIME NOT NULL,
    `revoked` BOOLEAN NOT NULL DEFAULT FALSE,
    FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE CASCADE,
    INDEX `idx_rf_token` (`token`),
    INDEX `idx_rf_user` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Bảng thông tin truyện (comics)
CREATE TABLE `comics` (
    `id` VARCHAR(50) PRIMARY KEY,
    `title` VARCHAR(255) NOT NULL,
    `author` VARCHAR(255) NOT NULL,
    `description` TEXT NULL,
    `cover_color` BIGINT NULL DEFAULT 4280424541,
    `cover_label` VARCHAR(100) NULL,
    `cover_url` VARCHAR(1000) NULL,
    `total_chapters` INT NOT NULL DEFAULT 0,
    `genre` VARCHAR(100) NOT NULL DEFAULT 'Tiên hiệp',
    `views` INT NOT NULL DEFAULT 0,
    `status` VARCHAR(50) NOT NULL DEFAULT 'ongoing',
    `rating` DOUBLE NOT NULL DEFAULT 5.0,
    INDEX `idx_comics_views` (`views` DESC),
    INDEX `idx_comics_genre` (`genre`),
    INDEX `idx_comics_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Bảng các chương của truyện (chapters)
CREATE TABLE `chapters` (
    `id` VARCHAR(100) PRIMARY KEY,
    `comic_id` VARCHAR(50) NOT NULL,
    `number` INT NOT NULL,
    `title` VARCHAR(255) NOT NULL,
    `content` LONGTEXT NULL,
    FOREIGN KEY (`comic_id`) REFERENCES `comics`(`id`) ON DELETE CASCADE,
    UNIQUE KEY `uk_comic_number` (`comic_id`, `number`),
    INDEX `idx_chapters_comic` (`comic_id`, `number` ASC)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Bảng lịch sử đọc truyện của người dùng (reading_history)
CREATE TABLE `reading_history` (
    `id` BIGINT AUTO_INCREMENT PRIMARY KEY,
    `user_id` BIGINT NOT NULL,
    `comic_id` VARCHAR(50) NOT NULL,
    `current_chapter` INT NOT NULL DEFAULT 1,
    `notify_enabled` BOOLEAN NOT NULL DEFAULT TRUE,
    `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE CASCADE,
    FOREIGN KEY (`comic_id`) REFERENCES `comics`(`id`) ON DELETE CASCADE,
    UNIQUE KEY `uk_user_comic_history` (`user_id`, `comic_id`),
    INDEX `idx_history_user` (`user_id`, `updated_at` DESC)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Bảng đánh dấu/lưu truyện của người dùng (bookmarks)
CREATE TABLE `bookmarks` (
    `id` BIGINT AUTO_INCREMENT PRIMARY KEY,
    `user_id` BIGINT NOT NULL,
    `comic_id` VARCHAR(50) NOT NULL,
    `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE CASCADE,
    FOREIGN KEY (`comic_id`) REFERENCES `comics`(`id`) ON DELETE CASCADE,
    UNIQUE KEY `uk_user_comic_bookmark` (`user_id`, `comic_id`),
    INDEX `idx_bookmark_user` (`user_id`, `created_at` DESC)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ====================================================================
-- 3. DỮ LIỆU MẪU BAN ĐẦU (SEED DATA)
-- ====================================================================

-- 3.1. Tài khoản người dùng mẫu
-- Mật khẩu đã được mã hóa BCrypt (cost=10):
-- user@novel.com  / User@123  -> $2a$10$fQlFBC00nqRLct7w8CE.KesghDDcmEPfRXOhuh6On2amdLfwzgTsm
-- admin@novel.com / Admin@123 -> $2a$10$2K4vy6rgZvLuxZ9nheS4e.U/hVV/Ej/4tvhxYEWU7z8aGHl8bY3i6
INSERT INTO `users` (`id`, `email`, `password`, `full_name`, `avatar_url`, `role`, `created_at`, `updated_at`) VALUES
(1, 'user@novel.com', '$2a$10$fQlFBC00nqRLct7w8CE.KesghDDcmEPfRXOhuh6On2amdLfwzgTsm', 'Nguyễn Văn Đọc', 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=150&auto=format&fit=crop&q=80', 'ROLE_USER', NOW(), NOW()),
(2, 'admin@novel.com', '$2a$10$2K4vy6rgZvLuxZ9nheS4e.U/hVV/Ej/4tvhxYEWU7z8aGHl8bY3i6', 'Quản Trị Viên', 'https://images.unsplash.com/photo-1570295999919-56ceb5ecca61?w=150&auto=format&fit=crop&q=80', 'ROLE_ADMIN', NOW(), NOW());

-- 3.2. Danh sách 11 bộ truyện mẫu
INSERT INTO `comics` (`id`, `title`, `author`, `description`, `cover_color`, `cover_label`, `cover_url`, `total_chapters`, `genre`, `views`, `status`, `rating`) VALUES
('c0', 'Linh Sủng Của Ta Có Được Bảng Trò Chơi', 'Tiểu Hà Hướng Tây Lưu', 'Đại Tây Dương chỗ sâu, du động thôn phệ vạn vật Hãn Hải Kinh Hoà... Nhân vật chính thức tỉnh bảng điều khiển trò chơi thần bí, thu phục và tiến hóa dị thú đỉnh cấp thế giới.', 4279973469, 'LINH SỦNG', 'https://images.unsplash.com/photo-1518709268805-4e9042af9f23?w=500&auto=format&fit=crop&q=80', 680, 'Kỳ ảo', 1900000, 'ongoing', 5.0),
('c2', 'Thanh Liên Chi Đỉnh', 'Mộng Nhập Thần Cơ', 'Con đường tu tiên khắc nghiệt dẫn tới đỉnh cao thanh liên. Thiếu niên bình phàm bước vào giới tu chân muôn màu muôn vẻ, từng bước chứng đạo trường sinh.', 4282263331, 'THANH LIÊN', 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRU6v9fJCm0c7djEz5w7fEpcrrF9mw42d9MTPReOkkRuw&s=10', 4900, 'Tiên hiệp', 1250000, 'completed', 4.9),
('c1', 'Tai Ách Phủ Xuống: Ta Là Toàn Cầu Duy Nhất Người Chơi', 'Ẩn danh', 'Khi tai ách giáng xuống toàn cầu, toàn bộ nhân loại hoảng loạn chạy trốn. Duy chỉ có hắn nhìn thấy bảng trạng thái người chơi, biến tai họa thành chuỗi phó bản thăng cấp.', 4281019179, 'TAI ÁCH', 'https://images.unsplash.com/photo-1578632767115-351597cf2477?w=500&auto=format&fit=crop&q=80', 267, 'Võng du', 520000, 'ongoing', 4.8),
('c8', 'Mọi Người Đều Là Lãnh Chúa, Bằng Cái Gì Ngươi Có Ức Cái Thiên Phú', 'Đông Hải', 'Toàn dân xuyên không vào chiến trường vạn tộc, mỗi người làm lãnh chúa xây dựng đế quốc. Hắn thức tỉnh vô tận thiên phú, quét ngang vạn giới.', 4290190364, 'LÃNH CHÚA', 'https://images.unsplash.com/photo-1534447677768-be436bb09401?w=500&auto=format&fit=crop&q=80', 850, 'Huyền huyễn', 2800000, 'ongoing', 4.9),
('c9', 'Dòng Tu Tiên, Một Năm Rút Ra Một Dòng', 'Bạch Vân', 'Mỗi năm trôi qua, thiên địa tặng cho hắn một dòng thuộc tính thần cấp. Bất tri bất giác, hắn đã gom đủ vô số từ điều vô địch.', 4280693304, 'TU TIÊN', 'https://images.unsplash.com/photo-1509198397868-475647b2a1e5?w=500&auto=format&fit=crop&q=80', 540, 'Tiên hiệp', 1500000, 'ongoing', 4.8),
('c10', 'Kiếm Chúc Đại Hoang', 'Cửu Kiếm', 'Nhất kiếm định càn khôn, dẹp yên muôn dặm đại hoang. Một thanh kiếm rỉ sét, mở ra truyền kỳ kiếm đạo bất hủ.', 4279093153, 'KIẾM CHÚC', 'https://images.unsplash.com/photo-1514533450685-4493e01d1fdc?w=500&auto=format&fit=crop&q=80', 420, 'Tiên hiệp', 950000, 'ongoing', 4.7),
('c3', 'Đại Quản Gia Là Ma Hoàng', 'Dạ Vũ', 'Ma hoàng Trác Nhất Phàm vì nắm giữ bí kíp thượng cổ bị đồ đệ phản bội, trùng sinh thành một đại quản gia của gia tộc Lạc gia đang lụn bại.', 4283045004, 'MA HOÀNG', 'https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?w=500&auto=format&fit=crop&q=80', 1200, 'Huyền huyễn', 3100000, 'ongoing', 4.9),
('c4', 'Toàn Chức Pháp Sư', 'Loạn', 'Tỉnh lại sau một giấc mộng dài, thế giới quen thuộc đã biến thành thế giới ma pháp. Học viện ma thuật, ma thú hoành hành, hắn lại thức tỉnh song hệ toàn năng.', 4280016416, 'PHÁP SƯ', 'https://images.unsplash.com/photo-1518709268805-4e9042af9f23?w=500&auto=format&fit=crop&q=80', 3200, 'Kỳ ảo', 2400000, 'completed', 4.7),
('c5', 'Đấu Phá Thương Khung', 'Thiên Tằm Thổ Đậu', 'Đây là thế giới của đấu khí, không có hoa tiếu ma pháp, chỉ có đấu khí phồn thịnh đến đỉnh phong! Ba mươi năm Hà Đông, ba mươi năm Hà Tây, đừng khinh thiếu niên nghèo!', 4293284096, 'ĐẤU PHÁ', 'https://images.unsplash.com/photo-1534447677768-be436bb09401?w=500&auto=format&fit=crop&q=80', 1648, 'Huyền huyễn', 4200000, 'completed', 4.9),
('c6', 'Vũ Động Càn Khôn', 'Thiên Tằm Thổ Đậu', 'Thiếu niên Lâm Động ngẫu nhiên nhặt được thần bí Thạch Phù, từng bước bước ra khỏi một tiểu trấn hẻo lánh, khuấy đảo phong vân toàn bộ đại lục.', 4281408402, 'VŨ ĐỘNG', 'https://images.unsplash.com/photo-1578632767115-351597cf2477?w=500&auto=format&fit=crop&q=80', 1308, 'Huyền huyễn', 3800000, 'completed', 4.8),
('c7', 'Nguyên Tôn', 'Thiên Tằm Thổ Đậu', 'Thiên địa vi lô, vạn vật vi đồng, âm dương vi thán, càn khôn vi sủng. Thiếu niên Chu Nguyên mang Thánh Long khí vận, nghịch thiên cải mệnh, ngạo thị quần hùng.', 4287106639, 'NGUYÊN TÔN', 'https://images.unsplash.com/photo-1509198397868-475647b2a1e5?w=500&auto=format&fit=crop&q=80', 1497, 'Huyền huyễn', 4500000, 'ongoing', 4.9);

-- 3.3. Chương mẫu (3 chương cho mỗi bộ truyện)
INSERT INTO `chapters` (`id`, `comic_id`, `number`, `title`, `content`) VALUES
-- c0: Linh Sủng
('c0_ch1', 'c0', 1, 'Chương 1: Bảng trò chơi thức tỉnh', 'Gió lạnh biển sâu thổi qua cảng khẩu, mang theo vị tanh nồng của sóng biển bọt trắng.\n\nLâm Phong mở mắt, trước mắt hắn bất ngờ hiện lên một giao diện màu lam nhạt phát sáng huyền ảo:\n[Chào mừng người chơi số 001 gia nhập Hãn Hải Vực].\n\n"Đây là... bảng điều khiển trò chơi?" - Hắn nắm chặt nắm tay, trái tim đập thình thịch.'),
('c0_ch2', 'c0', 2, 'Chương 2: Khế ước linh sủng đầu tiên', 'Trước mặt Lâm Phong là một quả trứng lân tinh màu lam thẫm đang phát ra từng nhịp đập khe khẽ.\n\nHắn đưa tay chạm nhẹ vào bề mặt trứng, linh lực từ lòng bàn tay tràn vào. Từng vết nứt nhanh chóng lan rộng, một chú tiểu kình ngư toàn thân phát sáng xuất hiện, cọ cọ vào lòng bàn tay hắn.'),
('c0_ch3', 'c0', 3, 'Chương 3: Chiến tích đầu tiên', 'Vùng biển nông gợn sóng dữ dội, một con Thiết Giáp Giải khổng lồ vung hai chiếc càng sắt bén ngót lao tới.\n\n"Tiểu Kình, dùng Ba Động Quyền!"\n\nMột cột sóng dâng trào đánh bay Thiết Giáp Giải. Âm thanh hệ thống vang lên:\n[Hạ gục thành công Thiết Giáp Giải cấp 3. Nhận được 120 điểm kinh nghiệm].'),

-- c2: Thanh Liên Chi Đỉnh
('c2_ch1', 'c2', 1, 'Chương 1: Thiếu niên Thanh Liên đảo', 'Thanh Liên đảo bốn mùa mây khói lượn quanh, linh khí mỏng manh nhưng yên bình.\n\nVương Trường Sinh ngồi xếp bằng trên vách đá ngắm nhìn mặt trời mọc, thở ra một làn bạch khí mờ ảo. Mười năm khổ tu, hôm nay rốt cuộc hắn cũng chạm tới ngưỡng cửa Luyện Khí tầng ba.'),
('c2_ch2', 'c2', 2, 'Chương 2: Linh dược trên vách núi', 'Theo lời dặn của tộc trưởng, Trường Sinh lặn lội đến vách đá Hắc Vụ Phong tìm kiếm một cây Xích Huyết Thảo trăm năm.\n\nGiữa làn sương độc, một đốm sáng đỏ rực lập lòe như ngọn lửa. Nhưng ngay cạnh đó, một con Độc Lân Hạt đang rình rập.'),
('c2_ch3', 'c2', 3, 'Chương 3: Đột phá Luyện Khí tầng 4', 'Dùng Xích Huyết Thảo luyện thành đan dược, dược lực cuồn cuộn như dòng nham thạch chảy khắp kinh mạch.\n\n"Rắc!" - Một tiếng động giòn tan vang lên trong đan điền, bình cảnh bị phá vỡ. Vương Trường Sinh chính thức bước vào Luyện Khí trung kỳ.'),

-- c1: Tai Ách Phủ Xuống
('c1_ch1', 'c1', 1, 'Chương 1: Bầu trời nhuộm đỏ', '12 giờ trưa, bầu trời trên toàn thế giới bỗng nhiên chuyển sang màu đỏ như máu.\n\nCòi báo động rền vang khắp thành phố, xe cộ va chạm hỗn loạn. Nhưng trong mắt Trần Viễn, chỉ có dòng chữ đếm ngược màu vàng kim:\n[Tai Ách phó bản số 1 chuẩn bị mở sau 60 giây].'),
('c1_ch2', 'c1', 2, 'Chương 2: Lựa chọn nghề nghiệp', 'Các khối sương mù đen đặc ngưng tụ thành những cánh cổng không gian dị giới.\n\n[Mời người chơi chọn chức nghiệp khởi đầu:\n1. Chiến sĩ dũng cảm\n2. Pháp sư nguyên tố\n3. Thợ săn bóng đêm (Ẩn - Tỷ lệ 0.001%)]\n\nTrần Viễn mỉm cười dứt khoát ấn chọn chức nghiệp thứ ba.'),
('c1_ch3', 'c1', 3, 'Chương 3: Lưỡi dao bóng tối', 'Bước vào trung tâm thương mại bỏ hoang, bầy Huyết Lang rít lên lao tới.\n\nThân hình Trần Viễn hóa thành tàn ảnh, lưỡi dao đen nhánh lướt qua cổ họng đầu lĩnh bầy sói trong chớp mắt. Máu tươi bắn tung tóe, đầu sói rơi xuống đất.'),

-- c8: Lãnh Chúa
('c8_ch1', 'c8', 1, 'Chương 1: Triệu hoán lãnh địa', 'Mỗi người được phân phối một lãnh địa ban đầu rộng 100 mét vuông cùng 3 nông dân nghèo nàn.\n\nGiữa tiếng khóc than của hàng tỷ người, Lục Thần bình tĩnh nhìn vào bảng thuộc tính lãnh chúa của mình:\n[Kích hoạt thiên phú vĩnh cửu: Bách Bội Bạo Suất].'),
('c8_ch2', 'c8', 2, 'Chương 2: Nâng cấp thành trì', 'Chỉ sau 2 tiếng thu hoạch gỗ và đá, lãnh địa của Lục Thần đã từ một lều cỏ rách nát biến thành một pháo đài bằng đá kiên cố.\n\nNông dân được trang bị giáp thép sáng loáng, sẵn sàng phòng ngự đợt tấn công quái thú đêm đầu tiên.'),
('c8_ch3', 'c8', 3, 'Chương 3: Binh chủng thần cấp', 'Từ tế đàn triệu hoán, một tia lôi điện giáng xuống.\n\nMột nữ thiên sứ sáu cánh cầm thánh kiếm quỳ gối trước mặt Lục Thần:\n"Chúa tể tôn kính, Lôi Đình Thiên Sứ nguyện vì người dẹp yên vạn tộc!"'),

-- c9: Dòng Tu Tiên
('c9_ch1', 'c9', 1, 'Chương 1: Một năm một từ điều', 'Bạch Thần sinh ra trong một thôn làng thợ rèn hẻo lánh.\n\nTròn mười tám tuổi, đồng hồ sinh mệnh vang lên một tiếng "Đinh!".\n[Đã qua một năm sinh tồn. Bắt đầu rút ra từ điều năm thứ nhất:\nNhận được từ điều cấp Kim: "Thiên Đạo Thù Cần" - Mọi hành động luyện tập đều tăng 1000% hiệu suất].'),
('c9_ch2', 'c9', 2, 'Chương 2: Vung kiếm vạn lần', 'Nhờ từ điều Thiên Đạo Thù Cần, chỉ sau một buổi sáng vung thanh kiếm gỗ, kiếm ý của Bạch Thần đã đạt đến cảnh giới Hóa Cảnh, chém đứt thác nước thượng nguồn.'),
('c9_ch3', 'c9', 3, 'Chương 3: Năm thứ hai, từ điều mới', 'Ngày tròn 19 tuổi, luồng sáng tím lại lóe lên:\n[Nhận được từ điều cấp Thần: "Bất Diệt Chân Thân" - Miễn nhiễm toàn bộ sát thương chí mạng dưới Thiên Tiên].'),

-- c10: Kiếm Chúc Đại Hoang
('c10_ch1', 'c10', 1, 'Chương 1: Rút kiếm trong bão cát', 'Đại hoang vô tận, gió cát mịt mù chôn vùi biết bao cổ thành di tích.\n\nThiếu niên áo rách dắt theo một con lừa gầy, sau lưng cõng một thanh kiếm nặng ngàn cân không có vỏ bọc.'),
('c10_ch2', 'c10', 2, 'Chương 2: Kiếm khí tung hoành', 'Một đàn Hoang Thú Cự Tích chặn đường, lớp vảy dày của chúng đao thương bất nhập.\n\nThiếu niên khẽ búng tay lên thân kiếm rỉ sét, một tiếng kiếm minh trong trẻo vang vọng xé toạc tầng mây, chém đứt đôi đàn thú dữ.'),
('c10_ch3', 'c10', 3, 'Chương 3: Khách điếm biên giới', 'Bước vào Long Môn khách điếm, các thế lực giang hồ và tu sĩ các tông môn đều đưa mắt cảnh giác nhìn vào thanh cự kiếm sau lưng hắn.'),

-- c3: Đại Quản Gia Là Ma Hoàng
('c3_ch1', 'c3', 1, 'Chương 1: Ma Hoàng trùng sinh', 'Trác Nhất Phàm mở mắt ra, phát hiện linh hồn Ma Hoàng của mình lại nhập vào thể xác của một tên gia đinh yếu ớt họ Trác trong Lạc gia.\n\n"Thế gian này, kẻ nào dám ức hiếp người của Trác Nhất Phàm ta?"'),
('c3_ch2', 'c3', 2, 'Chương 2: Thiết lập quy củ Lạc gia', 'Bọn sơn tặc Hắc Phong Trại kéo tới đòi nợ và cướp người. Đại tiểu thư Lạc Vân Thường run rẩy tuyệt vọng.\n\nTrác Phàm đứng chắn trước cửa lớn, ánh mắt lóe lên ma diễm lạnh lẽo: "Từ hôm nay, quy tắc của Lạc gia do ta định đoạt!"'),
('c3_ch3', 'c3', 3, 'Chương 3: Ma đạo bí pháp', 'Bằng những thủ đoạn tàn độc và xảo quyệt của Ma Hoàng kiếp trước, Trác Phàm từng bước tiêu diệt sạch sẽ thế lực nội gián trong gia tộc, đặt nền móng cho đệ nhất thế gia thiên hạ.'),

-- c4: Toàn Chức Pháp Sư
('c4_ch1', 'c4', 1, 'Chương 1: Thế giới ma pháp', 'Mạc Phàm thức dậy sau một giấc ngủ, thế giới khoa học kỹ thuật đã biến mất, thay vào đó là xe chạy bằng ma thạch, trường học dạy ma pháp nguyên tố.\n\n"Hỏa hệ, Lôi hệ... Tại sao lại có những thứ này?"'),
('c4_ch2', 'c4', 2, 'Chương 2: Thức tỉnh Thiên Sinh Song Hệ', 'Buổi lễ thức tỉnh ma pháp của trường trung học Thiên Lan diễn ra long trọng.\n\nBàn tay Mạc Phàm đặt lên quả cầu thủy tinh ma pháp, ánh lửa màu đỏ rực bùng cháy dữ dội. Nhưng giấu kín bên trong tinh trần là từng tia lôi điện màu tím cuồng bạo: Thiên Sinh Song Hệ!'),
('c4_ch3', 'c4', 3, 'Chương 3: Hỏa Diễm rực sáng', 'Tại sân tập ma pháp phía sau trường, Mạc Phàm luyện tập kết nối 7 ngôi sao ma pháp. Ngọn lửa Hỏa Tư từ đầu ngón tay phóng vút ra, thiêu rụi mục tiêu giả trong nháy mắt.'),

-- c5: Đấu Phá Thương Khung
('c5_ch1', 'c5', 1, 'Chương 1: Phế vật Tiêu gia', 'Tiêu Viêm ngồi trên đỉnh núi sau Tiêu gia, nhìn ngắm chiếc nhẫn đen cũ kỹ trên tay.\n\nBa năm trước, hắn là thiên tài trẻ tuổi nhất Ô Thản Thành. Ba năm sau, đấu khí không rõ lý do thoái hóa xuống Đấu Chi Khí tam đoạn, chịu đủ mọi lời chế giễu.'),
('c5_ch2', 'c5', 2, 'Chương 2: Đấu Khí Đại Lục', 'Gia tộc Nạp Lan mang theo hôn ước tới Tiêu gia từ hôn. Sự sỉ nhục trước mặt toàn thể trưởng bối Tiêu tộc khiến Tiêu Viêm nắm chặt bàn tay đến ứa máu.\n\n"Ba mươi năm Hà Đông, ba mươi năm Hà Tây, đừng khinh thiếu niên nghèo! Nạp Lan Yên Nhiên, ba năm sau ta sẽ đích thân lên Vân Lam Tông!"'),
('c5_ch3', 'c5', 3, 'Chương 3: Dược Lão hiện thân', 'Đêm khuya thanh vắng, linh hồn trong chiếc nhẫn rốt cuộc cũng thức tỉnh.\n\nMột lão giả tóc trắng lơ lửng giữa không trung cười khà khà: "Tiểu gia hỏa, có muốn trở thành Luyện Dược Sư đệ nhất đại lục không?"'),

-- c6: Vũ Động Càn Khôn
('c6_ch1', 'c6', 1, 'Chương 1: Thiếu niên Lâm Động', 'Thanh Dương trấn, phân gia của Lâm thị gia tộc.\n\nLâm Động nhẫn nại ngâm mình trong hồ nước lạnh buốt, gồng mình rèn luyện Thối Thể thiên. Hắn muốn trở nên mạnh mẽ để báo thù cho người cha bị thương tàn phế của mình.'),
('c6_ch2', 'c6', 2, 'Chương 2: Thạch Phù thần bí', 'Dưới đáy hồ sâu, một mảnh thạch phù cổ kính phát ra ánh huỳnh quang nhàn nhạt chìm vào lòng bàn tay Lâm Động.\n\nThạch Phù không chỉ có thể hoàn thiện võ học tàn khuyết mà còn tinh luyện linh dược thành đan dược thượng phẩm.'),
('c6_ch3', 'c6', 3, 'Chương 3: Thông Bối Quyền cửu hưởng', 'Tại diễn võ trường, tiếng quyền phong xé gió vang lên 9 tiếng nổ liên tiếp.\n\nLâm Động đánh bại đệ nhất thiên tài tiểu trấn, mở ra hành trình bước ra đại lục mênh mông.'),

-- c7: Nguyên Tôn
('c7_ch1', 'c7', 1, 'Chương 1: Mãng Tước Thôn Long', 'Đại Chu vương triều, tổ địa phong ấn.\n\nChu Nguyên sinh ra đã mang Thánh Long khí vận, lại bị Vũ Hoàng của Đại Vũ vương triều đoạt mất, khiến bát mạch bị bế tắc, không thể tu luyện nguyên khí.'),
('c7_ch2', 'c7', 2, 'Chương 2: Tề Vương phủ uy hiếp', 'Thế lực Tề Vương câu kết ngoại bang từng bước ép sát hoàng thất Đại Chu.\n\nNhìn phụ vương ngày đêm lo âu thổ huyết, Chu Nguyên quyết tâm bước vào tổ địa cấm kỵ tìm kiếm con đường nghịch thiên cải mệnh.'),
('c7_ch3', 'c7', 3, 'Chương 3: Khai mở bát mạch', 'Trong cấm địa, thiếu nữ bí ẩn Yêu Yêu cùng thần thú Thôn Thôn xuất hiện.\n\nDưới sự hướng dẫn của Hắc Đế truyền thừa, Chu Nguyên dùng bí thuật đả thông kinh mạch thứ nhất, rồng thiêng tỉnh giấc, nguyên khí ngút trời.');

-- 3.4. Dữ liệu lịch sử đọc mẫu cho người dùng id=1 (user@novel.com)
INSERT INTO `reading_history` (`user_id`, `comic_id`, `current_chapter`, `notify_enabled`, `updated_at`) VALUES
(1, 'c1', 1, TRUE, NOW() - INTERVAL 1 HOUR),
(1, 'c2', 3, TRUE, NOW() - INTERVAL 2 HOUR),
(1, 'c3', 2, TRUE, NOW() - INTERVAL 3 HOUR);

-- 3.5. Dữ liệu truyện yêu thích mẫu cho người dùng id=1 (user@novel.com)
INSERT INTO `bookmarks` (`user_id`, `comic_id`, `created_at`) VALUES
(1, 'c0', NOW() - INTERVAL 1 DAY),
(1, 'c2', NOW() - INTERVAL 2 DAY);

-- ====================================================================
-- HOÀN TẤT KHỞI TẠO DỮ LIỆU NOVEL_DB
-- ====================================================================
