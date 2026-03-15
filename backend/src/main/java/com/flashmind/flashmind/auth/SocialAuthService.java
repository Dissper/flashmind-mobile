package com.flashmind.flashmind.auth;

import com.flashmind.flashmind.common.BadRequestException;
import com.flashmind.flashmind.common.ResourceNotFoundException;
import com.flashmind.flashmind.config.AppProperties;
import com.flashmind.flashmind.security.AuthenticatedUser;
import com.flashmind.flashmind.security.JwtTokenService;
import com.flashmind.flashmind.user.UserEntity;
import com.flashmind.flashmind.user.UserRepository;
import com.flashmind.flashmind.user.UserResponse;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.EnumMap;
import java.util.List;
import java.util.Map;

@Service
public class SocialAuthService {

    private final UserRepository userRepository;
    private final JwtTokenService jwtTokenService;
    private final AppProperties properties;
    private final Map<SocialProvider, SocialIdentityVerifier> verifiers;

    public SocialAuthService(
            UserRepository userRepository,
            JwtTokenService jwtTokenService,
            AppProperties properties,
            List<SocialIdentityVerifier> verifiers
    ) {
        this.userRepository = userRepository;
        this.jwtTokenService = jwtTokenService;
        this.properties = properties;
        this.verifiers = new EnumMap<>(SocialProvider.class);
        for (SocialIdentityVerifier verifier : verifiers) {
            this.verifiers.put(verifier.provider(), verifier);
        }
    }

    @Transactional
    public AuthResponse socialLogin(SocialLoginRequest request) {
        SocialIdentityVerifier verifier = verifiers.get(request.provider());
        if (verifier == null) {
            throw new BadRequestException("Unsupported social provider: " + request.provider());
        }

        SocialIdentity identity = verifier.verify(request.idToken());
        UserEntity user = userRepository
                .findByProviderAndProviderUserId(request.provider(), identity.providerUserId())
                .orElseGet(UserEntity::new);

        user.setProvider(request.provider());
        user.setProviderUserId(identity.providerUserId());
        user.setEmail(identity.email());
        user.setDisplayName(identity.displayName());

        UserEntity savedUser = userRepository.save(user);
        String token = jwtTokenService.generateToken(savedUser);
        return new AuthResponse(token, UserResponse.fromEntity(savedUser));
    }

    @Transactional(readOnly = true)
    public UserResponse currentUser(AuthenticatedUser authenticatedUser) {
        UserEntity user = userRepository.findById(authenticatedUser.userId())
                .orElseThrow(() -> new ResourceNotFoundException("User not found."));
        return UserResponse.fromEntity(user);
    }

    @Transactional
    public AuthResponse devLogin() {
        if (!properties.getAuth().isAllowDevLoginBypass()) {
            throw new BadRequestException("Dev login bypass is disabled.");
        }

        String email = properties.getAuth().getDevBypassEmail();
        UserEntity user = userRepository.findByEmail(email).orElseGet(UserEntity::new);
        if (user.getId() == null) {
            user.setProvider(SocialProvider.GOOGLE);
            user.setProviderUserId("dev-bypass-" + Integer.toUnsignedString(email.hashCode()));
        }
        user.setEmail(email);
        user.setDisplayName(properties.getAuth().getDevBypassDisplayName());

        UserEntity savedUser = userRepository.save(user);
        String token = jwtTokenService.generateToken(savedUser);
        return new AuthResponse(token, UserResponse.fromEntity(savedUser));
    }
}
