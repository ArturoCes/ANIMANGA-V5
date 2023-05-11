package com.salesianos.triana.backend.Animangav4.dtos;


import com.salesianos.triana.backend.Animangav4.models.User;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;
@Component
@RequiredArgsConstructor
public class UserDtoConverter {
    public User createUserDtoToUser(CreateUserDto createUserDto, String uri) {

        return User.builder()
                .fullName(createUserDto.getFullName())
                .image(uri)
                .password(createUserDto.getPassword())
                .username(createUserDto.getUsername())
                .build();
    }

    public GetUserDto userToGetUserDto(User u) {
        return GetUserDto.builder()
                .id(u.getId())
                .username(u.getUsername())
                .createdAt(u.getCreatedAt())
                .fullName(u.getFullName())
                .email(u.getEmail())
                .image(u.getImage())
                .build();
    }

}