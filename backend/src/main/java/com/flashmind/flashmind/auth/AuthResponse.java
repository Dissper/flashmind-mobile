package com.flashmind.flashmind.auth;

import com.flashmind.flashmind.user.UserResponse;

public record AuthResponse(
        String token,
        UserResponse user
) {
}
