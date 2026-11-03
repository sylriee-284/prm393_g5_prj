package com.prm393.novel.dto.request;

import jakarta.validation.constraints.NotBlank;

public class SaveComicRequest {

    private String id;

    @NotBlank(message = "Tiêu đề truyện không được để trống")
    private String title;

    @NotBlank(message = "Tên tác giả không được để trống")
    private String author;

    private String description;
    private Long coverColor;
    private String coverLabel;
    private String coverUrl;
    private String genre = "Tiên hiệp";
    private String status = "ongoing";
    private Boolean isHidden = false;

    public SaveComicRequest() {
    }

    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public String getAuthor() {
        return author;
    }

    public void setAuthor(String author) {
        this.author = author;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public Long getCoverColor() {
        return coverColor;
    }

    public void setCoverColor(Long coverColor) {
        this.coverColor = coverColor;
    }

    public String getCoverLabel() {
        return coverLabel;
    }

    public void setCoverLabel(String coverLabel) {
        this.coverLabel = coverLabel;
    }

    public String getCoverUrl() {
        return coverUrl;
    }

    public void setCoverUrl(String coverUrl) {
        this.coverUrl = coverUrl;
    }

    public String getGenre() {
        return genre;
    }

    public void setGenre(String genre) {
        this.genre = genre;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public Boolean getIsHidden() {
        return isHidden;
    }

    public void setIsHidden(Boolean hidden) {
        this.isHidden = hidden;
    }
}

