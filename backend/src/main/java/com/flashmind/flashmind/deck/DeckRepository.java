package com.flashmind.flashmind.deck;

import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface DeckRepository extends JpaRepository<DeckEntity, Long> {

    List<DeckEntity> findAllByUserIdOrderByCreatedAtDesc(Long userId);

    Optional<DeckEntity> findByIdAndUserId(Long id, Long userId);
}
