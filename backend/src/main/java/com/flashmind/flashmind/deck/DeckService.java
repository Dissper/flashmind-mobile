package com.flashmind.flashmind.deck;

import com.flashmind.flashmind.common.ResourceNotFoundException;
import com.flashmind.flashmind.flashcard.FlashcardEntity;
import com.flashmind.flashmind.flashcard.FlashcardRepository;
import com.flashmind.flashmind.flashcard.FlashcardResponse;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
public class DeckService {

    private final DeckRepository deckRepository;
    private final FlashcardRepository flashcardRepository;
    private final ObjectMapper objectMapper;

    public DeckService(
            DeckRepository deckRepository,
            FlashcardRepository flashcardRepository,
            ObjectMapper objectMapper
    ) {
        this.deckRepository = deckRepository;
        this.flashcardRepository = flashcardRepository;
        this.objectMapper = objectMapper;
    }

    @Transactional(readOnly = true)
    public List<DeckResponse> listDecks(Long userId) {
        return deckRepository.findAllByUserIdOrderByCreatedAtDesc(userId)
                .stream()
                .map(DeckResponse::fromEntity)
                .toList();
    }

    @Transactional(readOnly = true)
    public DeckResponse getDeck(Long userId, Long deckId) {
        DeckEntity deck = findOwnedDeck(userId, deckId);
        return DeckResponse.fromEntity(deck);
    }

    @Transactional(readOnly = true)
    public List<FlashcardResponse> getFlashcards(Long userId, Long deckId) {
        findOwnedDeck(userId, deckId);
        List<FlashcardEntity> flashcards = flashcardRepository.findAllByDeckIdOrderByPositionAsc(deckId);
        return flashcards.stream()
                .map(card -> FlashcardResponse.fromEntity(card, objectMapper))
                .toList();
    }

    public DeckEntity findOwnedDeck(Long userId, Long deckId) {
        return deckRepository.findByIdAndUserId(deckId, userId)
                .orElseThrow(() -> new ResourceNotFoundException("Deck not found."));
    }
}
