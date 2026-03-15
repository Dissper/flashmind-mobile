package com.flashmind.flashmind.generation;

import java.util.List;

public interface FlashcardGenerationPort {

    List<FlashcardDraft> generate(FlashcardGenerationRequest request);
}
