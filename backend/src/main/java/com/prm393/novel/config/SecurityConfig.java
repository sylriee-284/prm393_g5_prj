package com.prm393.novel.config;

import com.prm393.novel.security.JwtAuthenticationEntryPoint;
import com.prm393.novel.security.JwtAuthenticationFilter;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.http.HttpMethod;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.config.Customizer;
import org.springframework.security.config.annotation.authentication.configuration.AuthenticationConfiguration;
import org.springframework.security.config.annotation.method.configuration.EnableMethodSecurity;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.annotation.web.configurers.AbstractHttpConfigurer;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;

@Configuration
@EnableWebSecurity
@EnableMethodSecurity
public class SecurityConfig {

    private final JwtAuthenticationEntryPoint unauthorizedHandler;
    private final JwtAuthenticationFilter jwtAuthenticationFilter;

    public SecurityConfig(JwtAuthenticationEntryPoint unauthorizedHandler,
                          JwtAuthenticationFilter jwtAuthenticationFilter) {
        this.unauthorizedHandler = unauthorizedHandler;
        this.jwtAuthenticationFilter = jwtAuthenticationFilter;
    }

    @Bean
    public PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder();
    }

    @Bean
    public AuthenticationManager authenticationManager(AuthenticationConfiguration authConfig) throws Exception {
        return authConfig.getAuthenticationManager();
    }

    @Bean
    public SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception {
        http
                // Tắt CSRF vì là REST API dùng Token JWT stateless
                .csrf(AbstractHttpConfigurer::disable)
                // Kích hoạt CORS từ CorsConfig
                .cors(Customizer.withDefaults())
                // Trả về 401 khi chưa đăng nhập
                .exceptionHandling(ex -> ex.authenticationEntryPoint(unauthorizedHandler))
                // Phiên làm việc không lưu trạng thái (Stateless)
                .sessionManagement(session -> session.sessionCreationPolicy(SessionCreationPolicy.STATELESS))
                // Quy tắc phân quyền endpoint
                .authorizeHttpRequests(auth -> auth
                        // Các API xác thực (Đăng ký, Đăng nhập, Refresh, Logout, Google Sign-in) cho phép tự do truy cập
                        .requestMatchers("/api/auth/register", "/api/auth/login", "/api/auth/refresh", "/api/auth/logout", "/api/auth/google").permitAll()
                        // Xem danh sách truyện và đọc chương cho phép người dùng khách (Guest)
                        .requestMatchers(HttpMethod.GET, "/api/comics", "/api/comics/**").permitAll()
                        .requestMatchers("/error").permitAll()
                        // Các endpoint cá nhân (tủ truyện, đổi mật khẩu, thông tin profile) bắt buộc phải có Token
                        .anyRequest().authenticated()
                );

        // Đặt JWT Filter chạy trước UsernamePasswordAuthenticationFilter
        http.addFilterBefore(jwtAuthenticationFilter, UsernamePasswordAuthenticationFilter.class);

        return http.build();
    }
}
