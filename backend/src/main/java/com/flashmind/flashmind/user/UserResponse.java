package com.flashmind.flashmind.user;

import com.flashmind.flashmind.auth.SocialProvider;

import java.time.OffsetDateTime;

public record UserResponse(
        Long id,
        SocialProvider provider,
        String email,
        String displayName,
        String revenuecatUserId,
        boolean subscriptionActive,
        boolean entitlementActive,
        boolean subscribed,
        int freeGenerationsUsed,
        int freeGenerationsRemaining,
        int maxCardsAllowed,
        OffsetDateTime createdAt,
        OffsetDateTime updatedAt
) {

    public static UserResponse fromEntity(UserEntity user, GenerationAccessResponse access) {
        return new UserResponse(
                user.getId(),
                user.getProvider(),
                user.getEmail(),
                user.getDisplayName(),
                user.getRevenuecatUserId(),
                user.isSubscriptionActive(),
                user.isEntitlementActive(),
                access.subscribed(),
                access.freeGenerationsUsed(),
                access.freeGenerationsRemaining(),
                access.maxCardsAllowed(),
                user.getCreatedAt(),
                user.getUpdatedAt()
        );
    }
}
