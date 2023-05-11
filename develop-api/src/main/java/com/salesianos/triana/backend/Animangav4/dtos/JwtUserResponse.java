package com.salesianos.triana.backend.Animangav4.dtos;

import com.fasterxml.jackson.annotation.JsonInclude;
import com.salesianos.triana.backend.Animangav4.models.User;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.experimental.SuperBuilder;

@Data
@NoArgsConstructor
@AllArgsConstructor
@SuperBuilder
@JsonInclude(JsonInclude.Include.NON_NULL)
public class JwtUserResponse extends UserResponse {

    private String token;
    private String refreshToken;

    public JwtUserResponse(UserResponse userResponse) {
        id = userResponse.getId();
        username = userResponse.getUsername();
        fullName = userResponse.getFullName();
        email = userResponse.getEmail();
        image = userResponse.getImage();
        createdAt = userResponse.getCreatedAt();

    }

    public static JwtUserResponse of(User user, String token, String refreshToken) {
        JwtUserResponse result = new JwtUserResponse(UserResponse.fromUser(user));
        result.setToken(token);
        result.setRefreshToken(refreshToken);
        return result;

    }

}