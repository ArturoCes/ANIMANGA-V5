package com.salesianos.triana.backend.Animangav4.dtos;

import com.salesianos.triana.backend.Animangav4.models.UserRole;
import lombok.*;

@AllArgsConstructor
@NoArgsConstructor
@Getter
@Setter
@Builder


public class SearchUserDto {



        private String username;
        private String fullName;
        private String email;
        private UserRole role;
    }

