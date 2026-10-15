package com.salesianos.triana.backend.Animangav4.config;

import com.salesianos.triana.backend.Animangav4.models.User;
import org.springframework.data.domain.AuditorAware;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;

import java.util.Optional;
import java.util.UUID;

public class AuditorAwareImpl implements AuditorAware<String> {

    @Override
    public Optional<String> getCurrentAuditor() {
        Authentication authentication =
                SecurityContextHolder.getContext().getAuthentication();

        // En peticiones anónimas (registro, login) el principal es un String
        return Optional.ofNullable(authentication)
                .map(Authentication::getPrincipal)
                .filter(User.class::isInstance)
                .map(User.class::cast)
                .map(User::getId)
                .map(UUID::toString);

    }
}
