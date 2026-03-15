package com.flashmind.flashmind.config;

import com.flashmind.flashmind.auth.SocialProvider;
import com.flashmind.flashmind.deck.DeckEntity;
import com.flashmind.flashmind.deck.DeckMode;
import com.flashmind.flashmind.deck.DeckRepository;
import com.flashmind.flashmind.flashcard.FlashcardEntity;
import com.flashmind.flashmind.flashcard.FlashcardRepository;
import com.flashmind.flashmind.flashcard.FlashcardType;
import com.flashmind.flashmind.user.UserEntity;
import com.flashmind.flashmind.user.UserRepository;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.springframework.boot.CommandLineRunner;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Profile;

import java.util.List;

@Configuration
@Profile("local")
public class SeedDataConfig {

    @Bean
    CommandLineRunner seedData(
            UserRepository userRepository,
            DeckRepository deckRepository,
            FlashcardRepository flashcardRepository,
            ObjectMapper objectMapper
    ) {
        return args -> {
            if (userRepository.count() > 0 || deckRepository.count() > 0) {
                return;
            }

            UserEntity user = new UserEntity();
            user.setProvider(SocialProvider.GOOGLE);
            user.setProviderUserId("demo-google-user");
            user.setEmail("demo@flashmind.local");
            user.setDisplayName("Demo User");
            UserEntity savedUser = userRepository.save(user);

            DeckEntity flipDeck = new DeckEntity();
            flipDeck.setUser(savedUser);
            flipDeck.setTitle("Biology Notes");
            flipDeck.setMode(DeckMode.FLIP);
            flipDeck.setCardCount(2);
            DeckEntity savedFlipDeck = deckRepository.save(flipDeck);

            DeckEntity quizDeck = new DeckEntity();
            quizDeck.setUser(savedUser);
            quizDeck.setTitle("World History Slides");
            quizDeck.setMode(DeckMode.MULTIPLE_CHOICE);
            quizDeck.setCardCount(2);
            DeckEntity savedQuizDeck = deckRepository.save(quizDeck);

            FlashcardEntity cardOne = new FlashcardEntity();
            cardOne.setDeck(savedFlipDeck);
            cardOne.setQuestion("What is photosynthesis?");
            cardOne.setAnswer("It is the process plants use to convert light into chemical energy.");
            cardOne.setOptionsJson("[]");
            cardOne.setType(FlashcardType.FLIP);
            cardOne.setPosition(1);

            FlashcardEntity cardTwo = new FlashcardEntity();
            cardTwo.setDeck(savedFlipDeck);
            cardTwo.setQuestion("Why is chlorophyll important?");
            cardTwo.setAnswer("It absorbs light energy needed for photosynthesis.");
            cardTwo.setOptionsJson("[]");
            cardTwo.setType(FlashcardType.FLIP);
            cardTwo.setPosition(2);

            FlashcardEntity cardThree = new FlashcardEntity();
            cardThree.setDeck(savedQuizDeck);
            cardThree.setQuestion("Which event began in 1789?");
            cardThree.setAnswer(null);
            cardThree.setOptionsJson(objectMapper.writeValueAsString(List.of(
                    "French Revolution",
                    "Industrial Revolution",
                    "American Civil War",
                    "Congress of Vienna"
            )));
            cardThree.setCorrectOption(0);
            cardThree.setType(FlashcardType.MULTIPLE_CHOICE);
            cardThree.setPosition(1);

            FlashcardEntity cardFour = new FlashcardEntity();
            cardFour.setDeck(savedQuizDeck);
            cardFour.setQuestion("Which empire built Machu Picchu?");
            cardFour.setAnswer(null);
            cardFour.setOptionsJson(objectMapper.writeValueAsString(List.of(
                    "Roman Empire",
                    "Inca Empire",
                    "Ottoman Empire",
                    "Mongol Empire"
            )));
            cardFour.setCorrectOption(1);
            cardFour.setType(FlashcardType.MULTIPLE_CHOICE);
            cardFour.setPosition(2);

            flashcardRepository.saveAll(List.of(cardOne, cardTwo, cardThree, cardFour));
        };
    }
}
