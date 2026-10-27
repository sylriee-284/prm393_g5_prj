package com.prm393.novel.model;

import java.time.LocalDateTime;

public class Bookmark {
    private Long id;
    private Long userId;
    private String comicId;
    private LocalDateTime createdAt;

    public Bookmark() {
    }

    public Bookmark(Long id, Long userId, String comicId, LocalDateTime createdAt) {
        this.id = id;
        this.userId = userId;
        this.comicId = comicId;
        this.createdAt = createdAt;
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

    public String getComicId() {
        return comicId;
    }

    public void setComicId(String comicId) {
        this.comicId = comicId;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }
}
