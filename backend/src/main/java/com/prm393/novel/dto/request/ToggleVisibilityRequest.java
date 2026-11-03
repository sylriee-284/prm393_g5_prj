package com.prm393.novel.dto.request;

public class ToggleVisibilityRequest {
    private Boolean isHidden;

    public ToggleVisibilityRequest() {
    }

    public ToggleVisibilityRequest(Boolean isHidden) {
        this.isHidden = isHidden;
    }

    public Boolean getIsHidden() {
        return isHidden;
    }

    public void setIsHidden(Boolean hidden) {
        this.isHidden = hidden;
    }
}

