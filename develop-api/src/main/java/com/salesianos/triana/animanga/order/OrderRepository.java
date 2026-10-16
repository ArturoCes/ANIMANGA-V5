package com.salesianos.triana.animanga.order;

import com.salesianos.triana.animanga.catalog.Manga;
import com.salesianos.triana.animanga.user.User;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.EntityGraph;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;

import java.math.BigDecimal;
import java.time.Instant;
import java.util.List;
import java.util.UUID;

public interface OrderRepository extends JpaRepository<Order, UUID>, JpaSpecificationExecutor<Order> {

    @EntityGraph(attributePaths = {"user", "lines"})
    Page<Order> findByUserOrderByCreatedAtDesc(User user, Pageable pageable);

    boolean existsByNumber(String number);

    boolean existsByUser(User user);

    long countByStatus(OrderStatus status);

    @Query("select coalesce(sum(o.total), 0) from Order o where o.status <> com.salesianos.triana.animanga.order.OrderStatus.CANCELLED")
    BigDecimal totalRevenue();

    @Query("select o from Order o where o.status <> com.salesianos.triana.animanga.order.OrderStatus.CANCELLED and o.createdAt >= :from")
    List<Order> findActiveSince(Instant from);

    @EntityGraph(attributePaths = {"user", "lines"})
    List<Order> findTop5ByOrderByCreatedAtDesc();

    /** Unidades vendidas de un manga (pedidos no cancelados). */
    @Query("""
            select coalesce(sum(l.quantity), 0) from OrderLine l
            where l.mangaId = :mangaId and l.order.status <> com.salesianos.triana.animanga.order.OrderStatus.CANCELLED
            """)
    long unitsSoldOfManga(UUID mangaId);

    /** ¿Ha comprado el usuario algún volumen de este manga? (reseña de compra verificada) */
    @Query("""
            select count(l) > 0 from OrderLine l
            where l.order.user = :user and l.mangaId = :mangaId
              and l.order.status <> com.salesianos.triana.animanga.order.OrderStatus.CANCELLED
            """)
    boolean hasPurchased(User user, UUID mangaId);

    @Query("select distinct l.mangaId from OrderLine l where l.order.user = :user and l.mangaId is not null")
    List<UUID> purchasedMangaIds(User user);

    /** Volúmenes más vendidos: [volumeId, título, portada, unidades, ingresos]. */
    @Query("""
            select l.volume.id, l.volumeTitle, l.coverImage, sum(l.quantity), sum(l.unitPrice * l.quantity)
            from OrderLine l
            where l.volume is not null and l.order.status <> com.salesianos.triana.animanga.order.OrderStatus.CANCELLED
            group by l.volume.id, l.volumeTitle, l.coverImage
            order by sum(l.quantity) desc
            """)
    List<Object[]> topVolumes(Pageable pageable);

    @Modifying
    @Query("update OrderLine l set l.volume = null where l.volume.id = :volumeId")
    void detachVolume(UUID volumeId);

    default boolean hasPurchased(User user, Manga manga) {
        return hasPurchased(user, manga.getId());
    }
}
