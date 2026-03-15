package com.flashmind.flashmind.flashcard;

import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface FlashcardRepository extends JpaRepository<FlashcardEntity, Long> {

    List<FlashcardEntity> findAllByDeckIdOrderByPositionAsc(Long deckId);
}
