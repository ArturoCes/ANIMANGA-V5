package com.salesianos.triana.animanga.config;

import org.springframework.boot.context.properties.ConfigurationProperties;

import java.util.List;

/** Configuración propia de la aplicación (prefijo {@code app.}). */
@ConfigurationProperties(prefix = "app")
public record AppProperties(
        Jwt jwt,
        Login login,
        Cors cors,
        String frontendUrl,
        Mail mail,
        Storage storage,
        Seed seed
) {
    public record Jwt(String secret, int accessMinutes, int refreshDays) {}

    public record Login(int maxAttempts, int blockMinutes) {}

    public record Cors(List<String> allowedOrigins) {}

    public record Mail(String from) {}

    public record Storage(String type, String location) {}

    public record Seed(boolean enabled, String adminPassword, String userPassword) {}
}
