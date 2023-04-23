package com.salesianos.triana.backend.Animangav5.dtos;

import com.salesianos.triana.backend.Animangav5.models.Category;
import org.springframework.stereotype.Component;

@Component
public class CategoryDtoConverter {
    public Category createCategoryDtoToCategory(CreateCategoryDto c) {
        return Category.builder().name(c.getName())
                .description(c.getDescription()).build();
    }

    public CreateCategoryDto genreToCreateGenreDto(Category c) {
        return CreateCategoryDto.builder().name(c.getName())
                .description(c.getDescription()).build();
    }

    public GetCategoryDto categoryToCategoryDto(Category c) {
        return GetCategoryDto.builder().id(c.getId()).name(c.getName())
                .description(c.getDescription()).build();
    }

}

