package com.salesianos.triana.animanga.catalog;

import com.salesianos.triana.animanga.catalog.CatalogDtos.*;

import java.util.Comparator;
import java.util.List;

/** Conversión de entidades del catálogo a DTOs (debe llamarse dentro de una transacción). */
public final class CatalogMapper {

    private CatalogMapper() {}

    public static CategoryDto category(Category c) {
        return new CategoryDto(c.getId(), c.getName(), c.getDescription());
    }

    public static VolumeDto volume(Volume v) {
        Manga m = v.getManga();
        return new VolumeDto(v.getId(), m.getId(), m.getTitle(), v.getNumber(), v.getTitle(), v.getPrice(),
                v.getIsbn(), v.getStock(), v.getCoverImage(), List.copyOf(v.getPreviewPages()));
    }

    public static CharacterDto character(MangaCharacter c) {
        return new CharacterDto(c.getId(), c.getName(), c.getAge(), c.getDescription(), c.getImage());
    }

    public static MangaSummary summary(Manga m) {
        return new MangaSummary(m.getId(), m.getTitle(), m.getAuthor(), m.getPublisher(), m.getReleaseDate(),
                m.getCoverImage(), categories(m), m.getMinPrice(), round(m.getRatingAverage()), m.getRatingCount(),
                m.getVolumes().size(), m.isInStock(), m.getUnitsSold());
    }

    public static MangaDetail detail(Manga m, boolean favorite, Integer myRating) {
        return new MangaDetail(m.getId(), m.getTitle(), m.getAuthor(), m.getPublisher(), m.getReleaseDate(),
                m.getSynopsis(), m.getCoverImage(), categories(m), m.getMinPrice(), round(m.getRatingAverage()),
                m.getRatingCount(), m.isInStock(), m.getUnitsSold(),
                m.getVolumes().stream().map(CatalogMapper::volume).toList(),
                m.getCharacters().stream().map(CatalogMapper::character).toList(),
                favorite, myRating);
    }

    private static List<CategoryRef> categories(Manga m) {
        return m.getCategories().stream()
                .sorted(Comparator.comparing(Category::getName))
                .map(c -> new CategoryRef(c.getId(), c.getName()))
                .toList();
    }

    private static double round(double value) {
        return Math.round(value * 10) / 10.0;
    }
}
