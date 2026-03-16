package com.flashmind.flashmind.user;

import com.flashmind.flashmind.common.ResourceNotFoundException;
import com.flashmind.flashmind.security.AuthenticatedUser;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class UserProfileService {

    private final UserRepository userRepository;
    private final GenerationAccessService generationAccessService;

    public UserProfileService(UserRepository userRepository, GenerationAccessService generationAccessService) {
        this.userRepository = userRepository;
        this.generationAccessService = generationAccessService;
    }

    @Transactional(readOnly = true)
    public UserResponse getCurrentUser(AuthenticatedUser authenticatedUser) {
        UserEntity user = getCurrentUserEntity(authenticatedUser);
        return toResponse(user);
    }

    @Transactional(readOnly = true)
    public GenerationAccessResponse getCurrentGenerationAccess(AuthenticatedUser authenticatedUser) {
        return generationAccessService.getGenerationAccess(getCurrentUserEntity(authenticatedUser));
    }

    public UserResponse toResponse(UserEntity user) {
        return UserResponse.fromEntity(user, generationAccessService.getGenerationAccess(user));
    }

    private UserEntity getCurrentUserEntity(AuthenticatedUser authenticatedUser) {
        return userRepository.findById(authenticatedUser.userId())
                .orElseThrow(() -> new ResourceNotFoundException("User not found."));
    }
}
