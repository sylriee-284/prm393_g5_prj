package com.prm393.novel.config;

import com.prm393.novel.repository.ComicRepository;
import com.prm393.novel.repository.UserRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.boot.CommandLineRunner;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Component;
/**
 * Kiểm tra trạng thái cơ sở dữ liệu MySQL khi ứng dụng khởi động.
 * Cấu trúc bảng và dữ liệu mẫu được khởi tạo tập trung thông qua file database.sql thay vì hardcode trong Java.
 */
@Component
public class DatabaseInitializer implements CommandLineRunner {

    private static final Logger logger = LoggerFactory.getLogger(DatabaseInitializer.class);

    private final ComicRepository comicRepository;
    private final UserRepository userRepository;
    private final JdbcTemplate jdbcTemplate;

    public DatabaseInitializer(ComicRepository comicRepository, UserRepository userRepository, JdbcTemplate jdbcTemplate) {
        this.comicRepository = comicRepository;
        this.userRepository = userRepository;
        this.jdbcTemplate = jdbcTemplate;
    }

    @Override
    public void run(String... args) {
        try {
            // Tự động kiểm tra và thêm cột is_hidden nếu DB cũ chưa có
            try {
                jdbcTemplate.execute("ALTER TABLE comics ADD COLUMN is_hidden BOOLEAN NOT NULL DEFAULT FALSE");
                logger.info(" - Đã tự động cập nhật schema: thêm cột 'is_hidden' vào bảng comics.");
            } catch (Exception ignored) {
                // Đã tồn tại cột is_hidden
            }

            int comicsCount = comicRepository.count();
            boolean hasDemoUser = userRepository.existsByEmail("user@novel.com");
            logger.info("====================================================================");
            logger.info(" Kết nối cơ sở dữ liệu MySQL thành công!");
            logger.info(" - Tổng số bộ truyện trong DB : {}", comicsCount);
            logger.info(" - Tài khoản mẫu (user@novel.com) : {}", hasDemoUser ? "ĐÃ SẴN SÀNG" : "CHƯA TÌM THẤY");
            if (comicsCount == 0) {
                logger.warn(" Lưu ý: Cơ sở dữ liệu đang trống. Vui lòng chạy file 'database.sql' vào MySQL để khởi tạo bảng và dữ liệu mẫu.");
            }
            logger.info("====================================================================");
        } catch (Exception e) {
            logger.warn("Không thể kiểm tra dữ liệu database khi khởi động: {}", e.getMessage());
        }
    }
}
