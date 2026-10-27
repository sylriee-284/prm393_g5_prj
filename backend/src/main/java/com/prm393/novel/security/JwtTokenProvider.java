package com.prm393.novel.security;

import com.nimbusds.jose.*;
import com.nimbusds.jose.crypto.MACSigner;
import com.nimbusds.jose.crypto.MACVerifier;
import com.nimbusds.jwt.JWTClaimsSet;
import com.nimbusds.jwt.SignedJWT;
import com.prm393.novel.model.User;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

import java.nio.charset.StandardCharsets;
import java.text.ParseException;
import java.util.Date;
import java.util.UUID;

@Component
public class JwtTokenProvider {

    private static final Logger logger = LoggerFactory.getLogger(JwtTokenProvider.class);

    @Value("${app.jwt.secret}")
    private String jwtSecret;

    @Value("${app.jwt.access-token-expiration-ms}")
    private long accessTokenExpirationMs;

    @Value("${app.jwt.refresh-token-expiration-ms}")
    private long refreshTokenExpirationMs;

    public String generateAccessToken(User user) {
        Date now = new Date();
        Date expiryDate = new Date(now.getTime() + accessTokenExpirationMs);

        try {
            JWSSigner signer = new MACSigner(jwtSecret.getBytes(StandardCharsets.UTF_8));

            JWTClaimsSet claimsSet = new JWTClaimsSet.Builder()
                    .subject(user.getEmail())
                    .claim("userId", user.getId())
                    .claim("fullName", user.getFullName())
                    .claim("role", user.getRole().name())
                    .issueTime(now)
                    .expirationTime(expiryDate)
                    .jwtID(UUID.randomUUID().toString())
                    .build();

            SignedJWT signedJWT = new SignedJWT(
                    new JWSHeader(JWSAlgorithm.HS256),
                    claimsSet
            );

            signedJWT.sign(signer);
            return signedJWT.serialize();
        } catch (JOSEException e) {
            logger.error("Không thể tạo JWT access token: {}", e.getMessage());
            throw new RuntimeException("Lỗi sinh JWT token", e);
        }
    }

    public String generateRefreshTokenString() {
        return UUID.randomUUID().toString().replace("-", "") + UUID.randomUUID().toString().replace("-", "");
    }

    public long getAccessTokenExpirationMs() {
        return accessTokenExpirationMs;
    }

    public long getRefreshTokenExpirationMs() {
        return refreshTokenExpirationMs;
    }

    public String getEmailFromToken(String token) {
        try {
            SignedJWT signedJWT = SignedJWT.parse(token);
            return signedJWT.getJWTClaimsSet().getSubject();
        } catch (ParseException e) {
            logger.error("Không thể đọc email từ token: {}", e.getMessage());
            return null;
        }
    }

    public boolean validateToken(String token) {
        try {
            SignedJWT signedJWT = SignedJWT.parse(token);
            JWSVerifier verifier = new MACVerifier(jwtSecret.getBytes(StandardCharsets.UTF_8));

            if (!signedJWT.verify(verifier)) {
                logger.warn("Chữ ký JWT không hợp lệ");
                return false;
            }

            Date expiration = signedJWT.getJWTClaimsSet().getExpirationTime();
            if (expiration == null || expiration.before(new Date())) {
                logger.warn("JWT token đã hết hạn");
                return false;
            }

            return true;
        } catch (ParseException e) {
            logger.warn("Định dạng JWT token không hợp lệ: {}", e.getMessage());
        } catch (JOSEException e) {
            logger.warn("Lỗi kiểm tra chữ ký JWT: {}", e.getMessage());
        }
        return false;
    }
}
