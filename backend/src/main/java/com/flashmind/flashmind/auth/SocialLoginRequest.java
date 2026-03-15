package com.flashmind.flashmind.auth;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;

public record SocialLoginRequest(
        @NotNull SocialProvider provider,
        @NotBlank String idToken
) {
}
