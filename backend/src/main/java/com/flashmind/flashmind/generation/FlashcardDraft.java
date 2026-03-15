package com.flashmind.flashmind.generation;

import com.flashmind.flashmind.flashcard.FlashcardType;

import java.util.List;

public record FlashcardDraft(
        String question,
        String answer,
        List<String> options,
        Integer correctOption,
        FlashcardType type
) {
}
