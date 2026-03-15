package com.flashmind.flashmind.auth;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;

import java.nio.charset.StandardCharsets;
import java.util.Base64;

final class SocialIdentitySupport {

    private SocialIdentitySupport() {
    }

    static SocialIdentity buildDevelopmentIdentity(
            ObjectMapper objectMapper,
            String idToken,
            String fallbackDomain,
            String fallbackName
    ) {
        String subject = "dev-" + Integer.toUnsignedString(idToken.hashCode());
        String email = subject + "@" + fallbackDomain;
        String displayName = fallbackName;

        try {
            String[] parts = idToken.split("\\.");
            if (parts.length >= 2) {
                String payload = new String(Base64.getUrlDecoder().decode(parts[1]), StandardCharsets.UTF_8);
                JsonNode jsonNode = objectMapper.readTree(payload);
                subject = jsonNode.path("sub").asText(subject);
                email = jsonNode.path("email").asText(email);
                displayName = jsonNode.path("name").asText(displayName);
            }
        } catch (Exception ignored) {
            // The local profile intentionally accepts dev tokens when full
            // provider validation is not configured yet.
        }

        return new SocialIdentity(subject, email, displayName);
    }
}
