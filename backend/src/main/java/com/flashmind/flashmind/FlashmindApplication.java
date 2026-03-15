package com.flashmind.flashmind;

import com.flashmind.flashmind.config.AppProperties;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.context.properties.EnableConfigurationProperties;

@SpringBootApplication
@EnableConfigurationProperties(AppProperties.class)
public class FlashmindApplication {

    public static void main(String[] args) {
        SpringApplication.run(FlashmindApplication.class, args);
    }
}
