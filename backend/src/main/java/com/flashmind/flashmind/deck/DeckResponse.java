package com.flashmind.flashmind.deck;

import java.time.OffsetDateTime;

public record DeckResponse(
        Long id,
        String title,
        DeckMode mode,
        int cardCount,
        OffsetDateTime createdAt
) {

    public static DeckResponse fromEntity(DeckEntity deck) {
        return new DeckResponse(
                deck.getId(),
                deck.getTitle(),
                deck.getMode(),
                deck.getCardCount(),
                deck.getCreatedAt()
        );
    }
}
