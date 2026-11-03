package com.prm393.novel.dto.request;

import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;

public class SaveChapterRequest {

    @NotNull(message = "Số thứ tự chương không được để trống")
    @Min(value = 1, message = "Số chương phải lớn hơn hoặc bằng 1")
    private Integer number;

    @NotBlank(message = "Tiêu đề chương không được để trống")
    private String title;

    @NotBlank(message = "Nội dung chương không được để trống")
    private String content;

    public SaveChapterRequest() {
    }

    public SaveChapterRequest(Integer number, String title, String content) {
        this.number = number;
        this.title = title;
        this.content = content;
    }

    public Integer getNumber() {
        return number;
    }

    public void setNumber(Integer number) {
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

