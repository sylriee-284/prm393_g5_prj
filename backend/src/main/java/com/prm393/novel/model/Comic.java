package com.prm393.novel.model;

public class Comic {
    private String id;
    private String title;
    private String author;
    private String description;
    private long coverColor;
    private String coverLabel;
    private String coverUrl;
    private int totalChapters;
    private String genre;
    private int views;
    private String status;
    private double rating;

    public Comic() {
    }

    public Comic(String id, String title, String author, String description, long coverColor, String coverLabel, String coverUrl, int totalChapters, String genre, int views, String status, double rating) {
        this.id = id;
        this.title = title;
        this.author = author;
        this.description = description;
        this.coverColor = coverColor;
        this.coverLabel = coverLabel;
        this.coverUrl = coverUrl;
        this.totalChapters = totalChapters;
        this.genre = genre;
        this.views = views;
        this.status = status;
        this.rating = rating;
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

    public long getCoverColor() {
        return coverColor;
    }

    public void setCoverColor(long coverColor) {
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

    public int getTotalChapters() {
        return totalChapters;
    }

    public void setTotalChapters(int totalChapters) {
        this.totalChapters = totalChapters;
    }

    public String getGenre() {
        return genre;
    }

    public void setGenre(String genre) {
        this.genre = genre;
    }

    public int getViews() {
        return views;
    }

    public void setViews(int views) {
        this.views = views;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public double getRating() {
        return rating;
    }

    public void setRating(double rating) {
        this.rating = rating;
    }
}
