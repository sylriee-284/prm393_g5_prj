package com.prm393.novel.model;

import java.time.Instant;

public class RefreshToken {
    private Long id;
    private Long userId;
    private String token;
    private Instant expiryDate;
    private boolean revoked;

    public RefreshToken() {
    }

    public RefreshToken(Long id, Long userId, String token, Instant expiryDate, boolean revoked) {
        this.id = id;
        this.userId = userId;
        this.token = token;
        this.expiryDate = expiryDate;
        this.revoked = revoked;
    }

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public Long getUserId() {
        return userId;
    }

    public void setUserId(Long userId) {
        this.userId = userId;
    }

    public String getToken() {
        return token;
    }

    public void setToken(String token) {
        this.token = token;
    }

    public Instant getExpiryDate() {
        return expiryDate;
    }

    public void setExpiryDate(Instant expiryDate) {
        this.expiryDate = expiryDate;
    }

    public boolean isRevoked() {
        return revoked;
    }

    public void setRevoked(boolean revoked) {
        this.revoked = revoked;
    }
}
