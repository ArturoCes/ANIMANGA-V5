package com.salesianos.triana.backend.Animangav5.dtos;

import lombok.*;

import java.util.UUID;
@AllArgsConstructor
@NoArgsConstructor
@Getter
@Setter
@Builder
public class CharacterDto {
    private UUID id;

    private String name;

    private Integer age;

    private String description;


}
