package com.prm393.novel.repository;

import com.prm393.novel.model.ReadingHistory;
import org.springframework.dao.EmptyResultDataAccessException;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.RowMapper;
import org.springframework.stereotype.Repository;

import java.sql.Timestamp;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

@Repository
public class ReadingHistoryRepository {

    private final JdbcTemplate jdbcTemplate;

    public ReadingHistoryRepository(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

    private final RowMapper<ReadingHistory> rowMapper = (rs, rowNum) -> new ReadingHistory(
            rs.getLong("id"),
            rs.getLong("user_id"),
            rs.getString("comic_id"),
            rs.getInt("current_chapter"),
            rs.getBoolean("notify_enabled"),
            rs.getTimestamp("updated_at") != null ? rs.getTimestamp("updated_at").toLocalDateTime() : null
    );

    public List<ReadingHistory> findByUserId(Long userId) {
        String sql = "SELECT * FROM reading_history WHERE user_id = ? ORDER BY updated_at DESC";
        return jdbcTemplate.query(sql, rowMapper, userId);
    }

    public Optional<ReadingHistory> findByUserIdAndComicId(Long userId, String comicId) {
        String sql = "SELECT * FROM reading_history WHERE user_id = ? AND comic_id = ?";
        try {
            ReadingHistory history = jdbcTemplate.queryForObject(sql, rowMapper, userId, comicId);
            return Optional.ofNullable(history);
        } catch (EmptyResultDataAccessException e) {
            return Optional.empty();
        }
    }

    public void upsert(Long userId, String comicId, int currentChapter) {
        Optional<ReadingHistory> existing = findByUserIdAndComicId(userId, comicId);
        Timestamp now = Timestamp.valueOf(LocalDateTime.now());
        if (existing.isPresent()) {
            String sql = "UPDATE reading_history SET current_chapter = ?, updated_at = ? WHERE user_id = ? AND comic_id = ?";
            jdbcTemplate.update(sql, currentChapter, now, userId, comicId);
        } else {
            String sql = "INSERT INTO reading_history (user_id, comic_id, current_chapter, notify_enabled, updated_at) VALUES (?, ?, ?, true, ?)";
            jdbcTemplate.update(sql, userId, comicId, currentChapter, now);
        }
    }

    public void toggleNotify(Long userId, String comicId) {
        String sql = "UPDATE reading_history SET notify_enabled = NOT notify_enabled, updated_at = ? WHERE user_id = ? AND comic_id = ?";
        jdbcTemplate.update(sql, Timestamp.valueOf(LocalDateTime.now()), userId, comicId);
    }

    public void delete(Long userId, String comicId) {
        String sql = "DELETE FROM reading_history WHERE user_id = ? AND comic_id = ?";
        jdbcTemplate.update(sql, userId, comicId);
    }

    public int countByUserId(Long userId) {
        Integer count = jdbcTemplate.queryForObject("SELECT COUNT(*) FROM reading_history WHERE user_id = ?", Integer.class, userId);
        return count != null ? count : 0;
    }
}
