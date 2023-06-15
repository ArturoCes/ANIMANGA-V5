package com.salesianos.triana.backend.Animangav4.dtos;

import com.salesianos.triana.backend.Animangav4.models.Manga;
import com.salesianos.triana.backend.Animangav4.models.Volumen;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

import java.util.stream.Collectors;

@Component
@RequiredArgsConstructor
public class VolumenDtoConverter {

    private final CategoryDtoConverter categoryDtoConverter;

    public Volumen createVolumenDtoToVolumen(CreateVolumenDto createVolumenDto, String uri) {
        return Volumen.builder()
                .nombre(createVolumenDto.getNombre())
                .cantidad(createVolumenDto.getCantidad())
                .precio(createVolumenDto.getPrecio())
                .isbn(createVolumenDto.getIsbn())
                .posterPath(uri)
                .build();
    }

    public GetVolumenDto volumenToGetVolumenDto(Volumen v) {
        return GetVolumenDto.builder()
                .id(v.getId())
                .nombre(v.getNombre())
                .cantidad(v.getCantidad())
                .precio(v.getPrecio())
                .isbn(v.getIsbn())
                .posterPath(v.getPosterPath())
                .descriptionManga(v.getManga().getDescription())
                .authorManga(v.getManga().getAuthor())
                .nameManga(v.getManga().getName())
                .idManga(v.getManga().getId())
                .posterPathManga(v.getManga().getPosterPath())
                .releaseDateManga(v.getManga().getReleaseDate())
                .categoriesManga(v.getManga().getCategories().stream()
                        .map(categoryDtoConverter::categoryToCategoryDto).collect(Collectors.toList()))
                .build();
    }
}
