package com.salesianos.triana.animanga.catalog;

import jakarta.persistence.*;
import lombok.*;

import java.math.BigDecimal;
import java.util.UUID;

@Entity
@Table(name = "volumes", uniqueConstraints = @UniqueConstraint(columnNames = {"manga_id", "number"}))
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Volume {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @ManyToOne(optional = false, fetch = FetchType.LAZY)
    @JoinColumn(name = "manga_id")
    private Manga manga;

    @Column(nullable = false)
    private int number;

    @Column(nullable = false, length = 150)
    private String title;

    @Column(nullable = false, precision = 8, scale = 2)
    private BigDecimal price;

    @Column(length = 13)
    private String isbn;

    @Column(nullable = false)
    private int stock;

    private String coverImage;

    /** Bloqueo optimista: evita sobrescribir cambios concurrentes del panel. */
    @Version
    private long version;
}
