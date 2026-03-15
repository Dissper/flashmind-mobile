package com.flashmind.flashmind.auth;

public interface SocialIdentityVerifier {

    SocialProvider provider();

    SocialIdentity verify(String idToken);
}
