package com.flashmind.flashmind.deck;

import com.flashmind.flashmind.flashcard.FlashcardRepository;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InOrder;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.util.Optional;

import static org.mockito.Mockito.doReturn;
import static org.mockito.Mockito.inOrder;
import static org.mockito.Mockito.spy;
import static org.mockito.Mockito.verifyNoMoreInteractions;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class DeckServiceTest {

    @Mock
    private DeckRepository deckRepository;

    @Mock
    private FlashcardRepository flashcardRepository;

    @Mock
    private ObjectMapper objectMapper;

    @InjectMocks
    private DeckService deckService;

    @Test
    void deleteDeckRemovesFlashcardsBeforeDeletingDeck() {
        DeckEntity deck = spy(new DeckEntity());
        doReturn(10L).when(deck).getId();

        when(deckRepository.findByIdAndUserId(10L, 42L)).thenReturn(Optional.of(deck));

        deckService.deleteDeck(42L, 10L);

        InOrder inOrder = inOrder(flashcardRepository, deckRepository);
        inOrder.verify(flashcardRepository).deleteByDeckId(10L);
        inOrder.verify(deckRepository).delete(deck);
        verifyNoMoreInteractions(flashcardRepository, deckRepository);
    }
}
