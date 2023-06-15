package com.salesianos.triana.backend.Animangav4.repository;

import com.salesianos.triana.backend.Animangav4.models.Cart;
import com.salesianos.triana.backend.Animangav4.models.Item;
import com.salesianos.triana.backend.Animangav4.models.Volumen;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;
import java.util.UUID;

public interface ItemRepository extends JpaRepository<Item, UUID> {
    Optional<Item> findByCartAndVolumen(Cart cart, Volumen volumen);

    Page<Item> findByCartId(UUID cartId, Pageable pageable);
}
