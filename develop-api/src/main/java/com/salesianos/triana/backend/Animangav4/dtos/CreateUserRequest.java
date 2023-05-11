package com.salesianos.triana.backend.Animangav4.dtos;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    @Builder
    public class CreateUserRequest {

        private String username;
        private String password;
        private String verifyPassword;
        private String image;
        private String fullName;
        private String email;

    }

