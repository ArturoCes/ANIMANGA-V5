package com.salesianos.triana.animanga.catalog;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.BatchSize;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;
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

    /** Páginas de muestra ("Leer avance"), en orden de lectura. */
    @ElementCollection
    @CollectionTable(name = "volume_preview_pages", joinColumns = @JoinColumn(name = "volume_id"))
    @OrderColumn(name = "position")
    @Column(name = "image", nullable = false)
    @BatchSize(size = 50)
    @Builder.Default
    private List<String> previewPages = new ArrayList<>();

    /** Bloqueo optimista: evita sobrescribir cambios concurrentes del panel. */
    @Version
    private long version;
}
