package com.salesianos.triana.animanga.catalog;

import org.springframework.data.jpa.repository.JpaRepository;

import java.util.UUID;

public interface CharacterRepository extends JpaRepository<MangaCharacter, UUID> {
}
