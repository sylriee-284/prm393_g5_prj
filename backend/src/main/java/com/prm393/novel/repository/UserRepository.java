package com.prm393.novel.repository;

import com.prm393.novel.model.Role;
import com.prm393.novel.model.User;
import org.springframework.dao.EmptyResultDataAccessException;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.RowMapper;
import org.springframework.jdbc.support.GeneratedKeyHolder;
import org.springframework.jdbc.support.KeyHolder;
import org.springframework.stereotype.Repository;

import java.sql.PreparedStatement;
import java.sql.Statement;
import java.sql.Timestamp;
import java.time.LocalDateTime;
import java.util.Optional;

@Repository
public class UserRepository {

    private final JdbcTemplate jdbcTemplate;

    public UserRepository(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

    private final RowMapper<User> rowMapper = (rs, rowNum) -> new User(
            rs.getLong("id"),
            rs.getString("email"),
            rs.getString("password"),
            rs.getString("full_name"),
            rs.getString("avatar_url"),
            Role.valueOf(rs.getString("role")),
            rs.getTimestamp("created_at") != null ? rs.getTimestamp("created_at").toLocalDateTime() : null,
            rs.getTimestamp("updated_at") != null ? rs.getTimestamp("updated_at").toLocalDateTime() : null
    );

    public boolean existsByEmail(String email) {
        String sql = "SELECT COUNT(*) FROM users WHERE LOWER(email) = LOWER(?)";
        Integer count = jdbcTemplate.queryForObject(sql, Integer.class, email);
        return count != null && count > 0;
    }

    public Optional<User> findByEmail(String email) {
        String sql = "SELECT * FROM users WHERE LOWER(email) = LOWER(?)";
        try {
            User user = jdbcTemplate.queryForObject(sql, rowMapper, email);
            return Optional.ofNullable(user);
        } catch (EmptyResultDataAccessException e) {
            return Optional.empty();
        }
    }

    public Optional<User> findById(Long id) {
        String sql = "SELECT * FROM users WHERE id = ?";
        try {
            User user = jdbcTemplate.queryForObject(sql, rowMapper, id);
            return Optional.ofNullable(user);
        } catch (EmptyResultDataAccessException e) {
            return Optional.empty();
        }
    }

    public User save(User user) {
        String sql = "INSERT INTO users (email, password, full_name, avatar_url, role, created_at, updated_at) " +
                     "VALUES (?, ?, ?, ?, ?, ?, ?)";
        KeyHolder keyHolder = new GeneratedKeyHolder();
        LocalDateTime now = LocalDateTime.now();
        user.setCreatedAt(now);
        user.setUpdatedAt(now);

        jdbcTemplate.update(connection -> {
            PreparedStatement ps = connection.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS);
            ps.setString(1, user.getEmail());
            ps.setString(2, user.getPassword());
            ps.setString(3, user.getFullName());
            ps.setString(4, user.getAvatarUrl());
            ps.setString(5, user.getRole().name());
            ps.setTimestamp(6, Timestamp.valueOf(now));
            ps.setTimestamp(7, Timestamp.valueOf(now));
            return ps;
        }, keyHolder);

        if (keyHolder.getKey() != null) {
            user.setId(keyHolder.getKey().longValue());
        }
        return user;
    }

    public void updateProfile(Long id, String fullName, String avatarUrl) {
        String sql = "UPDATE users SET full_name = ?, avatar_url = ?, updated_at = ? WHERE id = ?";
        jdbcTemplate.update(sql, fullName, avatarUrl, Timestamp.valueOf(LocalDateTime.now()), id);
    }

    public void updatePassword(Long id, String encodedPassword) {
        String sql = "UPDATE users SET password = ?, updated_at = ? WHERE id = ?";
        jdbcTemplate.update(sql, encodedPassword, Timestamp.valueOf(LocalDateTime.now()), id);
    }
}
