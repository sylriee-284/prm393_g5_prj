package com.prm393.novel.model;

public class Chapter {
    private String id;
    private String comicId;
    private int number;
    private String title;
    private String content;

    public Chapter() {
    }

    public Chapter(String id, String comicId, int number, String title, String content) {
        this.id = id;
        this.comicId = comicId;
        this.number = number;
        this.title = title;
        this.content = content;
    }

    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }

    public String getComicId() {
        return comicId;
    }

    public void setComicId(String comicId) {
        this.comicId = comicId;
    }

    public int getNumber() {
        return number;
    }

    public void setNumber(int number) {
        this.number = number;
    }

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public String getContent() {
        return content;
    }

    public void setContent(String content) {
        this.content = content;
    }
}
