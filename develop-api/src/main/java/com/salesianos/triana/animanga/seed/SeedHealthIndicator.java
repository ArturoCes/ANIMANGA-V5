package com.salesianos.triana.animanga.seed;

import org.springframework.boot.health.contributor.Health;
import org.springframework.boot.health.contributor.HealthIndicator;
import org.springframework.stereotype.Component;

import java.util.concurrent.atomic.AtomicBoolean;

/**
 * La API abre el puerto antes de terminar de cargar los datos de ejemplo. Mientras tanto
 * /actuator/health responde DOWN (503), así Render no le manda tráfico y los frontends
 * siguen mostrando "despertando el servidor" en vez de un catálogo vacío.
 */
@Component("seed")
public class SeedHealthIndicator implements HealthIndicator {

    private final AtomicBoolean ready = new AtomicBoolean(false);

    void markReady() {
        ready.set(true);
    }

    @Override
    public Health health() {
        return ready.get()
                ? Health.up().build()
                : Health.down().withDetail("seed", "cargando datos de ejemplo").build();
    }
}
