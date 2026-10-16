package com.salesianos.triana.animanga.cart;

import com.salesianos.triana.animanga.catalog.Volume;
import com.salesianos.triana.animanga.user.User;
import org.springframework.data.jpa.repository.EntityGraph;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface CartItemRepository extends JpaRepository<CartItem, UUID> {

    @EntityGraph(attributePaths = {"volume", "volume.manga"})
    List<CartItem> findByUserOrderByVolumeTitleAsc(User user);

    Optional<CartItem> findByUserAndVolume(User user, Volume volume);

    @Query("select c.volume.id from CartItem c where c.user = :user")
    List<UUID> volumeIdsOf(User user);

    @Modifying
    @Query("delete from CartItem c where c.user = :user")
    void deleteByUser(User user);

    @Modifying
    @Query("delete from CartItem c where c.volume = :volume")
    void deleteByVolume(Volume volume);
}
