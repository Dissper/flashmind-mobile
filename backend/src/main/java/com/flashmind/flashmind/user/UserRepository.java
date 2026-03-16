package com.flashmind.flashmind.user;

import com.flashmind.flashmind.auth.SocialProvider;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface UserRepository extends JpaRepository<UserEntity, Long> {

    Optional<UserEntity> findByEmail(String email);

    Optional<UserEntity> findByProviderAndProviderUserId(SocialProvider provider, String providerUserId);

    Optional<UserEntity> findByRevenuecatUserId(String revenuecatUserId);
}
