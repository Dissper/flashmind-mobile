package com.flashmind.flashmind.user;

public record GenerationAccessResponse(
        boolean subscribed,
        int freeGenerationsUsed,
        int freeGenerationsRemaining,
        boolean canGenerate,
        int maxCardsAllowed
) {
}
