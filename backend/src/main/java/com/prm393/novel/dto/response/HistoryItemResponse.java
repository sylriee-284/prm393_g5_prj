package com.prm393.novel.dto.response;

import com.prm393.novel.model.Comic;

import java.time.LocalDateTime;

public class HistoryItemResponse {
    private String comicId;
    private int currentChapter;
    private boolean notifyEnabled;
    private Comic comic;
    private LocalDateTime updatedAt;

    public HistoryItemResponse() {
    }

    public HistoryItemResponse(String comicId, int currentChapter, boolean notifyEnabled, Comic comic, LocalDateTime updatedAt) {
        this.comicId = comicId;
        this.currentChapter = currentChapter;
        this.notifyEnabled = notifyEnabled;
        this.comic = comic;
        this.updatedAt = updatedAt;
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

    public Comic getComic() {
        return comic;
    }

    public void setComic(Comic comic) {
        this.comic = comic;
    }

    public LocalDateTime getUpdatedAt() {
        return updatedAt;
    }

    public void setUpdatedAt(LocalDateTime updatedAt) {
        this.updatedAt = updatedAt;
    }
}
