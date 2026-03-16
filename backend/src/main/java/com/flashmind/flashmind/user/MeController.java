package com.flashmind.flashmind.user;

import com.flashmind.flashmind.security.AuthenticatedUser;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/me")
public class MeController {

    private final UserProfileService userProfileService;

    public MeController(UserProfileService userProfileService) {
        this.userProfileService = userProfileService;
    }

    @GetMapping
    public UserResponse me(@AuthenticationPrincipal AuthenticatedUser authenticatedUser) {
        return userProfileService.getCurrentUser(authenticatedUser);
    }

    @GetMapping("/generation-access")
    public GenerationAccessResponse generationAccess(
            @AuthenticationPrincipal AuthenticatedUser authenticatedUser
    ) {
        return userProfileService.getCurrentGenerationAccess(authenticatedUser);
    }
}
