package com.flashmind.flashmind.generation;

import com.flashmind.flashmind.deck.DeckMode;
import com.flashmind.flashmind.flashcard.FlashcardType;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.stereotype.Component;

import java.util.ArrayList;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Locale;
import java.util.Set;

@Component
@ConditionalOnProperty(name = "flashmind.generation.ai-provider", havingValue = "mock")
public class MockFlashcardGenerationAdapter implements FlashcardGenerationPort {

    private static final String[] FLIP_QUESTION_TEMPLATES = {
            "What does %s refer to?",
            "How would you explain %s?",
            "What is important about %s?",
            "What should a student know about %s?"
    };

    private static final String[] MULTIPLE_CHOICE_TEMPLATES = {
            "Which statement about %s is correct?",
            "Which option best describes %s?",
            "What is true about %s?",
            "Which idea correctly matches %s?"
    };

    private static final String[] FLIP_QUESTION_TEMPLATES_ES = {
            "¿A qué se refiere %s?",
            "¿Cómo explicarías %s?",
            "¿Qué es importante sobre %s?",
            "¿Qué debe saber un estudiante sobre %s?"
    };

    private static final String[] MULTIPLE_CHOICE_TEMPLATES_ES = {
            "¿Qué afirmación sobre %s es correcta?",
            "¿Qué opción describe mejor %s?",
            "¿Qué es verdadero sobre %s?",
            "¿Qué idea corresponde correctamente a %s?"
    };

    @Override
    public List<FlashcardDraft> generate(FlashcardGenerationRequest request) {
        List<String> segments = extractSegments(request.sourceText(), request.cardCount());
        List<FlashcardDraft> cards = new ArrayList<>();

        for (int index = 0; index < request.cardCount(); index++) {
            String segment = segments.get(index % segments.size());
            String topicPrompt = buildTopicPrompt(segment);
            boolean spanish = isSpanish(request.language());
            if (request.mode() == DeckMode.FLIP) {
                cards.add(new FlashcardDraft(
                        questionTemplate(spanish, true, index).formatted(topicPrompt),
                        segment,
                        List.of(),
                        null,
                        FlashcardType.FLIP
                ));
            } else {
                List<String> options = buildOptions(segments, index, segment);
                int correctOption = options.indexOf(segment);
                cards.add(new FlashcardDraft(
                        questionTemplate(spanish, false, index).formatted(topicPrompt),
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
                .filter(this::isStudySegment)
                .distinct()
                .limit(Math.max(cardCount + 3L, 6L))
                .toList();

        if (!segments.isEmpty()) {
            return segments;
        }

        String fallback = text.length() > 160 ? text.substring(0, 160) : text;
        return List.of(fallback.trim().isEmpty() ? "FlashMind demo content" : fallback.trim());
    }

    private String questionTemplate(boolean spanish, boolean flip, int index) {
        if (spanish) {
            return flip
                    ? FLIP_QUESTION_TEMPLATES_ES[index % FLIP_QUESTION_TEMPLATES_ES.length]
                    : MULTIPLE_CHOICE_TEMPLATES_ES[index % MULTIPLE_CHOICE_TEMPLATES_ES.length];
        }

        return flip
                ? FLIP_QUESTION_TEMPLATES[index % FLIP_QUESTION_TEMPLATES.length]
                : MULTIPLE_CHOICE_TEMPLATES[index % MULTIPLE_CHOICE_TEMPLATES.length];
    }

    private boolean isStudySegment(String segment) {
        String normalized = segment.toLowerCase(Locale.ROOT);
        return !normalized.contains("contents lists available")
                && !normalized.contains("sciencedirect")
                && !normalized.contains("journal homepage")
                && !normalized.contains("corresponding author")
                && !normalized.contains("university")
                && !normalized.contains("department of")
                && !normalized.contains("doi")
                && !normalized.startsWith("references");
    }

    private String buildTopicPrompt(String segment) {
        String cleaned = segment
                .replaceAll("\\s+", " ")
                .replaceAll("[\"'`]", "")
                .trim();

        String[] words = cleaned.split(" ");
        int wordCount = Math.min(words.length, 7);
        String prompt = String.join(" ", List.of(words).subList(0, wordCount))
                .replaceAll("[,:;]+$", "")
                .trim();

        if (prompt.length() < 8) {
            return "this topic";
        }

        return prompt;
    }

    private boolean isSpanish(String language) {
        return language != null && language.equalsIgnoreCase("Spanish");
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
