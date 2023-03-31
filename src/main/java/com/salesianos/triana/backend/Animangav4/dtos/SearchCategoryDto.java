package com.salesianos.triana.backend.Animangav4.dtos;

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