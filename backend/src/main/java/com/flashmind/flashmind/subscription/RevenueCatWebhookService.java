package com.flashmind.flashmind.subscription;

import com.fasterxml.jackson.databind.JsonNode;
import com.flashmind.flashmind.config.AppProperties;
import com.flashmind.flashmind.user.UserEntity;
import com.flashmind.flashmind.user.UserRepository;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

import java.time.Instant;
import java.util.Locale;

@Service
public class RevenueCatWebhookService {

    private final UserRepository userRepository;
    private final AppProperties properties;

    public RevenueCatWebhookService(UserRepository userRepository, AppProperties properties) {
        this.userRepository = userRepository;
        this.properties = properties;
    }

    @Transactional
    public void handleWebhook(String authorizationHeader, JsonNode payload) {
        validateAuthorization(authorizationHeader);

        JsonNode event = payload.path("event");
        if (event.isMissingNode()) {
            return;
        }

        String revenueCatUserId = textValue(event, "app_user_id");
        if (revenueCatUserId == null || revenueCatUserId.isBlank()) {
            revenueCatUserId = textValue(event, "original_app_user_id");
        }
        if (revenueCatUserId == null || revenueCatUserId.isBlank()) {
            return;
        }

        UserEntity user = userRepository.findByRevenuecatUserId(revenueCatUserId).orElse(null);
        if (user == null) {
            return;
        }

        if (!matchesConfiguredSubscription(event)) {
            return;
        }

        String eventType = event.path("type").asText("").toUpperCase(Locale.US);
        Long expirationAtMs = longValue(event, "expiration_at_ms");
        boolean entitlementActive = resolveEntitlementActive(eventType, expirationAtMs);
        boolean subscriptionActive = resolveSubscriptionActive(eventType, entitlementActive);

        user.setEntitlementActive(entitlementActive);
        user.setSubscriptionActive(subscriptionActive);
        userRepository.save(user);
    }

    private void validateAuthorization(String authorizationHeader) {
        String configuredSecret = properties.getSubscription().getWebhookSecret();
        if (configuredSecret == null || configuredSecret.isBlank()) {
            return;
        }

        if (configuredSecret.equals(authorizationHeader)
                || ("Bearer " + configuredSecret).equals(authorizationHeader)) {
            return;
        }

        throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "Invalid webhook authorization.");
    }

    private boolean matchesConfiguredSubscription(JsonNode event) {
        String entitlementName = properties.getSubscription().getEntitlementName();
        String productId = properties.getSubscription().getProductId();

        JsonNode entitlementIds = event.path("entitlement_ids");
        if (entitlementIds.isArray()) {
            for (JsonNode entitlementId : entitlementIds) {
                if (entitlementName.equalsIgnoreCase(entitlementId.asText())) {
                    return true;
                }
            }
        }

        return productId != null
                && !productId.isBlank()
                && !productId.equals("replace-me")
                && productId.equalsIgnoreCase(textValue(event, "product_id"));
    }

    private boolean resolveEntitlementActive(String eventType, Long expirationAtMs) {
        return switch (eventType) {
            case "INITIAL_PURCHASE",
                    "RENEWAL",
                    "PRODUCT_CHANGE",
                    "NON_RENEWING_PURCHASE",
                    "UNCANCELLATION",
                    "SUBSCRIPTION_EXTENDED",
                    "TRANSFER" -> hasNotExpired(expirationAtMs);
            case "TEMPORARY_ENTITLEMENT_GRANT" -> true;
            case "CANCELLATION", "BILLING_ISSUE" -> hasNotExpired(expirationAtMs);
            case "EXPIRATION", "REFUND" -> false;
            default -> hasNotExpired(expirationAtMs);
        };
    }

    private boolean resolveSubscriptionActive(String eventType, boolean entitlementActive) {
        return switch (eventType) {
            case "CANCELLATION", "BILLING_ISSUE", "EXPIRATION", "REFUND" -> false;
            case "TEMPORARY_ENTITLEMENT_GRANT" -> false;
            default -> entitlementActive;
        };
    }

    private boolean hasNotExpired(Long expirationAtMs) {
        return expirationAtMs == null || expirationAtMs > Instant.now().toEpochMilli();
    }

    private String textValue(JsonNode node, String fieldName) {
        JsonNode child = node.path(fieldName);
        return child.isMissingNode() || child.isNull() ? null : child.asText();
    }

    private Long longValue(JsonNode node, String fieldName) {
        JsonNode child = node.path(fieldName);
        return child.isMissingNode() || child.isNull() ? null : child.asLong();
    }
}
