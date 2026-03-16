package com.flashmind.flashmind.user;

import com.flashmind.flashmind.auth.SocialProvider;
import com.flashmind.flashmind.common.AuditableEntity;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import jakarta.persistence.UniqueConstraint;

@Entity
@Table(
        name = "users",
        uniqueConstraints = {
                @UniqueConstraint(name = "uk_user_provider_subject", columnNames = {"provider", "provider_user_id"})
        }
)
public class UserEntity extends AuditableEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 32)
    private SocialProvider provider;

    @Column(name = "provider_user_id", nullable = false, length = 255)
    private String providerUserId;

    @Column(nullable = false, length = 255)
    private String email;

    @Column(nullable = false, length = 255)
    private String displayName;

    @Column(name = "free_generations_used", nullable = false, columnDefinition = "integer default 0")
    private int freeGenerationsUsed = 0;

    @Column(name = "subscription_active", nullable = false, columnDefinition = "boolean default false")
    private boolean subscriptionActive = false;

    @Column(name = "entitlement_active", nullable = false, columnDefinition = "boolean default false")
    private boolean entitlementActive = false;

    @Column(name = "revenuecat_user_id", length = 255)
    private String revenuecatUserId;

    public Long getId() {
        return id;
    }

    public SocialProvider getProvider() {
        return provider;
    }

    public void setProvider(SocialProvider provider) {
        this.provider = provider;
    }

    public String getProviderUserId() {
        return providerUserId;
    }

    public void setProviderUserId(String providerUserId) {
        this.providerUserId = providerUserId;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getDisplayName() {
        return displayName;
    }

    public void setDisplayName(String displayName) {
        this.displayName = displayName;
    }

    public int getFreeGenerationsUsed() {
        return freeGenerationsUsed;
    }

    public void setFreeGenerationsUsed(int freeGenerationsUsed) {
        this.freeGenerationsUsed = freeGenerationsUsed;
    }

    public boolean isSubscriptionActive() {
        return subscriptionActive;
    }

    public void setSubscriptionActive(boolean subscriptionActive) {
        this.subscriptionActive = subscriptionActive;
    }

    public boolean isEntitlementActive() {
        return entitlementActive;
    }

    public void setEntitlementActive(boolean entitlementActive) {
        this.entitlementActive = entitlementActive;
    }

    public String getRevenuecatUserId() {
        return revenuecatUserId;
    }

    public void setRevenuecatUserId(String revenuecatUserId) {
        this.revenuecatUserId = revenuecatUserId;
    }
}
