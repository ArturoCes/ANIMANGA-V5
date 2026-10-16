package com.salesianos.triana.animanga.catalog;

import jakarta.validation.constraints.*;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;
import java.util.UUID;

/** Objetos de entrada y salida del catálogo. */
public final class CatalogDtos {

    private CatalogDtos() {}

    public record CategoryDto(UUID id, String name, String description) {}

    public record CategoryRef(UUID id, String name) {}

    public record CategoryRequest(
            @NotBlank(message = "El nombre es obligatorio") @Size(max = 60) String name,
            @Size(max = 500) String description) {}

    public record VolumeDto(UUID id, UUID mangaId, String mangaTitle, int number, String title,
                            BigDecimal price, String isbn, int stock, String coverImage,
                            List<String> previewPages) {}

    public record CharacterDto(UUID id, String name, Integer age, String description, String image) {}

    public record MangaSummary(UUID id, String title, String author, String publisher, LocalDate releaseDate,
                               String coverImage, List<CategoryRef> categories, BigDecimal minPrice,
                               double ratingAverage, int ratingCount, int volumeCount, boolean inStock,
                               int unitsSold) {}

    public record MangaDetail(UUID id, String title, String author, String publisher, LocalDate releaseDate,
                              String synopsis, String coverImage, List<CategoryRef> categories,
                              BigDecimal minPrice, double ratingAverage, int ratingCount, boolean inStock,
                              int unitsSold, List<VolumeDto> volumes, List<CharacterDto> characters,
                              boolean favorite, Integer myRating) {}

    public record HomeResponse(List<MangaSummary> latest, List<MangaSummary> bestSellers,
                               List<MangaSummary> topRated, List<MangaSummary> recommended) {}

    public record MangaRequest(
            @NotBlank(message = "El título es obligatorio") @Size(max = 150) String title,
            @Size(max = 100) String author,
            @Size(max = 100) String publisher,
            LocalDate releaseDate,
            @NotBlank(message = "La sinopsis es obligatoria") @Size(max = 2000) String synopsis,
            @NotEmpty(message = "Elige al menos una categoría") List<UUID> categoryIds) {}

    public record VolumeRequest(
            @Min(value = 0, message = "El número de tomo no puede ser negativo") int number,
            @Size(max = 150) String title,
            @NotNull(message = "El precio es obligatorio")
            @DecimalMin(value = "0.0", message = "El precio no puede ser negativo")
            @Digits(integer = 6, fraction = 2) BigDecimal price,
            @Pattern(regexp = "^$|^\\d{10}(\\d{3})?$", message = "El ISBN debe tener 10 o 13 dígitos") String isbn,
            @Min(value = 0, message = "El stock no puede ser negativo") int stock) {}

    public record CharacterRequest(
            @NotBlank(message = "El nombre es obligatorio") @Size(max = 100) String name,
            @Min(0) @Max(10_000) Integer age,
            @Size(max = 500) String description) {}
}
