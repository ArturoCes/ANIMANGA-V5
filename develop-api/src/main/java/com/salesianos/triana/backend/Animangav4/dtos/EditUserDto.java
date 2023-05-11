package com.salesianos.triana.backend.Animangav4.dtos;

import com.salesianos.triana.backend.Animangav4.validation.annotation.EditEmail;
import lombok.*;

import javax.validation.constraints.Email;
import javax.validation.constraints.NotBlank;

@NoArgsConstructor
@AllArgsConstructor
@Getter
@Setter
@Builder
@EditEmail(
        usernameField = "username",
        emailField = "email",
        message = "{user.unique.email}")
public class EditUserDto {

    private String username;
    private String fullName;
    @NotBlank(message = "{user.email.blank}")
    @Email(message = "{user.email.email}")
    private String email;
}