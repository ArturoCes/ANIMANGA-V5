package com.salesianos.triana.animanga.security;

import com.salesianos.triana.animanga.common.ApiError;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.security.web.AuthenticationEntryPoint;
import org.springframework.security.web.access.AccessDeniedHandler;
import org.springframework.stereotype.Component;
import tools.jackson.databind.json.JsonMapper;

import java.io.IOException;

/** Respuestas 401/403 de Spring Security con el mismo formato JSON que el resto de errores. */
@Component
@RequiredArgsConstructor
public class JsonSecurityHandlers {

    private final JsonMapper jsonMapper;

    public AuthenticationEntryPoint entryPoint() {
        return (req, res, ex) -> write(req, res, HttpStatus.UNAUTHORIZED,
                "Necesitas iniciar sesión (o tu sesión ha caducado)");
    }

    public AccessDeniedHandler accessDenied() {
        return (req, res, ex) -> write(req, res, HttpStatus.FORBIDDEN,
                "No tienes permisos para realizar esta acción");
    }

    private void write(HttpServletRequest req, HttpServletResponse res, HttpStatus status, String message)
            throws IOException {
        res.setStatus(status.value());
        res.setContentType(MediaType.APPLICATION_JSON_VALUE);
        res.setCharacterEncoding("UTF-8");
        if (status == HttpStatus.UNAUTHORIZED) res.setHeader("WWW-Authenticate", "Bearer");
        jsonMapper.writeValue(res.getOutputStream(),
                ApiError.of(status.value(), status.getReasonPhrase(), message, req.getRequestURI()));
    }
}
