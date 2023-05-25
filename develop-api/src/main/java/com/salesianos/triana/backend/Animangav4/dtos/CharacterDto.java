package com.salesianos.triana.backend.Animangav4.dtos;

import lombok.*;

@AllArgsConstructor
@NoArgsConstructor
@Getter
@Setter
@Builder
public class CharacterDto {
    private String id;
    private String name;
    private String description;
    private String imageUrl;

}
