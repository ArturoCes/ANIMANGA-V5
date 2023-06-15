package com.salesianos.triana.backend.Animangav4.dtos;

import com.salesianos.triana.backend.Animangav4.models.Manga;
import lombok.*;

import java.util.UUID;

@AllArgsConstructor
@NoArgsConstructor
@Getter
@Setter
@Builder
public class CreateVolumenDto {

    private UUID idManga;
    private String nombre;

    private Double precio;

    private String isbn;

    private Integer cantidad;

    private String posterPath;
}
