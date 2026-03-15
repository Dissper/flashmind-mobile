package com.flashmind.flashmind.auth;

import com.flashmind.flashmind.security.AuthenticatedUser;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/auth")
public class AuthController {

    private final SocialAuthService socialAuthService;

    public AuthController(SocialAuthService socialAuthService) {
        this.socialAuthService = socialAuthService;
    }

    @PostMapping("/social-login")
    @ResponseStatus(HttpStatus.OK)
    public AuthResponse socialLogin(@Valid @RequestBody SocialLoginRequest request) {
        return socialAuthService.socialLogin(request);
    }

    @PostMapping("/dev-login")
    @ResponseStatus(HttpStatus.OK)
    public AuthResponse devLogin() {
        return socialAuthService.devLogin();
    }

    @GetMapping("/me")
    public com.flashmind.flashmind.user.UserResponse me(
            @AuthenticationPrincipal AuthenticatedUser authenticatedUser
    ) {
        return socialAuthService.currentUser(authenticatedUser);
    }
}
