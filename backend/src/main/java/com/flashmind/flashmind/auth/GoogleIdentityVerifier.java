package com.flashmind.flashmind.auth;

import com.flashmind.flashmind.common.BadRequestException;
import com.flashmind.flashmind.config.AppProperties;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.springframework.stereotype.Component;

@Component
public class GoogleIdentityVerifier implements SocialIdentityVerifier {

    private final AppProperties properties;
    private final ObjectMapper objectMapper;

    public GoogleIdentityVerifier(AppProperties properties, ObjectMapper objectMapper) {
        this.properties = properties;
        this.objectMapper = objectMapper;
    }

    @Override
    public SocialProvider provider() {
        return SocialProvider.GOOGLE;
    }

    @Override
    public SocialIdentity verify(String idToken) {
        if (properties.getSocial().isSkipIdTokenValidation()) {
            return SocialIdentitySupport.buildDevelopmentIdentity(
                    objectMapper,
                    idToken,
                    "google.local",
                    "Google Dev User"
            );
        }

        // TODO: Perform full Google ID token validation against Google's keys
        // and verify issuer, audience, expiry, and signature using the real
        // configured client ID before production use.
        throw new BadRequestException("Google token validation is not fully configured yet.");
    }
}
