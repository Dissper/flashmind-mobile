package com.flashmind.flashmind.user;

import com.flashmind.flashmind.auth.SocialProvider;

import java.time.OffsetDateTime;

public record UserResponse(
        Long id,
        SocialProvider provider,
        String email,
        String displayName,
        OffsetDateTime createdAt,
        OffsetDateTime updatedAt
) {

    public static UserResponse fromEntity(UserEntity user) {
        return new UserResponse(
                user.getId(),
                user.getProvider(),
                user.getEmail(),
                user.getDisplayName(),
                user.getCreatedAt(),
                user.getUpdatedAt()
        );
    }
}
