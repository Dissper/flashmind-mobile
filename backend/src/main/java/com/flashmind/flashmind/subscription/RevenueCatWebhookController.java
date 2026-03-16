package com.flashmind.flashmind.subscription;

import com.fasterxml.jackson.databind.JsonNode;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/subscriptions/revenuecat")
public class RevenueCatWebhookController {

    private final RevenueCatWebhookService revenueCatWebhookService;

    public RevenueCatWebhookController(RevenueCatWebhookService revenueCatWebhookService) {
        this.revenueCatWebhookService = revenueCatWebhookService;
    }

    @PostMapping("/webhook")
    @ResponseStatus(HttpStatus.OK)
    public void handleWebhook(
            @RequestHeader(value = HttpHeaders.AUTHORIZATION, required = false) String authorizationHeader,
            @RequestBody JsonNode payload
    ) {
        revenueCatWebhookService.handleWebhook(authorizationHeader, payload);
    }
}
