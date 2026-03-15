package com.flashmind.flashmind.generation;

import com.flashmind.flashmind.common.BadRequestException;
import com.flashmind.flashmind.common.ResourceNotFoundException;
import com.flashmind.flashmind.config.AppProperties;
import com.flashmind.flashmind.deck.DeckEntity;
import com.flashmind.flashmind.deck.DeckMode;
import com.flashmind.flashmind.deck.DeckRepository;
import com.flashmind.flashmind.deck.DeckResponse;
import com.flashmind.flashmind.document.DocumentExtractorService;
import com.flashmind.flashmind.document.ExtractedDocument;
import com.flashmind.flashmind.flashcard.FlashcardEntity;
import com.flashmind.flashmind.flashcard.FlashcardRepository;
import com.flashmind.flashmind.user.UserEntity;
import com.flashmind.flashmind.user.UserRepository;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import java.util.ArrayList;
import java.util.List;

@Service
public class DeckGenerationService {

    private final UserRepository userRepository;
    private final DeckRepository deckRepository;
    private final FlashcardRepository flashcardRepository;
    private final DocumentExtractorService documentExtractorService;
    private final FlashcardGenerationPort flashcardGenerationPort;
    private final ObjectMapper objectMapper;
    private final AppProperties properties;

    public DeckGenerationService(
            UserRepository userRepository,
            DeckRepository deckRepository,
            FlashcardRepository flashcardRepository,
            DocumentExtractorService documentExtractorService,
            FlashcardGenerationPort flashcardGenerationPort,
            ObjectMapper objectMapper,
            AppProperties properties
    ) {
        this.userRepository = userRepository;
        this.deckRepository = deckRepository;
        this.flashcardRepository = flashcardRepository;
        this.documentExtractorService = documentExtractorService;
        this.flashcardGenerationPort = flashcardGenerationPort;
        this.objectMapper = objectMapper;
        this.properties = properties;
    }

    @Transactional
    public DeckResponse generateDeck(Long userId, MultipartFile file, DeckMode mode, Integer requestedCardCount) {
        UserEntity user = userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("User not found."));

        int cardCount = normalizeCardCount(requestedCardCount);
        ExtractedDocument extractedDocument = documentExtractorService.extract(file);
        List<FlashcardDraft> generatedCards = flashcardGenerationPort.generate(
                new FlashcardGenerationRequest(
                        extractedDocument.text(),
                        mode,
                        cardCount,
                        extractedDocument.title()
                )
        );

        if (generatedCards.isEmpty()) {
            throw new BadRequestException("No flashcards were generated from the document.");
        }

        List<FlashcardDraft> limitedCards = generatedCards.stream()
                .limit(properties.getGeneration().getMaxCardCount())
                .toList();

        DeckEntity deck = new DeckEntity();
        deck.setUser(user);
        deck.setTitle(extractedDocument.title());
        deck.setMode(mode);
        deck.setCardCount(limitedCards.size());
        DeckEntity savedDeck = deckRepository.save(deck);

        List<FlashcardEntity> flashcards = new ArrayList<>();
        for (int index = 0; index < limitedCards.size(); index++) {
            FlashcardDraft draft = limitedCards.get(index);
            FlashcardEntity flashcard = new FlashcardEntity();
            flashcard.setDeck(savedDeck);
            flashcard.setQuestion(draft.question());
            flashcard.setAnswer(draft.answer());
            flashcard.setCorrectOption(draft.correctOption());
            flashcard.setType(draft.type());
            flashcard.setPosition(index + 1);
            flashcard.setOptionsJson(serializeOptions(draft.options()));
            flashcards.add(flashcard);
        }
        flashcardRepository.saveAll(flashcards);

        return DeckResponse.fromEntity(savedDeck);
    }

    private int normalizeCardCount(Integer requestedCardCount) {
        int effectiveCount = requestedCardCount == null
                ? properties.getGeneration().getDefaultCardCount()
                : requestedCardCount;

        if (effectiveCount < 1) {
            throw new BadRequestException("cardCount must be at least 1.");
        }
        if (effectiveCount > properties.getGeneration().getMaxCardCount()) {
            throw new BadRequestException("cardCount cannot exceed 20.");
        }
        return effectiveCount;
    }

    private String serializeOptions(List<String> options) {
        try {
            return objectMapper.writeValueAsString(options == null ? List.of() : options);
        } catch (Exception exception) {
            throw new IllegalStateException("Could not serialize flashcard options.", exception);
        }
    }
}
