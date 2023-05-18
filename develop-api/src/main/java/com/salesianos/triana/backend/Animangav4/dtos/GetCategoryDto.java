package com.salesianos.triana.backend.Animangav4.dtos;

import lombok.*;

import java.util.UUID;

@NoArgsConstructor
@AllArgsConstructor
@Getter
@Setter
@Builder
public class GetCategoryDto {


    private UUID id;
    private String name;
    private String description;

}