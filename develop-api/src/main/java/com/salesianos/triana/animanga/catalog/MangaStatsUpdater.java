package com.salesianos.triana.animanga.catalog;

import com.salesianos.triana.animanga.order.OrderRepository;
import com.salesianos.triana.animanga.review.ReviewRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

import java.math.BigDecimal;
import java.util.Comparator;

/** Recalcula los datos derivados de un manga: precio "desde", stock, valoración y ventas. */
@Component
@RequiredArgsConstructor
public class MangaStatsUpdater {

    private final ReviewRepository reviews;
    private final OrderRepository orders;

    public void refresh(Manga manga) {
        manga.setMinPrice(manga.getVolumes().stream()
                .map(Volume::getPrice)
                .min(Comparator.naturalOrder())
                .orElse(null));
        manga.setInStock(manga.getVolumes().stream().anyMatch(v -> v.getStock() > 0));
        manga.setRatingCount((int) reviews.countByManga(manga));
        manga.setRatingAverage(manga.getRatingCount() == 0 ? 0 : reviews.averageRating(manga));
        manga.setUnitsSold((int) orders.unitsSoldOfManga(manga.getId()));
    }

    /** Variante ligera tras cambios de stock o precio (no consulta reseñas ni ventas). */
    public void refreshStock(Manga manga) {
        manga.setMinPrice(manga.getVolumes().stream().map(Volume::getPrice)
                .min(Comparator.naturalOrder()).orElse((BigDecimal) null));
        manga.setInStock(manga.getVolumes().stream().anyMatch(v -> v.getStock() > 0));
    }
}
