package com.flashmind.flashmind.user;

import com.flashmind.flashmind.config.AppProperties;
import org.springframework.stereotype.Service;

@Service
public class GenerationAccessService {

    private final AppProperties properties;

    public GenerationAccessService(AppProperties properties) {
        this.properties = properties;
    }

    public GenerationAccessResponse getGenerationAccess(UserEntity user) {
        int freeLimit = properties.getSubscription().getFreeGenerationLimit();
        boolean subscribed = hasPremiumAccess(user);
        int freeUsed = user.getFreeGenerationsUsed();
        int freeRemaining = Math.max(freeLimit - freeUsed, 0);

        return new GenerationAccessResponse(
                subscribed,
                freeUsed,
                freeRemaining,
                subscribed || freeRemaining > 0,
                subscribed
                        ? properties.getSubscription().getPremiumMaxCards()
                        : properties.getSubscription().getFreeMaxCards()
        );
    }

    public boolean hasPremiumAccess(UserEntity user) {
        return user.isEntitlementActive() || user.isSubscriptionActive();
    }
}
