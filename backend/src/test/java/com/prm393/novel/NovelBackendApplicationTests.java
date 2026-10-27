package com.prm393.novel;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.prm393.novel.dto.request.LoginRequest;
import com.prm393.novel.dto.request.RefreshTokenRequest;
import com.prm393.novel.dto.request.RegisterRequest;
import com.prm393.novel.dto.response.AuthResponse;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.MvcResult;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@SpringBootTest
@AutoConfigureMockMvc
class NovelBackendApplicationTests {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private ObjectMapper objectMapper;

    @Autowired
    private org.springframework.security.crypto.password.PasswordEncoder passwordEncoder;



    @Test
    @DisplayName("1. Đăng ký tài khoản mới thành công")
    void testRegisterSuccess() throws Exception {
        String email = "tester_" + System.currentTimeMillis() + "@novel.com";
        RegisterRequest req = new RegisterRequest(
                email,
                "Password123",
                "Password123",
                "Tester Số 1"
        );

        mockMvc.perform(post("/api/auth/register")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(req)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true))
                .andExpect(jsonPath("$.data.accessToken").isNotEmpty())
                .andExpect(jsonPath("$.data.refreshToken").isNotEmpty())
                .andExpect(jsonPath("$.data.user.email").value(email));
    }

    @Test
    @DisplayName("2. Đăng ký thất bại khi mật khẩu không khớp")
    void testRegisterPasswordMismatch() throws Exception {
        RegisterRequest req = new RegisterRequest(
                "tester_mismatch@novel.com",
                "Password123",
                "DifferentPassword123",
                "Tester Mismatch"
        );

        mockMvc.perform(post("/api/auth/register")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(req)))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.success").value(false));
    }

    @Test
    @DisplayName("3. Đăng nhập thành công với tài khoản mẫu (seeded)")
    void testLoginSuccess() throws Exception {
        LoginRequest req = new LoginRequest("user@novel.com", "User@123");

        mockMvc.perform(post("/api/auth/login")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(req)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true))
                .andExpect(jsonPath("$.data.accessToken").isNotEmpty())
                .andExpect(jsonPath("$.data.refreshToken").isNotEmpty())
                .andExpect(jsonPath("$.data.user.email").value("user@novel.com"));
    }

    @Test
    @DisplayName("4. Đăng nhập thất bại khi sai mật khẩu trả về 401")
    void testLoginBadCredentials() throws Exception {
        LoginRequest req = new LoginRequest("user@novel.com", "WrongPassword999");

        mockMvc.perform(post("/api/auth/login")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(req)))
                .andExpect(status().isUnauthorized())
                .andExpect(jsonPath("$.success").value(false));
    }

    @Test
    @DisplayName("5. Làm mới token bằng refresh token")
    void testRefreshToken() throws Exception {
        // Đăng nhập lấy refresh token
        LoginRequest loginReq = new LoginRequest("user@novel.com", "User@123");
        MvcResult loginResult = mockMvc.perform(post("/api/auth/login")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(loginReq)))
                .andExpect(status().isOk())
                .andReturn();

        String json = loginResult.getResponse().getContentAsString();
        String refreshToken = objectMapper.readTree(json).get("data").get("refreshToken").asText();

        RefreshTokenRequest refreshReq = new RefreshTokenRequest(refreshToken);
        mockMvc.perform(post("/api/auth/refresh")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(refreshReq)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true))
                .andExpect(jsonPath("$.data.accessToken").isNotEmpty());
    }

    @Test
    @DisplayName("6. Truy cập endpoint /api/auth/me với Bearer token")
    void testGetCurrentUserProfile() throws Exception {
        LoginRequest loginReq = new LoginRequest("user@novel.com", "User@123");
        MvcResult loginResult = mockMvc.perform(post("/api/auth/login")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(loginReq)))
                .andReturn();

        String json = loginResult.getResponse().getContentAsString();
        String accessToken = objectMapper.readTree(json).get("data").get("accessToken").asText();

        mockMvc.perform(get("/api/auth/me")
                        .header("Authorization", "Bearer " + accessToken))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true))
                .andExpect(jsonPath("$.data.email").value("user@novel.com"));
    }

    @Test
    @DisplayName("7. Truy cập endpoint bảo vệ không kèm token trả về 401")
    void testProtectedEndpointWithoutToken() throws Exception {
        mockMvc.perform(get("/api/library/history"))
                .andExpect(status().isUnauthorized());
    }

    @Test
    @DisplayName("8. Khách xem danh sách truyện công khai không cần token")
    void testPublicComicsEndpoint() throws Exception {
        mockMvc.perform(get("/api/comics"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.success").value(true))
                .andExpect(jsonPath("$.data").isArray())
                .andExpect(jsonPath("$.data.length()").value(org.hamcrest.Matchers.greaterThan(0)));
    }
}
