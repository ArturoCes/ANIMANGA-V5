package com.salesianos.triana.backend.Animangav4.repository;

import com.salesianos.triana.backend.Animangav4.models.Character;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.UUID;

public interface CharacterRepository extends JpaRepository<Character, UUID> {
}
