package com.flashmind.flashmind.deck;

import com.flashmind.flashmind.flashcard.FlashcardResponse;
import com.flashmind.flashmind.generation.DeckGenerationService;
import com.flashmind.flashmind.security.AuthenticatedUser;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;

@RestController
@RequestMapping("/api/decks")
public class DeckController {

    private final DeckService deckService;
    private final DeckGenerationService deckGenerationService;

    public DeckController(DeckService deckService, DeckGenerationService deckGenerationService) {
        this.deckService = deckService;
        this.deckGenerationService = deckGenerationService;
    }

    @GetMapping
    public List<DeckResponse> listDecks(@AuthenticationPrincipal AuthenticatedUser authenticatedUser) {
        return deckService.listDecks(authenticatedUser.userId());
    }

    @GetMapping("/{id}")
    public DeckResponse getDeck(
            @AuthenticationPrincipal AuthenticatedUser authenticatedUser,
            @PathVariable Long id
    ) {
        return deckService.getDeck(authenticatedUser.userId(), id);
    }

    @GetMapping("/{id}/flashcards")
    public List<FlashcardResponse> getFlashcards(
            @AuthenticationPrincipal AuthenticatedUser authenticatedUser,
            @PathVariable Long id
    ) {
        return deckService.getFlashcards(authenticatedUser.userId(), id);
    }

    @DeleteMapping("/{id}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void deleteDeck(
            @AuthenticationPrincipal AuthenticatedUser authenticatedUser,
            @PathVariable Long id
    ) {
        deckService.deleteDeck(authenticatedUser.userId(), id);
    }

    @PostMapping(path = "/generate", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    @ResponseStatus(HttpStatus.CREATED)
    public DeckResponse generateDeck(
            @AuthenticationPrincipal AuthenticatedUser authenticatedUser,
            @RequestParam MultipartFile file,
            @RequestParam DeckMode mode,
            @RequestParam(required = false) Integer cardCount
    ) {
        return deckGenerationService.generateDeck(authenticatedUser.userId(), file, mode, cardCount);
    }
}
