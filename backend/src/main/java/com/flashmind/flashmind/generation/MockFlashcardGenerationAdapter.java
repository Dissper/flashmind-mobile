package com.flashmind.flashmind.generation;

import com.flashmind.flashmind.deck.DeckMode;
import com.flashmind.flashmind.flashcard.FlashcardType;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.stereotype.Component;

import java.util.ArrayList;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Set;

@Component
@ConditionalOnProperty(name = "flashmind.generation.ai-provider", havingValue = "mock")
public class MockFlashcardGenerationAdapter implements FlashcardGenerationPort {

    @Override
    public List<FlashcardDraft> generate(FlashcardGenerationRequest request) {
        List<String> segments = extractSegments(request.sourceText(), request.cardCount());
        List<FlashcardDraft> cards = new ArrayList<>();

        for (int index = 0; index < request.cardCount(); index++) {
            String segment = segments.get(index % segments.size());
            if (request.mode() == DeckMode.FLIP) {
                cards.add(new FlashcardDraft(
                        "What is one key idea from the document?",
                        segment,
                        List.of(),
                        null,
                        FlashcardType.FLIP
                ));
            } else {
                List<String> options = buildOptions(segments, index, segment);
                int correctOption = options.indexOf(segment);
                cards.add(new FlashcardDraft(
                        "Which statement best matches the document content?",
                        null,
                        options,
                        correctOption,
                        FlashcardType.MULTIPLE_CHOICE
                ));
            }
        }

        return cards;
    }

    private List<String> extractSegments(String text, int cardCount) {
        List<String> segments = text.lines()
                .flatMap(line -> List.of(line.split("[.!?]")).stream())
                .map(String::trim)
                .filter(value -> value.length() >= 24)
                .distinct()
                .limit(Math.max(cardCount + 3L, 6L))
                .toList();

        if (!segments.isEmpty()) {
            return segments;
        }

        String fallback = text.length() > 160 ? text.substring(0, 160) : text;
        return List.of(fallback.trim().isEmpty() ? "FlashMind demo content" : fallback.trim());
    }

    private List<String> buildOptions(List<String> segments, int offset, String correctAnswer) {
        Set<String> options = new LinkedHashSet<>();
        options.add(correctAnswer);

        for (int i = 0; i < segments.size() && options.size() < 4; i++) {
            options.add(segments.get((offset + i + 1) % segments.size()));
        }

        while (options.size() < 4) {
            options.add("Distractor option " + options.size());
        }

        return new ArrayList<>(options);
    }
}
