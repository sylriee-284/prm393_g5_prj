package com.prm393.novel.dto.request;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;

public class ChangePasswordRequest {

    @NotBlank(message = "Mật khẩu cũ không được để trống")
    private String oldPassword;

    @NotBlank(message = "Mật khẩu mới không được để trống")
    @Size(min = 6, max = 32, message = "Mật khẩu mới phải từ 6 đến 32 ký tự")
    @Pattern(
        regexp = "^(?=.*[A-Z])(?=.*\\d).*$",
        message = "Mật khẩu mới phải chứa ít nhất 1 chữ hoa và 1 chữ số"
    )
    private String newPassword;

    public ChangePasswordRequest() {
    }

    public ChangePasswordRequest(String oldPassword, String newPassword) {
        this.oldPassword = oldPassword;
        this.newPassword = newPassword;
    }

    public String getOldPassword() {
        return oldPassword;
    }

    public void setOldPassword(String oldPassword) {
        this.oldPassword = oldPassword;
    }

    public String getNewPassword() {
        return newPassword;
    }

    public void setNewPassword(String newPassword) {
        this.newPassword = newPassword;
    }
}
