package com.salesianos.triana.animanga.catalog;

import jakarta.persistence.criteria.Join;
import jakarta.persistence.criteria.Predicate;
import org.springframework.data.domain.Sort;
import org.springframework.data.jpa.domain.Specification;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;

/** Filtros y ordenaciones del catálogo. */
public final class MangaSpecifications {

    private MangaSpecifications() {}

    public record Filter(String q, String category, String publisher, BigDecimal minPrice,
                         BigDecimal maxPrice, Boolean inStock) {}

    public static Specification<Manga> matching(Filter f) {
        return (root, query, cb) -> {
            List<Predicate> predicates = new ArrayList<>();
            if (f.q() != null && !f.q().isBlank()) {
                String like = "%" + f.q().trim().toLowerCase() + "%";
                predicates.add(cb.or(cb.like(cb.lower(root.get("title")), like),
                        cb.like(cb.lower(root.get("author")), like)));
            }
            if (f.category() != null && !f.category().isBlank()) {
                Join<Manga, Category> categories = root.join("categories");
                predicates.add(cb.equal(cb.lower(categories.get("name")), f.category().trim().toLowerCase()));
                query.distinct(true);
            }
            if (f.publisher() != null && !f.publisher().isBlank()) {
                predicates.add(cb.equal(cb.lower(root.get("publisher")), f.publisher().trim().toLowerCase()));
            }
            if (f.minPrice() != null) predicates.add(cb.greaterThanOrEqualTo(root.get("minPrice"), f.minPrice()));
            if (f.maxPrice() != null) predicates.add(cb.lessThanOrEqualTo(root.get("minPrice"), f.maxPrice()));
            if (Boolean.TRUE.equals(f.inStock())) predicates.add(cb.isTrue(root.get("inStock")));
            return cb.and(predicates.toArray(Predicate[]::new));
        };
    }

    /** Traduce el parámetro {@code sort} de la API a una ordenación de Spring Data. */
    public static Sort sort(String sort) {
        Sort byTitle = Sort.by("title").ascending();
        if (sort == null) return byTitle;
        return switch (sort) {
            case "newest" -> Sort.by(Sort.Order.desc("releaseDate").nullsLast()).and(byTitle);
            case "price_asc" -> Sort.by(Sort.Order.asc("minPrice").nullsLast()).and(byTitle);
            case "price_desc" -> Sort.by(Sort.Order.desc("minPrice").nullsLast()).and(byTitle);
            case "rating" -> Sort.by(Sort.Order.desc("ratingAverage"), Sort.Order.desc("ratingCount")).and(byTitle);
            case "bestselling" -> Sort.by(Sort.Order.desc("unitsSold")).and(byTitle);
            default -> byTitle;
        };
    }
}
