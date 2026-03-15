package com.flashmind.flashmind.auth;

import com.flashmind.flashmind.common.BadRequestException;
import com.flashmind.flashmind.config.AppProperties;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.springframework.stereotype.Component;

@Component
public class AppleIdentityVerifier implements SocialIdentityVerifier {

    private final AppProperties properties;
    private final ObjectMapper objectMapper;

    public AppleIdentityVerifier(AppProperties properties, ObjectMapper objectMapper) {
        this.properties = properties;
        this.objectMapper = objectMapper;
    }

    @Override
    public SocialProvider provider() {
        return SocialProvider.APPLE;
    }

    @Override
    public SocialIdentity verify(String idToken) {
        if (properties.getSocial().isSkipIdTokenValidation()) {
            return SocialIdentitySupport.buildDevelopmentIdentity(
                    objectMapper,
                    idToken,
                    "apple.local",
                    "Apple Dev User"
            );
        }

        // TODO: Validate Apple identity tokens against Apple's JWK set, check
        // audience, issuer, nonce, and expiry, and wire the configured team
        // and key identifiers before production rollout.
        throw new BadRequestException("Apple token validation is not fully configured yet.");
    }
}
