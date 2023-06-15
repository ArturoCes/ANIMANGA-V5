package com.salesianos.triana.backend.Animangav4.dtos;

import lombok.*;

import java.time.LocalDate;
import java.util.List;
import java.util.UUID;

@AllArgsConstructor
@NoArgsConstructor
@Getter
@Setter
@Builder
public class GetVolumenDto {

    private UUID id;
    private UUID idManga;

    private String nombre;

    private Double precio;

    private String isbn;

    private Integer cantidad;

    private String posterPath;

    private String nameManga;
    private String descriptionManga;
    private LocalDate releaseDateManga;
    private String posterPathManga;
    private String authorManga;
    private List<GetCategoryDto> categoriesManga;
}
