package com.salesianos.triana.animanga.user;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;

import java.time.Instant;
import java.util.UUID;

/** Objetos de entrada y salida de usuarios y autenticación. */
public final class UserDtos {

    private UserDtos() {}

    public record UserDto(UUID id, String username, String fullName, String email, String avatar,
                          Role role, boolean emailVerified, Instant createdAt) {
        public static UserDto from(User u) {
            return new UserDto(u.getId(), u.getUsername(), u.getFullName(), u.getEmail(), u.getAvatar(),
                    u.getRole(), u.isEmailVerified(), u.getCreatedAt());
        }
    }

    public record RegisterRequest(
            @NotBlank(message = "El usuario es obligatorio")
            @Size(min = 3, max = 30, message = "El usuario debe tener entre 3 y 30 caracteres")
            @Pattern(regexp = "^[a-zA-Z0-9._-]+$", message = "El usuario solo puede tener letras, números, punto y guion")
            String username,
            @NotBlank(message = "El nombre es obligatorio") @Size(max = 100) String fullName,
            @NotBlank(message = "El email es obligatorio") @Email(message = "El email no es válido") String email,
            @NotBlank(message = "La contraseña es obligatoria")
            @Size(min = 8, max = 100, message = "La contraseña debe tener al menos 8 caracteres")
            String password) {}

    public record LoginRequest(@NotBlank(message = "El usuario es obligatorio") String username,
                               @NotBlank(message = "La contraseña es obligatoria") String password) {}

    public record RefreshRequest(@NotBlank String refreshToken) {}

    public record AuthResponse(String accessToken, String refreshToken, long expiresIn, UserDto user) {}

    public record ForgotPasswordRequest(@NotBlank @Email(message = "El email no es válido") String email) {}

    public record ResetPasswordRequest(
            @NotBlank String token,
            @NotBlank @Size(min = 8, max = 100, message = "La contraseña debe tener al menos 8 caracteres") String password) {}

    public record VerifyEmailRequest(@NotBlank String token) {}

    public record UpdateProfileRequest(
            @NotBlank(message = "El nombre es obligatorio") @Size(max = 100) String fullName,
            @NotBlank(message = "El email es obligatorio") @Email(message = "El email no es válido") String email) {}

    public record ChangePasswordRequest(
            @NotBlank(message = "Introduce tu contraseña actual") String currentPassword,
            @NotBlank @Size(min = 8, max = 100, message = "La nueva contraseña debe tener al menos 8 caracteres")
            String newPassword) {}

    public record RoleRequest(@NotNull(message = "El rol es obligatorio") Role role) {}
}
