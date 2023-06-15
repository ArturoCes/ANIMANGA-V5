package com.salesianos.triana.backend.Animangav4.repository;

import com.salesianos.triana.backend.Animangav4.dtos.CategoryMangaDto;
import com.salesianos.triana.backend.Animangav4.models.Manga;
import com.salesianos.triana.backend.Animangav4.models.User;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import java.util.List;
import java.util.UUID;

public interface MangaRepository extends JpaRepository<Manga, UUID> {


    Page<Manga> findByUsersMangaFavorite(User user, Pageable pageable);

    boolean existsByIdAndUsersMangaFavorite(UUID id, User user);

    @Query("select m from Manga m JOIN m.categories c WHERE c.name = :name")
    Page<Manga> findByCategoryName(String name, Pageable pageable);

    Page<Manga> findByNameIgnoreCaseContains(String name, Pageable pageable);
}
