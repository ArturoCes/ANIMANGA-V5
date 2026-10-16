package com.salesianos.triana.animanga.user;

import com.salesianos.triana.animanga.common.ApiException;
import com.salesianos.triana.animanga.config.AppProperties;
import com.salesianos.triana.animanga.mail.MailService;
import com.salesianos.triana.animanga.security.JwtService;
import com.salesianos.triana.animanga.security.LoginAttemptService;
import com.salesianos.triana.animanga.security.Tokens;
import com.salesianos.triana.animanga.user.UserDtos.*;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Duration;
import java.time.Instant;

@Service
@RequiredArgsConstructor
public class AuthService {

    private static final Duration VERIFY_TTL = Duration.ofHours(48);
    private static final Duration RESET_TTL = Duration.ofHours(1);

    private final UserRepository users;
    private final AccountTokenRepository tokens;
    private final PasswordEncoder passwordEncoder;
    private final JwtService jwtService;
    private final LoginAttemptService loginAttempts;
    private final MailService mail;
    private final AppProperties props;

    @Transactional
    public AuthResponse register(RegisterRequest req) {
        if (users.existsByUsernameIgnoreCase(req.username())) {
            throw ApiException.conflict("Ese nombre de usuario ya está en uso");
        }
        if (users.existsByEmailIgnoreCase(req.email())) {
            throw ApiException.conflict("Ya existe una cuenta con ese email");
        }
        User user = users.save(User.builder()
                .username(req.username().trim())
                .fullName(req.fullName().trim())
                .email(req.email().trim().toLowerCase())
                .password(passwordEncoder.encode(req.password()))
                .role(Role.USER)
                .build());
        sendVerification(user);
        return issueTokens(user);
    }

    @Transactional
    public AuthResponse login(LoginRequest req, String ip) {
        loginAttempts.checkAllowed(req.username(), ip);
        User user = users.findByUsernameIgnoreCase(req.username().trim())
                .filter(u -> passwordEncoder.matches(req.password(), u.getPassword()))
                .orElse(null);
        if (user == null) {
            loginAttempts.registerFailure(req.username(), ip);
            // Mismo mensaje exista o no el usuario: no se filtra información
            throw new ApiException(HttpStatus.UNAUTHORIZED, "Usuario o contraseña incorrectos");
        }
        loginAttempts.registerSuccess(req.username(), ip);
        return issueTokens(user);
    }

    /** Cambia un refresh token válido por un par nuevo (rotación: el anterior deja de servir). */
    @Transactional
    public AuthResponse refresh(String refreshToken) {
        AccountToken token = tokens.findByTokenHashAndType(Tokens.sha256(refreshToken), AccountToken.Type.REFRESH)
                .orElseThrow(() -> new ApiException(HttpStatus.UNAUTHORIZED, "La sesión ha caducado"));
        tokens.delete(token);
        if (token.isExpired()) throw new ApiException(HttpStatus.UNAUTHORIZED, "La sesión ha caducado");
        return issueTokens(token.getUser());
    }

    @Transactional
    public void logout(String refreshToken) {
        tokens.findByTokenHashAndType(Tokens.sha256(refreshToken), AccountToken.Type.REFRESH)
                .ifPresent(tokens::delete);
    }

    /** Siempre responde igual, exista o no el email, para no revelar qué cuentas existen. */
    @Transactional
    public void forgotPassword(String email) {
        users.findByEmailIgnoreCase(email.trim()).ifPresent(user -> {
            tokens.deleteByUserAndType(user, AccountToken.Type.RESET_PASSWORD);
            String token = createToken(user, AccountToken.Type.RESET_PASSWORD, RESET_TTL);
            mail.sendPasswordReset(user.getEmail(), user.getFullName(), token);
        });
    }

    @Transactional
    public void resetPassword(ResetPasswordRequest req) {
        AccountToken token = consume(req.token(), AccountToken.Type.RESET_PASSWORD,
                "El enlace para cambiar la contraseña no es válido o ha caducado");
        User user = token.getUser();
        user.setPassword(passwordEncoder.encode(req.password()));
        // Cierra las sesiones abiertas en otros dispositivos
        tokens.deleteByUserAndType(user, AccountToken.Type.REFRESH);
    }

    @Transactional
    public UserDto verifyEmail(String rawToken) {
        AccountToken token = consume(rawToken, AccountToken.Type.VERIFY_EMAIL,
                "El enlace de verificación no es válido o ha caducado");
        token.getUser().setEmailVerified(true);
        return UserDto.from(token.getUser());
    }

    @Transactional
    public void resendVerification(User user) {
        User fresh = users.findById(user.getId()).orElseThrow();
        if (fresh.isEmailVerified()) throw ApiException.badRequest("Tu email ya está verificado");
        sendVerification(fresh);
    }

    void sendVerification(User user) {
        tokens.deleteByUserAndType(user, AccountToken.Type.VERIFY_EMAIL);
        String token = createToken(user, AccountToken.Type.VERIFY_EMAIL, VERIFY_TTL);
        mail.sendVerification(user.getEmail(), user.getFullName(), token);
    }

    private AuthResponse issueTokens(User user) {
        String refresh = createToken(user, AccountToken.Type.REFRESH, Duration.ofDays(props.jwt().refreshDays()));
        return new AuthResponse(jwtService.createAccessToken(user), refresh, jwtService.accessTtlSeconds(),
                UserDto.from(user));
    }

    private String createToken(User user, AccountToken.Type type, Duration ttl) {
        String raw = Tokens.newToken();
        tokens.save(AccountToken.builder()
                .user(user)
                .type(type)
                .tokenHash(Tokens.sha256(raw))
                .expiresAt(Instant.now().plus(ttl))
                .build());
        return raw;
    }

    private AccountToken consume(String raw, AccountToken.Type type, String error) {
        AccountToken token = tokens.findByTokenHashAndType(Tokens.sha256(raw), type)
                .orElseThrow(() -> ApiException.badRequest(error));
        tokens.delete(token);
        if (token.isExpired()) throw ApiException.badRequest(error);
        return token;
    }
}
