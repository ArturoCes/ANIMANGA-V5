package com.salesianos.triana.animanga;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.context.properties.ConfigurationPropertiesScan;

@SpringBootApplication
@ConfigurationPropertiesScan
public class AnimangaApplication {

    public static void main(String[] args) {
        SpringApplication.run(AnimangaApplication.class, args);
    }
}
