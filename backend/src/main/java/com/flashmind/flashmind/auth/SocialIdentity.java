package com.flashmind.flashmind.auth;

public record SocialIdentity(
        String providerUserId,
        String email,
        String displayName
) {
}
