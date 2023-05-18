package com.salesianos.triana.backend.Animangav4.dtos;

import lombok.*;

import java.time.LocalDateTime;
import java.util.UUID;

@AllArgsConstructor
@NoArgsConstructor
@Builder
@Getter
@Setter
public class GetUserDto {

    private UUID id;
    private String username;
    private String email;

    private String image;

    private String fullName;

    private LocalDateTime createdAt;
}
