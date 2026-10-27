package com.prm393.novel.dto.request;

import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;

public class UpdateProgressRequest {

    @NotBlank(message = "Comic ID không được để trống")
    private String comicId;

    @Min(value = 1, message = "Số chương phải lớn hơn hoặc bằng 1")
    private int currentChapter;

    public UpdateProgressRequest() {
    }

    public UpdateProgressRequest(String comicId, int currentChapter) {
        this.comicId = comicId;
        this.currentChapter = currentChapter;
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
}
