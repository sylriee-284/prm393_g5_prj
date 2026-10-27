package com.prm393.novel.repository;

import com.prm393.novel.model.Comic;
import org.springframework.dao.EmptyResultDataAccessException;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.RowMapper;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public class ComicRepository {

    private final JdbcTemplate jdbcTemplate;

    public ComicRepository(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

    private final RowMapper<Comic> rowMapper = (rs, rowNum) -> new Comic(
            rs.getString("id"),
            rs.getString("title"),
            rs.getString("author"),
            rs.getString("description"),
            rs.getLong("cover_color"),
            rs.getString("cover_label"),
            rs.getString("cover_url"),
            rs.getInt("total_chapters"),
            rs.getString("genre"),
            rs.getInt("views"),
            rs.getString("status"),
            rs.getDouble("rating")
    );

    public List<Comic> findAll() {
        String sql = "SELECT * FROM comics ORDER BY views DESC";
        return jdbcTemplate.query(sql, rowMapper);
    }

    public Optional<Comic> findById(String id) {
        String sql = "SELECT * FROM comics WHERE id = ?";
        try {
            Comic comic = jdbcTemplate.queryForObject(sql, rowMapper, id);
            return Optional.ofNullable(comic);
        } catch (EmptyResultDataAccessException e) {
            return Optional.empty();
        }
    }

    public List<Comic> search(String query) {
        String sql = "SELECT * FROM comics WHERE LOWER(title) LIKE LOWER(?) OR LOWER(author) LIKE LOWER(?) OR LOWER(genre) LIKE LOWER(?)";
        String pattern = "%" + query.trim() + "%";
        return jdbcTemplate.query(sql, rowMapper, pattern, pattern, pattern);
    }

    public List<Comic> findByStatus(String status) {
        String sql = "SELECT * FROM comics WHERE LOWER(status) = LOWER(?) ORDER BY views DESC";
        return jdbcTemplate.query(sql, rowMapper, status);
    }

    public void save(Comic comic) {
        if (findById(comic.getId()).isPresent()) {
            String sql = "UPDATE comics SET title = ?, author = ?, description = ?, cover_color = ?, " +
                         "cover_label = ?, cover_url = ?, total_chapters = ?, genre = ?, views = ?, " +
                         "status = ?, rating = ? WHERE id = ?";
            jdbcTemplate.update(
                    sql,
                    comic.getTitle(),
                    comic.getAuthor(),
                    comic.getDescription(),
                    comic.getCoverColor(),
                    comic.getCoverLabel(),
                    comic.getCoverUrl(),
                    comic.getTotalChapters(),
                    comic.getGenre(),
                    comic.getViews(),
                    comic.getStatus(),
                    comic.getRating(),
                    comic.getId()
            );
        } else {
            String sql = "INSERT INTO comics (id, title, author, description, cover_color, cover_label, " +
                         "cover_url, total_chapters, genre, views, status, rating) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
            jdbcTemplate.update(
                    sql,
                    comic.getId(),
                    comic.getTitle(),
                    comic.getAuthor(),
                    comic.getDescription(),
                    comic.getCoverColor(),
                    comic.getCoverLabel(),
                    comic.getCoverUrl(),
                    comic.getTotalChapters(),
                    comic.getGenre(),
                    comic.getViews(),
                    comic.getStatus(),
                    comic.getRating()
            );
        }
    }

    public int count() {
        Integer c = jdbcTemplate.queryForObject("SELECT COUNT(*) FROM comics", Integer.class);
        return c != null ? c : 0;
    }
}
