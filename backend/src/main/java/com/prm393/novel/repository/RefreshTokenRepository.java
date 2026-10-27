package com.prm393.novel.repository;

import com.prm393.novel.model.RefreshToken;
import org.springframework.dao.EmptyResultDataAccessException;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.RowMapper;
import org.springframework.stereotype.Repository;

import java.sql.Timestamp;
import java.util.Optional;

@Repository
public class RefreshTokenRepository {

    private final JdbcTemplate jdbcTemplate;

    public RefreshTokenRepository(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

    private final RowMapper<RefreshToken> rowMapper = (rs, rowNum) -> new RefreshToken(
            rs.getLong("id"),
            rs.getLong("user_id"),
            rs.getString("token"),
            rs.getTimestamp("expiry_date").toInstant(),
            rs.getBoolean("revoked")
    );

    public void save(RefreshToken token) {
        String sql = "INSERT INTO refresh_tokens (user_id, token, expiry_date, revoked) VALUES (?, ?, ?, ?)";
        jdbcTemplate.update(sql, token.getUserId(), token.getToken(), Timestamp.from(token.getExpiryDate()), token.isRevoked());
    }

    public Optional<RefreshToken> findByToken(String token) {
        String sql = "SELECT * FROM refresh_tokens WHERE token = ? AND revoked = false";
        try {
            RefreshToken rt = jdbcTemplate.queryForObject(sql, rowMapper, token);
            return Optional.ofNullable(rt);
        } catch (EmptyResultDataAccessException e) {
            return Optional.empty();
        }
    }

    public void revokeByToken(String token) {
        String sql = "UPDATE refresh_tokens SET revoked = true WHERE token = ?";
        jdbcTemplate.update(sql, token);
    }

    public void revokeByUserId(Long userId) {
        String sql = "UPDATE refresh_tokens SET revoked = true WHERE user_id = ?";
        jdbcTemplate.update(sql, userId);
    }

    public void deleteExpiredTokens() {
        String sql = "DELETE FROM refresh_tokens WHERE expiry_date < ?";
        jdbcTemplate.update(sql, Timestamp.from(java.time.Instant.now()));
    }
}
