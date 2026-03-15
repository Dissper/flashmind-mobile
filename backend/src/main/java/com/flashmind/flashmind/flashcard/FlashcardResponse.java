package com.flashmind.flashmind.flashcard;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;

import java.util.List;

public record FlashcardResponse(
        Long id,
        String question,
        String answer,
        List<String> options,
        Integer correctOption,
        FlashcardType type,
        int position
) {

    public static FlashcardResponse fromEntity(FlashcardEntity flashcard, ObjectMapper objectMapper) {
        try {
            List<String> options = flashcard.getOptionsJson() == null || flashcard.getOptionsJson().isBlank()
                    ? List.of()
                    : objectMapper.readValue(flashcard.getOptionsJson(), new TypeReference<>() {
                    });

            return new FlashcardResponse(
                    flashcard.getId(),
                    flashcard.getQuestion(),
                    flashcard.getAnswer(),
                    options,
                    flashcard.getCorrectOption(),
                    flashcard.getType(),
                    flashcard.getPosition()
            );
        } catch (Exception exception) {
            throw new IllegalStateException("Could not deserialize flashcard options.", exception);
        }
    }
}
