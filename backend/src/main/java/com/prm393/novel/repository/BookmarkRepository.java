package com.prm393.novel.repository;

import com.prm393.novel.model.Bookmark;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.RowMapper;
import org.springframework.stereotype.Repository;

import java.sql.Timestamp;
import java.time.LocalDateTime;
import java.util.List;

@Repository
public class BookmarkRepository {

    private final JdbcTemplate jdbcTemplate;

    public BookmarkRepository(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

    private final RowMapper<Bookmark> rowMapper = (rs, rowNum) -> new Bookmark(
            rs.getLong("id"),
            rs.getLong("user_id"),
            rs.getString("comic_id"),
            rs.getTimestamp("created_at") != null ? rs.getTimestamp("created_at").toLocalDateTime() : null
    );

    public List<Bookmark> findByUserId(Long userId) {
        String sql = "SELECT * FROM bookmarks WHERE user_id = ? ORDER BY created_at DESC";
        return jdbcTemplate.query(sql, rowMapper, userId);
    }

    public boolean exists(Long userId, String comicId) {
        String sql = "SELECT COUNT(*) FROM bookmarks WHERE user_id = ? AND comic_id = ?";
        Integer count = jdbcTemplate.queryForObject(sql, Integer.class, userId, comicId);
        return count != null && count > 0;
    }

    public void add(Long userId, String comicId) {
        if (!exists(userId, comicId)) {
            String sql = "INSERT INTO bookmarks (user_id, comic_id, created_at) VALUES (?, ?, ?)";
            jdbcTemplate.update(sql, userId, comicId, Timestamp.valueOf(LocalDateTime.now()));
        }
    }

    public void remove(Long userId, String comicId) {
        String sql = "DELETE FROM bookmarks WHERE user_id = ? AND comic_id = ?";
        jdbcTemplate.update(sql, userId, comicId);
    }

    public int countByUserId(Long userId) {
        Integer count = jdbcTemplate.queryForObject("SELECT COUNT(*) FROM bookmarks WHERE user_id = ?", Integer.class, userId);
        return count != null ? count : 0;
    }
}
