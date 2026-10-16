package com.salesianos.triana.animanga.catalog;

import jakarta.persistence.*;
import lombok.*;

import java.math.BigDecimal;
import java.time.Instant;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;
import java.util.UUID;

@Entity
@Table(name = "mangas")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Manga {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @Column(nullable = false, length = 150)
    private String title;

    @Column(length = 100)
    private String author;

    @Column(length = 100)
    private String publisher;

    private LocalDate releaseDate;

    @Column(length = 2000)
    private String synopsis;

    private String coverImage;

    @Builder.Default
    @ManyToMany
    @JoinTable(name = "manga_categories",
            joinColumns = @JoinColumn(name = "manga_id"),
            inverseJoinColumns = @JoinColumn(name = "category_id"))
    private Set<Category> categories = new HashSet<>();

    @Builder.Default
    @OneToMany(mappedBy = "manga", cascade = CascadeType.ALL, orphanRemoval = true)
    @OrderBy("number ASC")
    private List<Volume> volumes = new ArrayList<>();

    @Builder.Default
    @OneToMany(mappedBy = "manga", cascade = CascadeType.ALL, orphanRemoval = true)
    @OrderBy("name ASC")
    private List<MangaCharacter> characters = new ArrayList<>();

    // --- Datos derivados que se recalculan al cambiar volúmenes, reseñas o pedidos.
    //     Permiten filtrar y ordenar el catálogo directamente en SQL.

    /** Precio del volumen más barato ("desde"). */
    private BigDecimal minPrice;

    @Builder.Default
    private double ratingAverage = 0;

    @Builder.Default
    private int ratingCount = 0;

    @Builder.Default
    private int unitsSold = 0;

    @Builder.Default
    private boolean inStock = false;

    private Instant createdAt;

    @PrePersist
    void prePersist() {
        if (createdAt == null) createdAt = Instant.now();
    }

    public void addVolume(Volume volume) {
        volume.setManga(this);
        volumes.add(volume);
    }

    public void addCharacter(MangaCharacter character) {
        character.setManga(this);
        characters.add(character);
    }
}
