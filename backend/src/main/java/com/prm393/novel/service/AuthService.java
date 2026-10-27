package com.prm393.novel.service;

import com.prm393.novel.dto.request.*;
import com.prm393.novel.dto.response.AuthResponse;
import com.prm393.novel.dto.response.UserProfileResponse;
import com.prm393.novel.exception.AppException;
import com.prm393.novel.exception.ResourceNotFoundException;
import com.prm393.novel.exception.TokenRefreshException;
import com.prm393.novel.model.RefreshToken;
import com.prm393.novel.model.Role;
import com.prm393.novel.model.User;
import com.prm393.novel.repository.BookmarkRepository;
import com.prm393.novel.repository.ReadingHistoryRepository;
import com.prm393.novel.repository.RefreshTokenRepository;
import com.prm393.novel.repository.UserRepository;
import com.prm393.novel.security.JwtTokenProvider;
import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.util.UUID;

@Service
public class AuthService {

    private final UserRepository userRepository;
    private final RefreshTokenRepository refreshTokenRepository;
    private final ReadingHistoryRepository readingHistoryRepository;
    private final BookmarkRepository bookmarkRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtTokenProvider tokenProvider;

    public AuthService(UserRepository userRepository,
                       RefreshTokenRepository refreshTokenRepository,
                       ReadingHistoryRepository readingHistoryRepository,
                       BookmarkRepository bookmarkRepository,
                       PasswordEncoder passwordEncoder,
                       JwtTokenProvider tokenProvider) {
        this.userRepository = userRepository;
        this.refreshTokenRepository = refreshTokenRepository;
        this.readingHistoryRepository = readingHistoryRepository;
        this.bookmarkRepository = bookmarkRepository;
        this.passwordEncoder = passwordEncoder;
        this.tokenProvider = tokenProvider;
    }

    @Transactional
    public AuthResponse register(RegisterRequest request) {
        if (!request.getPassword().equals(request.getConfirmPassword())) {
            throw new AppException("Mật khẩu và xác nhận mật khẩu không khớp");
        }

        if (userRepository.existsByEmail(request.getEmail())) {
            throw new AppException("Email này đã được sử dụng. Vui lòng chọn email khác.");
        }

        User user = new User();
        user.setEmail(request.getEmail().toLowerCase());
        user.setPassword(passwordEncoder.encode(request.getPassword()));
        user.setFullName(request.getFullName());
        user.setAvatarUrl("https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=150&auto=format&fit=crop&q=80");
        user.setRole(Role.ROLE_USER);

        user = userRepository.save(user);

        return createAuthResponse(user);
    }

    @Transactional
    public AuthResponse login(LoginRequest request) {
        User user = userRepository.findByEmail(request.getEmail().toLowerCase())
                .orElseThrow(() -> new BadCredentialsException("Email hoặc mật khẩu không chính xác"));

        if (!passwordEncoder.matches(request.getPassword(), user.getPassword())) {
            throw new BadCredentialsException("Email hoặc mật khẩu không chính xác");
        }

        return createAuthResponse(user);
    }

    @Transactional
    public AuthResponse refreshToken(RefreshTokenRequest request) {
        RefreshToken token = refreshTokenRepository.findByToken(request.getRefreshToken())
                .orElseThrow(() -> new TokenRefreshException("Refresh token không tồn tại hoặc đã bị thu hồi"));

        if (token.getExpiryDate().isBefore(Instant.now())) {
            refreshTokenRepository.revokeByToken(token.getToken());
            throw new TokenRefreshException("Refresh token đã hết hạn. Vui lòng đăng nhập lại.");
        }

        User user = userRepository.findById(token.getUserId())
                .orElseThrow(() -> new ResourceNotFoundException("Người dùng không còn tồn tại"));

        String newAccessToken = tokenProvider.generateAccessToken(user);

        UserProfileResponse profile = getProfileResponse(user);

        return new AuthResponse(
                newAccessToken,
                token.getToken(),
                tokenProvider.getAccessTokenExpirationMs() / 1000,
                profile
        );
    }

    @Transactional
    public void logout(String refreshToken) {
        if (refreshToken != null && !refreshToken.isBlank()) {
            refreshTokenRepository.revokeByToken(refreshToken);
        }
    }

    @Transactional
    public AuthResponse googleLogin(GoogleLoginRequest request) {
        String email = request.getEmail().toLowerCase();
        User user = userRepository.findByEmail(email).orElse(null);

        if (user == null) {
            user = new User();
            user.setEmail(email);
            // Mật khẩu ngẫu nhiên bảo mật vì tài khoản quản lý bởi Google OAuth
            user.setPassword(passwordEncoder.encode(UUID.randomUUID().toString()));
            user.setFullName(request.getFullName() != null && !request.getFullName().isBlank() ? request.getFullName() : email.split("@")[0]);
            user.setAvatarUrl(request.getAvatarUrl() != null && !request.getAvatarUrl().isBlank()
                    ? request.getAvatarUrl()
                    : "https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=150&auto=format&fit=crop&q=80");
            user.setRole(Role.ROLE_USER);
            user = userRepository.save(user);
        } else {
            // Cập nhật thông tin avatar hoặc name nếu có thay đổi từ Google
            boolean updated = false;
            if (request.getFullName() != null && !request.getFullName().isBlank() && !request.getFullName().equals(user.getFullName())) {
                user.setFullName(request.getFullName());
                updated = true;
            }
            if (request.getAvatarUrl() != null && !request.getAvatarUrl().isBlank() && !request.getAvatarUrl().equals(user.getAvatarUrl())) {
                user.setAvatarUrl(request.getAvatarUrl());
                updated = true;
            }
            if (updated) {
                userRepository.updateProfile(user.getId(), user.getFullName(), user.getAvatarUrl());
            }
        }

        return createAuthResponse(user);
    }

    public UserProfileResponse getCurrentUserProfile(Long userId) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy thông tin người dùng"));
        return getProfileResponse(user);
    }

    @Transactional
    public UserProfileResponse updateProfile(Long userId, UpdateProfileRequest request) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy người dùng"));

        String avatar = (request.getAvatarUrl() != null && !request.getAvatarUrl().isBlank())
                ? request.getAvatarUrl().trim()
                : user.getAvatarUrl();

        userRepository.updateProfile(userId, request.getFullName().trim(), avatar);
        user.setFullName(request.getFullName().trim());
        user.setAvatarUrl(avatar);
        return getProfileResponse(user);
    }

    @Transactional
    public void changePassword(Long userId, ChangePasswordRequest request) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("Không tìm thấy người dùng"));

        if (!passwordEncoder.matches(request.getOldPassword(), user.getPassword())) {
            throw new AppException("Mật khẩu hiện tại không đúng");
        }

        if (passwordEncoder.matches(request.getNewPassword(), user.getPassword())) {
            throw new AppException("Mật khẩu mới không được trùng với mật khẩu cũ");
        }

        userRepository.updatePassword(userId, passwordEncoder.encode(request.getNewPassword()));
        // Hủy toàn bộ refresh token cũ để buộc các phiên đăng nhập khác đăng nhập lại
        refreshTokenRepository.revokeByUserId(userId);
    }

    private AuthResponse createAuthResponse(User user) {
        String accessToken = tokenProvider.generateAccessToken(user);
        String refreshTokenStr = tokenProvider.generateRefreshTokenString();

        Instant expiryDate = Instant.now().plusMillis(tokenProvider.getRefreshTokenExpirationMs());
        RefreshToken refreshToken = new RefreshToken(null, user.getId(), refreshTokenStr, expiryDate, false);
        refreshTokenRepository.save(refreshToken);

        UserProfileResponse profile = getProfileResponse(user);

        return new AuthResponse(
                accessToken,
                refreshTokenStr,
                tokenProvider.getAccessTokenExpirationMs() / 1000,
                profile
        );
    }

    private UserProfileResponse getProfileResponse(User user) {
        int historyCount = readingHistoryRepository.countByUserId(user.getId());
        int bookmarkCount = bookmarkRepository.countByUserId(user.getId());

        return new UserProfileResponse(
                user.getId(),
                user.getEmail(),
                user.getFullName(),
                user.getAvatarUrl(),
                user.getRole(),
                historyCount,
                bookmarkCount
        );
    }
}
