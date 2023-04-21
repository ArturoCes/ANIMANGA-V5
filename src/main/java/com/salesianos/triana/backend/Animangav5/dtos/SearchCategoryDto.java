package com.salesianos.triana.backend.Animangav5.dtos;

import lombok.*;

@AllArgsConstructor
@NoArgsConstructor
@Getter
@Setter
@Builder
public class SearchCategoryDto {
    private String name;
    private String description;
}