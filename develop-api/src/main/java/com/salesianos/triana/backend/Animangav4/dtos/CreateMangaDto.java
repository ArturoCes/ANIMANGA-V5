package com.salesianos.triana.backend.Animangav4.dtos;

import com.salesianos.triana.backend.Animangav4.models.Category;
import lombok.*;

import javax.validation.constraints.NotBlank;
import javax.validation.constraints.NotEmpty;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

@AllArgsConstructor
@NoArgsConstructor
@Getter@Setter@Builder
public class CreateMangaDto {

    @NotBlank(message = "{manga.name.blank}")
    private String name;
    @NotBlank(message = "{manga.description.blank}")
    private String description;
    private LocalDate releaseDate;

    private String author;
    @NotEmpty(message = "{manga.category.list.empty}")
    private List<Category> categories = new ArrayList<>();
}
