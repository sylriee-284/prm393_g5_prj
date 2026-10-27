package com.prm393.novel.model;

import java.time.LocalDateTime;

public class ReadingHistory {
    private Long id;
    private Long userId;
    private String comicId;
    private int currentChapter;
    private boolean notifyEnabled;
    private LocalDateTime updatedAt;

    public ReadingHistory() {
    }

    public ReadingHistory(Long id, Long userId, String comicId, int currentChapter, boolean notifyEnabled, LocalDateTime updatedAt) {
        this.id = id;
        this.userId = userId;
        this.comicId = comicId;
        this.currentChapter = currentChapter;
        this.notifyEnabled = notifyEnabled;
        this.updatedAt = updatedAt;
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

    public int getCurrentChapter() {
        return currentChapter;
    }

    public void setCurrentChapter(int currentChapter) {
        this.currentChapter = currentChapter;
    }

    public boolean isNotifyEnabled() {
        return notifyEnabled;
    }

    public void setNotifyEnabled(boolean notifyEnabled) {
        this.notifyEnabled = notifyEnabled;
    }

    public LocalDateTime getUpdatedAt() {
        return updatedAt;
    }

    public void setUpdatedAt(LocalDateTime updatedAt) {
        this.updatedAt = updatedAt;
    }
}
