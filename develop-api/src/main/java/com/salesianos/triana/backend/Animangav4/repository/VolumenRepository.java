package com.salesianos.triana.backend.Animangav4.repository;

import com.salesianos.triana.backend.Animangav4.models.Volumen;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.UUID;

public interface VolumenRepository  extends JpaRepository<Volumen, UUID> {
}
