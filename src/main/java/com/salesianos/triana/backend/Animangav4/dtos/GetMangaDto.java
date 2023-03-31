package com.salesianos.triana.backend.Animangav4.dtos;

import lombok.*;

import java.time.LocalDate;
import java.util.List;
import java.util.UUID;

@AllArgsConstructor
@NoArgsConstructor
@Builder
@Getter
@Setter
public class GetMangaDto {
    private UUID id;
    private String name;
    private String description;
    private LocalDate releaseDate;
    private String posterPath;
    private String author;
    private List<GetCategoryDto> categories;

}
