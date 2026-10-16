package com.salesianos.triana.animanga.catalog;

import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;

import java.util.Collection;
import java.util.List;
import java.util.UUID;

public interface MangaRepository extends JpaRepository<Manga, UUID>, JpaSpecificationExecutor<Manga> {

    @Query("select distinct m.publisher from Manga m where m.publisher is not null order by m.publisher")
    List<String> findPublishers();

    List<Manga> findAllByCategoriesContains(Category category);

    @Modifying
    @Query(value = "delete from user_favorites where manga_id = :mangaId", nativeQuery = true)
    void deleteFavorites(UUID mangaId);

    /** Mangas de ciertas categorías, excluyendo los indicados, mejor valorados primero. */
    @Query("""
            select distinct m from Manga m join m.categories c
            where c.id in :categoryIds and m.id not in :excluded
            order by m.ratingAverage desc, m.unitsSold desc
            """)
    List<Manga> findRecommended(Collection<UUID> categoryIds, Collection<UUID> excluded, Pageable pageable);
}
