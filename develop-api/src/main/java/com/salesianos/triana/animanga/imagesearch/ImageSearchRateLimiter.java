package com.salesianos.triana.animanga.imagesearch;

import com.salesianos.triana.animanga.common.ApiException;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Component;

import java.time.Clock;
import java.time.Duration;
import java.time.Instant;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

/** La búsqueda por imagen es pública y cuesta CPU: se limita a unas pocas por minuto y por IP. */
@Component
public class ImageSearchRateLimiter {

    static final int MAX_PER_WINDOW = 10;
    private static final Duration WINDOW = Duration.ofMinutes(1);

    private record Window(Instant start, int count) {}

    private final Map<String, Window> windows = new ConcurrentHashMap<>();
    private final Clock clock = Clock.systemUTC();

    public void check(String ip) {
        Instant now = clock.instant();
        Window w = windows.compute(ip, (key, current) ->
                current == null || current.start().plus(WINDOW).isBefore(now)
                        ? new Window(now, 1)
                        : new Window(current.start(), current.count() + 1));
        if (w.count() > MAX_PER_WINDOW) {
            throw new ApiException(HttpStatus.TOO_MANY_REQUESTS, "Demasiadas búsquedas seguidas. Espera un minuto.");
        }
        if (windows.size() > 10_000) windows.entrySet().removeIf(e -> e.getValue().start().plus(WINDOW).isBefore(now));
    }

    /** Para los tests. */
    public void reset() {
        windows.clear();
    }
}
