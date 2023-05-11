package com.salesianos.triana.backend.Animangav4.dtos;


import com.salesianos.triana.backend.Animangav4.validation.annotation.PasswordsMatch;
import com.salesianos.triana.backend.Animangav4.validation.annotation.UniqueUsername;
import lombok.*;


import javax.validation.constraints.Email;
import javax.validation.constraints.NotBlank;
import javax.validation.constraints.Size;
import java.time.LocalDateTime;


@AllArgsConstructor
@NoArgsConstructor
@Getter
@Setter
@Builder
@PasswordsMatch(passwordField = "password",
        verifyPasswordField = "verifyPassword",
        message = "{user.password.notmatch}")
public class CreateUserDto {
    @UniqueUsername(message = "{user.unique.username}")
    private String username;
    @Email
    @NotBlank
    private String email;
    @Size(min = 8, message = "{user.password.size}")
    private String password;
    @Size(min = 8, message = "{user.password.size}")
    private String verifyPassword;
    @NotBlank(message = "{user.fullName}")
    private String fullName;

    private String image;

}
