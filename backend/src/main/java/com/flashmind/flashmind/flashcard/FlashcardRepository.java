package com.flashmind.flashmind.flashcard;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;

public interface FlashcardRepository extends JpaRepository<FlashcardEntity, Long> {

    List<FlashcardEntity> findAllByDeckIdOrderByPositionAsc(Long deckId);

    @Modifying(flushAutomatically = true, clearAutomatically = true)
    @Query("delete from FlashcardEntity flashcard where flashcard.deck.id = :deckId")
    int deleteByDeckId(@Param("deckId") Long deckId);
}
