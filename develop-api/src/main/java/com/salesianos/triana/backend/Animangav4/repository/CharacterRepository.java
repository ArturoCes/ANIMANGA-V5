package com.salesianos.triana.backend.Animangav4.repository;

import com.salesianos.triana.backend.Animangav4.models.Character;
import com.salesianos.triana.backend.Animangav4.models.Manga;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;


import java.util.UUID;

public interface CharacterRepository extends JpaRepository<Character, UUID> {

    Page<Character> findByManga(Manga manga, Pageable pageable);

}
