package com.flashmind.flashmind.generation;

import com.flashmind.flashmind.common.BadRequestException;
import com.flashmind.flashmind.common.UpstreamServiceException;
import com.flashmind.flashmind.config.AppProperties;
import com.flashmind.flashmind.deck.DeckMode;
import com.flashmind.flashmind.flashcard.FlashcardType;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Component;
import org.springframework.web.client.RestClient;
import org.springframework.web.client.RestClientException;
import org.springframework.web.client.RestClientResponseException;

import java.util.ArrayList;
import java.util.List;
import java.util.Locale;
import java.util.Map;

@Component
public class OpenAiFlashcardGenerationAdapter implements FlashcardGenerationPort {

    private final AppProperties properties;
    private final ObjectMapper objectMapper;
    private final RestClient restClient;

    @Autowired
    public OpenAiFlashcardGenerationAdapter(AppProperties properties, ObjectMapper objectMapper) {
        this(properties, objectMapper, RestClient.builder().build());
    }

    OpenAiFlashcardGenerationAdapter(AppProperties properties, ObjectMapper objectMapper, RestClient restClient) {
        this.properties = properties;
        this.objectMapper = objectMapper;
        this.restClient = restClient;
    }

    @Override
    public List<FlashcardDraft> generate(FlashcardGenerationRequest request) {
        if (!hasConfiguredApiKey()) {
            throw new BadRequestException("OPENAI_API_KEY is not configured.");
        }
        if (request.model() == null || request.model().isBlank()) {
            throw new BadRequestException("OpenAI model is not configured.");
        }

        Map<String, Object> payload = Map.of(
                "model", request.model(),
                "response_format", Map.of("type", "json_object"),
                "messages", List.of(
                        Map.of(
                                "role", "system",
                                "content", """
                                        You generate high-quality study flashcards and return strict JSON only.
                                        The flashcards must test knowledge of the topic itself, not the source file.
                                        Never mention the document, file, text, slide deck, notes, or source material in any question.
                                        Ignore editorial boilerplate, journal headers, website headers, author names, university affiliations, copyright text, citations, and references unless they are genuinely the study topic.
                                        Every question, answer, and option must be written in the same language as the study material.
                                        Do not mix English and Spanish in the same deck unless the source text itself is genuinely bilingual.
                                        Never let the question reveal the full answer text or copy the correct option into the question stem.
                                        Questions must be specific, varied, and useful for studying.
                                        Avoid duplicate or near-duplicate questions.
                                        """
                        ),
                        Map.of(
                                "role", "user",
                                "content", buildPrompt(request)
                        )
                )
        );

        JsonNode response;
        try {
            response = restClient.post()
                    .uri(properties.getGeneration().getOpenaiBaseUrl() + "/v1/chat/completions")
                    .header(HttpHeaders.AUTHORIZATION, "Bearer " + properties.getGeneration().getOpenaiApiKey())
                    .contentType(MediaType.APPLICATION_JSON)
                    .body(payload)
                    .retrieve()
                    .body(JsonNode.class);
        } catch (RestClientResponseException exception) {
            throw mapProviderException(exception);
        } catch (RestClientException exception) {
            throw new UpstreamServiceException(
                    HttpStatus.SERVICE_UNAVAILABLE,
                    "OpenAI is temporarily unavailable. Please try again later."
            );
        }

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

    private boolean hasConfiguredApiKey() {
        String apiKey = properties.getGeneration().getOpenaiApiKey();
        return apiKey != null
                && !apiKey.isBlank()
                && !"replace-me".equalsIgnoreCase(apiKey.trim());
    }

    private RuntimeException mapProviderException(RestClientResponseException exception) {
        String providerMessage = extractProviderMessage(exception.getResponseBodyAsString());
        int status = exception.getStatusCode().value();

        if (status == HttpStatus.TOO_MANY_REQUESTS.value()) {
            String message = providerMessage.toLowerCase(Locale.ROOT).contains("quota")
                    ? "OpenAI quota is exhausted. Configure a billed OPENAI_API_KEY or wait for quota to reset."
                    : "OpenAI rate limit exceeded. Please try again in a moment.";
            return new UpstreamServiceException(HttpStatus.TOO_MANY_REQUESTS, message);
        }
        if (status == HttpStatus.UNAUTHORIZED.value() || status == HttpStatus.FORBIDDEN.value()) {
            return new UpstreamServiceException(
                    HttpStatus.BAD_GATEWAY,
                    "OpenAI credentials are invalid or do not have access to the requested model."
            );
        }
        if (status >= 400 && status < 500) {
            String message = providerMessage.isBlank()
                    ? "OpenAI rejected the flashcard generation request."
                    : "OpenAI rejected the flashcard generation request: " + providerMessage;
            return new UpstreamServiceException(HttpStatus.BAD_GATEWAY, message);
        }

        return new UpstreamServiceException(
                HttpStatus.SERVICE_UNAVAILABLE,
                "OpenAI is temporarily unavailable. Please try again later."
        );
    }

    private String extractProviderMessage(String responseBody) {
        if (responseBody == null || responseBody.isBlank()) {
            return "";
        }

        try {
            JsonNode errorNode = objectMapper.readTree(responseBody).path("error");
            String message = errorNode.path("message").asText("");
            if (!message.isBlank()) {
                return message.trim();
            }
        } catch (Exception ignored) {
            // Fall back to the raw response body when the provider body is not valid JSON.
        }

        return responseBody.replaceAll("\\s+", " ").trim();
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

                Requirements for FLIP cards:
                - Ask about concepts, definitions, mechanisms, examples, comparisons, causes, effects, or relationships from the topic.
                - Questions must be answerable from the source text.
                - Each question must be distinct.
                - Write both the question and the answer in %s.
                - Do not copy the answer into the question.
                - Do not ask generic questions like "What is one key idea from the document?"
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

                Requirements for MULTIPLE_CHOICE cards:
                - Ask about concepts in the topic itself, not about the document.
                - The correct option must be clearly supported by the source text.
                - Distractors must be plausible but clearly wrong.
                - Each question must be distinct.
                - Write the question and all options in %s.
                - Do not copy the correct option into the question stem.
                - Do not ask generic questions like "Which statement best matches the document content?"
                """;

        return """
                Generate %d flashcards for the title "%s".
                Output language: %s
                Mode: %s
                Use only the source text below.
                Keep the cards short, clear, and study-friendly.
                Focus on the subject matter discussed in the text.
                Ask about the topic, not about the existence of the file or document.
                Ignore publisher headers, website navigation text, author affiliations, university names, citation metadata, and references unless the document is actually studying those things.
                Prefer concrete questions about definitions, processes, components, causes, examples, comparisons, formulas, dates, terminology, and relationships found in the text.
                Make the wording natural for a student who is studying the topic.
                Do not repeat the same question stem across cards.
                The deck must stay entirely in %s.
                Do not use phrases such as "according to the document", "in the text", "from the file", or "from the source".
                Do not add explanations outside the JSON.
                %s

                Source text:
                %s
                """.formatted(
                request.cardCount(),
                request.titleHint(),
                request.language(),
                request.mode().name(),
                request.language(),
                modeInstructions,
                request.sourceText()
        );
    }
}
