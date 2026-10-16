package com.salesianos.triana.animanga.security;

import com.salesianos.triana.animanga.common.ApiException;
import com.salesianos.triana.animanga.config.AppProperties;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;

import java.time.Clock;
import java.time.Duration;
import java.time.Instant;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

/**
 * Frena ataques de fuerza bruta: tras N intentos fallidos para el mismo usuario e IP,
 * bloquea el login durante unos minutos. Se guarda en memoria (una sola instancia).
 */
@Service
public class LoginAttemptService {

    private record Attempts(int failures, Instant firstFailure, Instant blockedUntil) {}

    private final Map<String, Attempts> attempts = new ConcurrentHashMap<>();
    private final int maxAttempts;
    private final Duration blockTime;
    private final Clock clock;

    @Autowired
    public LoginAttemptService(AppProperties props) {
        this(props.login().maxAttempts(), Duration.ofMinutes(props.login().blockMinutes()), Clock.systemUTC());
    }

    LoginAttemptService(int maxAttempts, Duration blockTime, Clock clock) {
        this.maxAttempts = maxAttempts;
        this.blockTime = blockTime;
        this.clock = clock;
    }

    public void checkAllowed(String username, String ip) {
        Attempts a = attempts.get(key(username, ip));
        if (a != null && a.blockedUntil() != null && a.blockedUntil().isAfter(clock.instant())) {
            long minutes = Math.max(1, Duration.between(clock.instant(), a.blockedUntil()).toMinutes() + 1);
            throw new ApiException(HttpStatus.TOO_MANY_REQUESTS,
                    "Demasiados intentos fallidos. Inténtalo de nuevo en " + minutes + " min.");
        }
    }

    public void registerFailure(String username, String ip) {
        Instant now = clock.instant();
        attempts.compute(key(username, ip), (k, a) -> {
            if (a == null || a.firstFailure().plus(blockTime).isBefore(now)) {
                a = new Attempts(0, now, null);
            }
            int failures = a.failures() + 1;
            Instant blockedUntil = failures >= maxAttempts ? now.plus(blockTime) : null;
            return new Attempts(failures, a.firstFailure(), blockedUntil);
        });
    }

    public void registerSuccess(String username, String ip) {
        attempts.remove(key(username, ip));
    }

    /** Solo para tests. */
    public void reset() {
        attempts.clear();
    }

    private static String key(String username, String ip) {
        return (username == null ? "" : username.trim().toLowerCase()) + "|" + ip;
    }
}
