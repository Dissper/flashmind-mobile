package com.flashmind.flashmind.generation;

import com.flashmind.flashmind.deck.DeckMode;

public record FlashcardGenerationRequest(
        String sourceText,
        DeckMode mode,
        int cardCount,
        String titleHint,
        String language,
        String model
) {
}
