package com.flashmind.flashmind.security;

import com.flashmind.flashmind.config.AppProperties;
import com.flashmind.flashmind.user.UserEntity;
import io.jsonwebtoken.Claims;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.security.Keys;
import org.springframework.stereotype.Service;

import javax.crypto.SecretKey;
import java.nio.charset.StandardCharsets;
import java.time.Instant;
import java.time.temporal.ChronoUnit;
import java.util.Date;

@Service
public class JwtTokenService {

    private final AppProperties properties;

    public JwtTokenService(AppProperties properties) {
        this.properties = properties;
    }

    public String generateToken(UserEntity user) {
        Instant now = Instant.now();
        Instant expiresAt = now.plus(properties.getJwt().getExpirationHours(), ChronoUnit.HOURS);

        return Jwts.builder()
                .subject(user.getId().toString())
                .claim("email", user.getEmail())
                .issuedAt(Date.from(now))
                .expiration(Date.from(expiresAt))
                .signWith(secretKey())
                .compact();
    }

    public AuthenticatedUser parseToken(String token) {
        Claims claims = Jwts.parser()
                .verifyWith(secretKey())
                .build()
                .parseSignedClaims(token)
                .getPayload();

        return new AuthenticatedUser(
                Long.parseLong(claims.getSubject()),
                claims.get("email", String.class)
        );
    }

    private SecretKey secretKey() {
        return Keys.hmacShaKeyFor(properties.getJwt().getSecret().getBytes(StandardCharsets.UTF_8));
    }
}
