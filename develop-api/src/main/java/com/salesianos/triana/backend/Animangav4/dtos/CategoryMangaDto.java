package com.salesianos.triana.backend.Animangav4.dtos;

import com.salesianos.triana.backend.Animangav4.models.Manga;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

@Data

@Builder
public class CategoryMangaDto {

    private String categoria;

    private List<Manga> mangas;


    public CategoryMangaDto(String categoria, List<Manga> mangas) {
        this.categoria = categoria;
        this.mangas = mangas;
    }
}
