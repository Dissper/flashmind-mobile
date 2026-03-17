package com.flashmind.flashmind.config;

import org.springframework.boot.context.properties.ConfigurationProperties;

@ConfigurationProperties(prefix = "flashmind")
public class AppProperties {

    private final Jwt jwt = new Jwt();
    private final Auth auth = new Auth();
    private final Social social = new Social();
    private final Document document = new Document();
    private final Generation generation = new Generation();
    private final Subscription subscription = new Subscription();

    public Jwt getJwt() {
        return jwt;
    }

    public Auth getAuth() {
        return auth;
    }

    public Social getSocial() {
        return social;
    }

    public Document getDocument() {
        return document;
    }

    public Generation getGeneration() {
        return generation;
    }

    public Subscription getSubscription() {
        return subscription;
    }

    public static class Auth {
        private boolean allowDevLoginBypass;
        private String devBypassEmail = "demo@flashmind.local";
        private String devBypassDisplayName = "Demo User";

        public boolean isAllowDevLoginBypass() {
            return allowDevLoginBypass;
        }

        public void setAllowDevLoginBypass(boolean allowDevLoginBypass) {
            this.allowDevLoginBypass = allowDevLoginBypass;
        }

        public String getDevBypassEmail() {
            return devBypassEmail;
        }

        public void setDevBypassEmail(String devBypassEmail) {
            this.devBypassEmail = devBypassEmail;
        }

        public String getDevBypassDisplayName() {
            return devBypassDisplayName;
        }

        public void setDevBypassDisplayName(String devBypassDisplayName) {
            this.devBypassDisplayName = devBypassDisplayName;
        }
    }

    public static class Jwt {
        private String secret = "replace-with-a-long-secret-for-local-use-only";
        private long expirationHours = 24;

        public String getSecret() {
            return secret;
        }

        public void setSecret(String secret) {
            this.secret = secret;
        }

        public long getExpirationHours() {
            return expirationHours;
        }

        public void setExpirationHours(long expirationHours) {
            this.expirationHours = expirationHours;
        }
    }

    public static class Social {
        private boolean skipIdTokenValidation;
        private String googleClientId = "replace-me";
        private String appleClientId = "replace-me";
        private String appleTeamId = "replace-me";
        private String appleKeyId = "replace-me";

        public boolean isSkipIdTokenValidation() {
            return skipIdTokenValidation;
        }

        public void setSkipIdTokenValidation(boolean skipIdTokenValidation) {
            this.skipIdTokenValidation = skipIdTokenValidation;
        }

        public String getGoogleClientId() {
            return googleClientId;
        }

        public void setGoogleClientId(String googleClientId) {
            this.googleClientId = googleClientId;
        }

        public String getAppleClientId() {
            return appleClientId;
        }

        public void setAppleClientId(String appleClientId) {
            this.appleClientId = appleClientId;
        }

        public String getAppleTeamId() {
            return appleTeamId;
        }

        public void setAppleTeamId(String appleTeamId) {
            this.appleTeamId = appleTeamId;
        }

        public String getAppleKeyId() {
            return appleKeyId;
        }

        public void setAppleKeyId(String appleKeyId) {
            this.appleKeyId = appleKeyId;
        }
    }

    public static class Document {
        private long maxFileSizeBytes = 10 * 1024 * 1024L;
        private int maxPdfPages = 60;
        private int maxPptxSlides = 80;
        private int maxDocxParagraphs = 500;
        private int maxExtractedTextLength = 16_000;

        public long getMaxFileSizeBytes() {
            return maxFileSizeBytes;
        }

        public void setMaxFileSizeBytes(long maxFileSizeBytes) {
            this.maxFileSizeBytes = maxFileSizeBytes;
        }

        public int getMaxPdfPages() {
            return maxPdfPages;
        }

        public void setMaxPdfPages(int maxPdfPages) {
            this.maxPdfPages = maxPdfPages;
        }

        public int getMaxPptxSlides() {
            return maxPptxSlides;
        }

        public void setMaxPptxSlides(int maxPptxSlides) {
            this.maxPptxSlides = maxPptxSlides;
        }

        public int getMaxDocxParagraphs() {
            return maxDocxParagraphs;
        }

        public void setMaxDocxParagraphs(int maxDocxParagraphs) {
            this.maxDocxParagraphs = maxDocxParagraphs;
        }

        public int getMaxExtractedTextLength() {
            return maxExtractedTextLength;
        }

        public void setMaxExtractedTextLength(int maxExtractedTextLength) {
            this.maxExtractedTextLength = maxExtractedTextLength;
        }
    }

    public static class Generation {
        private int maxCardCount = 20;
        private int defaultCardCount = 10;
        private String openaiApiKey = "";
        private String openaiFreeModel = "gpt-4.1";
        private String openaiPremiumModel = "gpt-5.4";
        private String openaiBaseUrl = "https://api.openai.com";

        public int getMaxCardCount() {
            return maxCardCount;
        }

        public void setMaxCardCount(int maxCardCount) {
            this.maxCardCount = maxCardCount;
        }

        public int getDefaultCardCount() {
            return defaultCardCount;
        }

        public void setDefaultCardCount(int defaultCardCount) {
            this.defaultCardCount = defaultCardCount;
        }

        public String getOpenaiApiKey() {
            return openaiApiKey;
        }

        public void setOpenaiApiKey(String openaiApiKey) {
            this.openaiApiKey = openaiApiKey;
        }

        public String getOpenaiFreeModel() {
            return openaiFreeModel;
        }

        public void setOpenaiFreeModel(String openaiFreeModel) {
            this.openaiFreeModel = openaiFreeModel;
        }

        public String getOpenaiPremiumModel() {
            return openaiPremiumModel;
        }

        public void setOpenaiPremiumModel(String openaiPremiumModel) {
            this.openaiPremiumModel = openaiPremiumModel;
        }

        public String getOpenaiBaseUrl() {
            return openaiBaseUrl;
        }

        public void setOpenaiBaseUrl(String openaiBaseUrl) {
            this.openaiBaseUrl = openaiBaseUrl;
        }
    }

    public static class Subscription {
        private int freeGenerationLimit = 3;
        private int freeMaxCards = 10;
        private int premiumMaxCards = 20;
        private String entitlementName = "premium";
        private String productId = "replace-me";
        private String revenuecatApiKey = "";
        private String webhookSecret = "";

        public int getFreeGenerationLimit() {
            return freeGenerationLimit;
        }

        public void setFreeGenerationLimit(int freeGenerationLimit) {
            this.freeGenerationLimit = freeGenerationLimit;
        }

        public int getFreeMaxCards() {
            return freeMaxCards;
        }

        public void setFreeMaxCards(int freeMaxCards) {
            this.freeMaxCards = freeMaxCards;
        }

        public int getPremiumMaxCards() {
            return premiumMaxCards;
        }

        public void setPremiumMaxCards(int premiumMaxCards) {
            this.premiumMaxCards = premiumMaxCards;
        }

        public String getEntitlementName() {
            return entitlementName;
        }

        public void setEntitlementName(String entitlementName) {
            this.entitlementName = entitlementName;
        }

        public String getProductId() {
            return productId;
        }

        public void setProductId(String productId) {
            this.productId = productId;
        }

        public String getRevenuecatApiKey() {
            return revenuecatApiKey;
        }

        public void setRevenuecatApiKey(String revenuecatApiKey) {
            this.revenuecatApiKey = revenuecatApiKey;
        }

        public String getWebhookSecret() {
            return webhookSecret;
        }

        public void setWebhookSecret(String webhookSecret) {
            this.webhookSecret = webhookSecret;
        }
    }
}
