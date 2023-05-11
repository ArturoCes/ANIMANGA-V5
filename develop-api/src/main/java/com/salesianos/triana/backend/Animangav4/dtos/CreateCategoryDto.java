package com.salesianos.triana.backend.Animangav4.dtos;

import lombok.*;

import javax.validation.constraints.NotBlank;

@AllArgsConstructor
@NoArgsConstructor
@Getter
@Setter
@Builder
public class CreateCategoryDto {


    @NotBlank(message = "{category.name.blank}")
    private String name;
    private String description;
}

