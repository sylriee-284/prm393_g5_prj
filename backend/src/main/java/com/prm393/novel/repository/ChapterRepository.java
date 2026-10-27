package com.prm393.novel.repository;

import com.prm393.novel.model.Chapter;
import org.springframework.dao.EmptyResultDataAccessException;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.RowMapper;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public class ChapterRepository {

    private final JdbcTemplate jdbcTemplate;

    public ChapterRepository(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

    private final RowMapper<Chapter> rowMapper = (rs, rowNum) -> new Chapter(
            rs.getString("id"),
            rs.getString("comic_id"),
            rs.getInt("number"),
            rs.getString("title"),
            rs.getString("content")
    );

    public List<Chapter> findByComicId(String comicId) {
        String sql = "SELECT * FROM chapters WHERE comic_id = ? ORDER BY number ASC";
        return jdbcTemplate.query(sql, rowMapper, comicId);
    }

    public Optional<Chapter> findByComicIdAndNumber(String comicId, int number) {
        String sql = "SELECT * FROM chapters WHERE comic_id = ? AND number = ?";
        try {
            Chapter chapter = jdbcTemplate.queryForObject(sql, rowMapper, comicId, number);
            return Optional.ofNullable(chapter);
        } catch (EmptyResultDataAccessException e) {
            return Optional.empty();
        }
    }

    public void save(Chapter chapter) {
        String checkSql = "SELECT COUNT(*) FROM chapters WHERE id = ?";
        Integer count = jdbcTemplate.queryForObject(checkSql, Integer.class, chapter.getId());
        if (count != null && count > 0) {
            String sql = "UPDATE chapters SET comic_id = ?, number = ?, title = ?, content = ? WHERE id = ?";
            jdbcTemplate.update(sql, chapter.getComicId(), chapter.getNumber(), chapter.getTitle(), chapter.getContent(), chapter.getId());
        } else {
            String sql = "INSERT INTO chapters (id, comic_id, number, title, content) VALUES (?, ?, ?, ?, ?)";
            jdbcTemplate.update(sql, chapter.getId(), chapter.getComicId(), chapter.getNumber(), chapter.getTitle(), chapter.getContent());
        }
    }

    public int count() {
        Integer c = jdbcTemplate.queryForObject("SELECT COUNT(*) FROM chapters", Integer.class);
        return c != null ? c : 0;
    }
}
