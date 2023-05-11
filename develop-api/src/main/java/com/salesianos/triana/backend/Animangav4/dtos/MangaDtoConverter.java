package com.salesianos.triana.backend.Animangav4.dtos;

import com.salesianos.triana.backend.Animangav4.models.Manga;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

import java.util.stream.Collectors;

@Component
@RequiredArgsConstructor
public class MangaDtoConverter {
    private final CategoryDtoConverter categoryDtoConverter;

    public Manga createMangaDtoToManga(CreateMangaDto createMangaDto, String uri) {
        return Manga.builder()
                .name(createMangaDto.getName())
                .description(createMangaDto.getDescription())
                .releaseDate(createMangaDto.getReleaseDate())
                .author(createMangaDto.getAuthor())
                .posterPath(uri)
                .build();
    }

    public GetMangaDto mangaToGetMangaDto(Manga m) {
        return GetMangaDto.builder()
                .id(m.getId())
                .name(m.getName())
                .description(m.getDescription())
                .posterPath(m.getPosterPath())
                .releaseDate(m.getReleaseDate())
                .author(m.getAuthor())
                .categories(m.getCategories().stream()
                        .map(categoryDtoConverter::categoryToCategoryDto).collect(Collectors.toList()))
                .build();
    }
}