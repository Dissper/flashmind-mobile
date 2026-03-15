package com.flashmind.flashmind.generation;

import com.flashmind.flashmind.common.BadRequestException;
import com.flashmind.flashmind.config.AppProperties;
import com.flashmind.flashmind.deck.DeckMode;
import com.flashmind.flashmind.flashcard.FlashcardType;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Component;
import org.springframework.web.client.RestClient;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

@Component
@ConditionalOnProperty(name = "flashmind.generation.ai-provider", havingValue = "openai", matchIfMissing = true)
public class OpenAiFlashcardGenerationAdapter implements FlashcardGenerationPort {

    private final AppProperties properties;
    private final ObjectMapper objectMapper;
    private final RestClient restClient;

    public OpenAiFlashcardGenerationAdapter(AppProperties properties, ObjectMapper objectMapper) {
        this.properties = properties;
        this.objectMapper = objectMapper;
        this.restClient = RestClient.builder().build();
    }

    @Override
    public List<FlashcardDraft> generate(FlashcardGenerationRequest request) {
        if (properties.getGeneration().getOpenaiApiKey() == null
                || properties.getGeneration().getOpenaiApiKey().isBlank()) {
            throw new BadRequestException("OPENAI_API_KEY is not configured.");
        }

        Map<String, Object> payload = Map.of(
                "model", properties.getGeneration().getOpenaiModel(),
                "response_format", Map.of("type", "json_object"),
                "messages", List.of(
                        Map.of(
                                "role", "system",
                                "content", "You generate concise study flashcards and return strict JSON only."
                        ),
                        Map.of(
                                "role", "user",
                                "content", buildPrompt(request)
                        )
                )
        );

        JsonNode response = restClient.post()
                .uri(properties.getGeneration().getOpenaiBaseUrl() + "/v1/chat/completions")
                .header(HttpHeaders.AUTHORIZATION, "Bearer " + properties.getGeneration().getOpenaiApiKey())
                .contentType(MediaType.APPLICATION_JSON)
                .body(payload)
                .retrieve()
                .body(JsonNode.class);

        if (response == null) {
            throw new BadRequestException("AI provider returned an empty response.");
        }

        try {
            String content = response.path("choices").path(0).path("message").path("content").asText();
            JsonNode resultJson = objectMapper.readTree(content);
            JsonNode cardsNode = resultJson.path("cards");
            if (!cardsNode.isArray() || cardsNode.isEmpty()) {
                throw new BadRequestException("AI provider returned no flashcards.");
            }

            List<FlashcardDraft> cards = new ArrayList<>();
            for (JsonNode card : cardsNode) {
                if (request.mode() == DeckMode.FLIP) {
                    cards.add(new FlashcardDraft(
                            card.path("question").asText(),
                            card.path("answer").asText(),
                            List.of(),
                            null,
                            FlashcardType.FLIP
                    ));
                } else {
                    List<String> options = new ArrayList<>();
                    for (JsonNode option : card.path("options")) {
                        options.add(option.asText());
                    }
                    cards.add(new FlashcardDraft(
                            card.path("question").asText(),
                            null,
                            options,
                            card.path("correctOption").asInt(),
                            FlashcardType.MULTIPLE_CHOICE
                    ));
                }
            }
            return cards;
        } catch (BadRequestException exception) {
            throw exception;
        } catch (Exception exception) {
            throw new BadRequestException("AI provider response could not be parsed.");
        }
    }

    private String buildPrompt(FlashcardGenerationRequest request) {
        String modeInstructions = request.mode() == DeckMode.FLIP
                ? """
                Return JSON with this shape:
                {
                  "cards": [
                    { "question": "string", "answer": "string" }
                  ]
                }
                """
                : """
                Return JSON with this shape:
                {
                  "cards": [
                    {
                      "question": "string",
                      "options": ["string", "string", "string", "string"],
                      "correctOption": 0
                    }
                  ]
                }
                """;

        return """
                Generate %d flashcards for the title "%s".
                Mode: %s
                Use only the source text below.
                Keep the cards short, clear, and study-friendly.
                Do not add explanations outside the JSON.
                %s

                Source text:
                %s
                """.formatted(
                request.cardCount(),
                request.titleHint(),
                request.mode().name(),
                modeInstructions,
                request.sourceText()
        );
    }
}
