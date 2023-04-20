package com.salesianos.triana.backend.Animangav4.repository;

import com.salesianos.triana.backend.Animangav4.models.Manga;
import com.salesianos.triana.backend.Animangav4.models.User;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.UUID;

public interface MangaRepository extends JpaRepository<Manga, UUID> {


    boolean existsByIdInWishList(UUID id, User user);
}
