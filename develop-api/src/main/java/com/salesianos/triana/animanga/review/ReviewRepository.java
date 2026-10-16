package com.salesianos.triana.animanga.review;

import com.salesianos.triana.animanga.catalog.Manga;
import com.salesianos.triana.animanga.user.User;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.EntityGraph;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;

import java.util.Optional;
import java.util.UUID;

public interface ReviewRepository extends JpaRepository<Review, UUID> {

    @EntityGraph(attributePaths = "user")
    Page<Review> findByMangaOrderByCreatedAtDesc(Manga manga, Pageable pageable);

    Optional<Review> findByUserAndManga(User user, Manga manga);

    @Query("select coalesce(avg(r.rating), 0) from Review r where r.manga = :manga")
    double averageRating(Manga manga);

    long countByManga(Manga manga);

    @Modifying
    @Query("delete from Review r where r.manga = :manga")
    void deleteByManga(Manga manga);

    @Modifying
    @Query("delete from Review r where r.user = :user")
    void deleteByUser(User user);
}
