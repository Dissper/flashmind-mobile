package com.flashmind.flashmind.generation;

import com.flashmind.flashmind.common.BadRequestException;
import com.flashmind.flashmind.common.UpstreamServiceException;
import com.flashmind.flashmind.config.AppProperties;
import com.flashmind.flashmind.deck.DeckMode;
import com.flashmind.flashmind.flashcard.FlashcardType;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.jupiter.api.Test;
import org.springframework.http.HttpMethod;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.test.web.client.MockRestServiceServer;
import org.springframework.web.client.RestClient;

import java.util.List;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.junit.jupiter.api.Assertions.assertTrue;
import static org.springframework.test.web.client.match.MockRestRequestMatchers.method;
import static org.springframework.test.web.client.match.MockRestRequestMatchers.requestTo;
import static org.springframework.test.web.client.response.MockRestResponseCreators.withStatus;
import static org.springframework.test.web.client.response.MockRestResponseCreators.withSuccess;

class OpenAiFlashcardGenerationAdapterTest {

    private final ObjectMapper objectMapper = new ObjectMapper();

    @Test
    void generateReturnsParsedFlashcardsForValidResponse() {
        AppProperties properties = configuredProperties();
        RestClient.Builder builder = RestClient.builder();
        MockRestServiceServer server = MockRestServiceServer.bindTo(builder).build();
        OpenAiFlashcardGenerationAdapter adapter =
                new OpenAiFlashcardGenerationAdapter(properties, objectMapper, builder.build());
        String cardPayload = "{\"cards\":[{\"question\":\"Que organulo realiza la fotosintesis?\",\"answer\":\"El cloroplasto\"}]}";

        server.expect(requestTo("https://api.openai.com/v1/chat/completions"))
                .andExpect(method(HttpMethod.POST))
                .andRespond(withSuccess("""
                        {
                          "choices": [
                            {
                              "message": {
                                "content": %s
                              }
                            }
                          ]
                        }
                        """.formatted(jsonString(cardPayload)), MediaType.APPLICATION_JSON));

        List<FlashcardDraft> cards = adapter.generate(flipRequest());

        assertEquals(1, cards.size());
        assertEquals("Que organulo realiza la fotosintesis?", cards.getFirst().question());
        assertEquals("El cloroplasto", cards.getFirst().answer());
        assertEquals(FlashcardType.FLIP, cards.getFirst().type());
        server.verify();
    }

    @Test
    void generateMapsQuotaErrorsWithoutReturningInternalServerError() {
        AppProperties properties = configuredProperties();
        RestClient.Builder builder = RestClient.builder();
        MockRestServiceServer server = MockRestServiceServer.bindTo(builder).build();
        OpenAiFlashcardGenerationAdapter adapter =
                new OpenAiFlashcardGenerationAdapter(properties, objectMapper, builder.build());

        server.expect(requestTo("https://api.openai.com/v1/chat/completions"))
                .andRespond(withStatus(HttpStatus.TOO_MANY_REQUESTS)
                        .contentType(MediaType.APPLICATION_JSON)
                        .body("""
                                {
                                  "error": {
                                    "message": "You exceeded your current quota, please check your plan and billing details.",
                                    "type": "insufficient_quota",
                                    "code": "insufficient_quota"
                                  }
                                }
                                """));

        UpstreamServiceException exception =
                assertThrows(UpstreamServiceException.class, () -> adapter.generate(flipRequest()));

        assertEquals(HttpStatus.TOO_MANY_REQUESTS, exception.getStatus());
        assertTrue(exception.getMessage().contains("quota is exhausted"));
        server.verify();
    }

    @Test
    void generateFailsFastWhenApiKeyIsMissing() {
        AppProperties properties = configuredProperties();
        properties.getGeneration().setOpenaiApiKey("");
        OpenAiFlashcardGenerationAdapter adapter =
                new OpenAiFlashcardGenerationAdapter(properties, objectMapper, RestClient.builder().build());

        BadRequestException exception =
                assertThrows(BadRequestException.class, () -> adapter.generate(flipRequest()));

        assertEquals("OPENAI_API_KEY is not configured.", exception.getMessage());
    }

    private AppProperties configuredProperties() {
        AppProperties properties = new AppProperties();
        properties.getGeneration().setOpenaiApiKey("test-openai-key");
        properties.getGeneration().setOpenaiBaseUrl("https://api.openai.com");
        return properties;
    }

    private FlashcardGenerationRequest flipRequest() {
        return new FlashcardGenerationRequest(
                "La fotosintesis convierte la energia de la luz en energia quimica.",
                DeckMode.FLIP,
                1,
                "Fotosintesis",
                "Spanish",
                "gpt-4.1"
        );
    }

    private String jsonString(String value) {
        try {
            return objectMapper.writeValueAsString(value);
        } catch (Exception exception) {
            throw new IllegalStateException("Could not serialize the mock OpenAI content payload.", exception);
        }
    }
}
