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
import com.flashmind.flashmind.user.GenerationAccessResponse;
import com.flashmind.flashmind.user.GenerationAccessService;
import com.flashmind.flashmind.user.UserEntity;
import com.flashmind.flashmind.user.UserRepository;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashSet;
import java.util.List;
import java.util.Locale;
import java.util.Set;
import java.util.stream.Collectors;

@Service
public class DeckGenerationService {

    private final UserRepository userRepository;
    private final DeckRepository deckRepository;
    private final FlashcardRepository flashcardRepository;
    private final DocumentExtractorService documentExtractorService;
    private final FlashcardGenerationPort flashcardGenerationPort;
    private final ObjectMapper objectMapper;
    private final AppProperties properties;
    private final GenerationAccessService generationAccessService;

    public DeckGenerationService(
            UserRepository userRepository,
            DeckRepository deckRepository,
            FlashcardRepository flashcardRepository,
            DocumentExtractorService documentExtractorService,
            FlashcardGenerationPort flashcardGenerationPort,
            ObjectMapper objectMapper,
            AppProperties properties,
            GenerationAccessService generationAccessService
    ) {
        this.userRepository = userRepository;
        this.deckRepository = deckRepository;
        this.flashcardRepository = flashcardRepository;
        this.documentExtractorService = documentExtractorService;
        this.flashcardGenerationPort = flashcardGenerationPort;
        this.objectMapper = objectMapper;
        this.properties = properties;
        this.generationAccessService = generationAccessService;
    }

    @Transactional
    public DeckResponse generateDeck(Long userId, MultipartFile file, DeckMode mode, Integer requestedCardCount) {
        UserEntity user = userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("User not found."));
        GenerationAccessResponse access = generationAccessService.getGenerationAccess(user);
        if (!access.canGenerate()) {
            throw new BadRequestException("Generation limit reached. Upgrade to premium to continue.");
        }

        int cardCount = normalizeCardCount(requestedCardCount, access.maxCardsAllowed());
        ExtractedDocument extractedDocument = documentExtractorService.extract(file);
        List<FlashcardDraft> generatedCards = flashcardGenerationPort.generate(
                new FlashcardGenerationRequest(
                        extractedDocument.text(),
                        mode,
                        cardCount,
                        extractedDocument.title(),
                        extractedDocument.language(),
                        access.subscribed()
                                ? properties.getGeneration().getOpenaiPremiumModel()
                                : properties.getGeneration().getOpenaiFreeModel()
                )
        );

        List<FlashcardDraft> reviewedCards = filterLowQualityCards(generatedCards);

        if (reviewedCards.isEmpty()) {
            throw new BadRequestException("No flashcards were generated from the document.");
        }

        List<FlashcardDraft> limitedCards = reviewedCards.stream()
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

        if (!access.subscribed()) {
            user.setFreeGenerationsUsed(user.getFreeGenerationsUsed() + 1);
            userRepository.save(user);
        }

        return DeckResponse.fromEntity(savedDeck);
    }

    private int normalizeCardCount(Integer requestedCardCount, int maxCardsAllowed) {
        int effectiveCount = requestedCardCount == null
                ? properties.getGeneration().getDefaultCardCount()
                : requestedCardCount;

        if (effectiveCount < 1) {
            throw new BadRequestException("cardCount must be at least 1.");
        }
        if (effectiveCount > maxCardsAllowed) {
            throw new BadRequestException("cardCount cannot exceed " + maxCardsAllowed + ".");
        }
        if (effectiveCount > properties.getGeneration().getMaxCardCount()) {
            throw new BadRequestException("cardCount cannot exceed " + properties.getGeneration().getMaxCardCount() + ".");
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

    private List<FlashcardDraft> filterLowQualityCards(List<FlashcardDraft> generatedCards) {
        return generatedCards.stream()
                .filter(card -> card.question() != null && !card.question().isBlank())
                .filter(this::hasDistinctQuestionAndAnswer)
                .filter(this::hasDistinctQuestionAndOptions)
                .toList();
    }

    private boolean hasDistinctQuestionAndAnswer(FlashcardDraft card) {
        if (card.answer() == null || card.answer().isBlank()) {
            return true;
        }

        return !isTooSimilar(card.question(), card.answer());
    }

    private boolean hasDistinctQuestionAndOptions(FlashcardDraft card) {
        if (card.options() == null || card.options().isEmpty()) {
            return true;
        }

        return card.options().stream().noneMatch(option -> isTooSimilar(card.question(), option));
    }

    private boolean isTooSimilar(String left, String right) {
        String normalizedLeft = normalizeForComparison(left);
        String normalizedRight = normalizeForComparison(right);

        if (normalizedLeft.isBlank() || normalizedRight.isBlank()) {
            return false;
        }
        if (normalizedLeft.contains(normalizedRight) || normalizedRight.contains(normalizedLeft)) {
            return true;
        }

        Set<String> leftTokens = significantTokens(normalizedLeft);
        Set<String> rightTokens = significantTokens(normalizedRight);
        if (leftTokens.isEmpty() || rightTokens.isEmpty()) {
            return false;
        }

        Set<String> intersection = new HashSet<>(leftTokens);
        intersection.retainAll(rightTokens);

        double overlapBySmaller = (double) intersection.size() / Math.min(leftTokens.size(), rightTokens.size());
        return overlapBySmaller >= 0.75 && intersection.size() >= 3;
    }

    private String normalizeForComparison(String value) {
        return value.toLowerCase(Locale.ROOT)
                .replaceAll("[^\\p{L}\\p{N}\\s]", " ")
                .replaceAll("\\s+", " ")
                .trim();
    }

    private Set<String> significantTokens(String value) {
        return Arrays.stream(value.split(" "))
                .map(String::trim)
                .filter(token -> token.length() >= 4)
                .collect(Collectors.toSet());
    }
}
