package com.salesianos.triana.animanga.catalog;

import jakarta.persistence.LockModeType;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Lock;
import org.springframework.data.jpa.repository.Query;

import java.util.Collection;
import java.util.List;
import java.util.UUID;

public interface VolumeRepository extends JpaRepository<Volume, UUID> {

    boolean existsByMangaAndNumber(Manga manga, int number);

    boolean existsByMangaAndNumberAndIdNot(Manga manga, int number, UUID id);

    @Query("select coalesce(sum(v.stock), 0) from Volume v")
    long totalStock();

    @Query("select v from Volume v join fetch v.manga where v.stock <= :threshold order by v.stock asc, v.title asc")
    List<Volume> findLowStock(int threshold);

    /**
     * Bloquea las filas de los volúmenes durante el pago para que dos compras simultáneas
     * no puedan vender la misma última unidad.
     */
    @Lock(LockModeType.PESSIMISTIC_WRITE)
    @Query("select v from Volume v where v.id in :ids order by v.id")
    List<Volume> lockAllByIdIn(Collection<UUID> ids);
}
