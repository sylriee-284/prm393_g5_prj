package com.prm393.novel.controller;

import com.prm393.novel.dto.request.*;
import com.prm393.novel.dto.response.ApiResponse;
import com.prm393.novel.dto.response.AuthResponse;
import com.prm393.novel.dto.response.UserProfileResponse;
import com.prm393.novel.security.UserPrincipal;
import com.prm393.novel.service.AuthService;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/auth")
public class AuthController {

    private final AuthService authService;

    public AuthController(AuthService authService) {
        this.authService = authService;
    }

    @PostMapping("/register")
    public ResponseEntity<ApiResponse<AuthResponse>> register(@Valid @RequestBody RegisterRequest request) {
        AuthResponse response = authService.register(request);
        return ResponseEntity.ok(ApiResponse.ok("Đăng ký tài khoản thành công", response));
    }

    @PostMapping("/login")
    public ResponseEntity<ApiResponse<AuthResponse>> login(@Valid @RequestBody LoginRequest request) {
        AuthResponse response = authService.login(request);
        return ResponseEntity.ok(ApiResponse.ok("Đăng nhập thành công", response));
    }

    @PostMapping("/refresh")
    public ResponseEntity<ApiResponse<AuthResponse>> refresh(@Valid @RequestBody RefreshTokenRequest request) {
        AuthResponse response = authService.refreshToken(request);
        return ResponseEntity.ok(ApiResponse.ok("Làm mới token thành công", response));
    }

    @PostMapping("/logout")
    public ResponseEntity<ApiResponse<Void>> logout(@RequestBody(required = false) RefreshTokenRequest request) {
        if (request != null && request.getRefreshToken() != null) {
            authService.logout(request.getRefreshToken());
        }
        return ResponseEntity.ok(ApiResponse.ok("Đăng xuất thành công", null));
    }

    @PostMapping("/google")
    public ResponseEntity<ApiResponse<AuthResponse>> googleLogin(@Valid @RequestBody GoogleLoginRequest request) {
        AuthResponse response = authService.googleLogin(request);
        return ResponseEntity.ok(ApiResponse.ok("Đăng nhập bằng Google thành công", response));
    }

    @GetMapping("/me")
    public ResponseEntity<ApiResponse<UserProfileResponse>> getCurrentUser(@AuthenticationPrincipal UserPrincipal currentUser) {
        UserProfileResponse profile = authService.getCurrentUserProfile(currentUser.getId());
        return ResponseEntity.ok(ApiResponse.ok(profile));
    }

    @PutMapping("/profile")
    public ResponseEntity<ApiResponse<UserProfileResponse>> updateProfile(
            @AuthenticationPrincipal UserPrincipal currentUser,
            @Valid @RequestBody UpdateProfileRequest request) {
        UserProfileResponse profile = authService.updateProfile(currentUser.getId(), request);
        return ResponseEntity.ok(ApiResponse.ok("Cập nhật thông tin thành công", profile));
    }

    @PostMapping("/change-password")
    public ResponseEntity<ApiResponse<Void>> changePassword(
            @AuthenticationPrincipal UserPrincipal currentUser,
            @Valid @RequestBody ChangePasswordRequest request) {
        authService.changePassword(currentUser.getId(), request);
        return ResponseEntity.ok(ApiResponse.ok("Đổi mật khẩu thành công. Vui lòng đăng nhập lại trên các thiết bị khác.", null));
    }
}
