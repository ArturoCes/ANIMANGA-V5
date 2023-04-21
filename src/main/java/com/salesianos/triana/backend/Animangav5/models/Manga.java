package com.salesianos.triana.backend.Animangav5.models;

import lombok.*;
import org.hibernate.annotations.GenericGenerator;
import org.hibernate.annotations.Parameter;
import org.springframework.data.jpa.domain.support.AuditingEntityListener;

import javax.persistence.*;
import java.io.Serializable;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

@EntityListeners(AuditingEntityListener.class)
@Entity
@Getter
@Setter
@AllArgsConstructor
@NoArgsConstructor
@Builder
public class Manga implements Serializable {

    @Id
    @GeneratedValue(generator = "UUID")
    @GenericGenerator(
            name = "UUID",
            strategy = "org.hibernate.id.UUIDGenerator",
            parameters = {
                    @Parameter(
                            name = "uuid_gen_strategy_class",
                            value = "org.hibernate.id.uuid.CustomVersionOneStrategy"

                    )
            }
    )
    @Column(columnDefinition = "uuid")
    private UUID id;

    private String name;

    private String description;

    private LocalDate releaseDate;

    private String posterPath;

    private String author;

    private String publisher;
    @OneToMany(mappedBy = "manga")
    private List<Character> characters;

    @Builder.Default
    @ManyToMany
    @JoinTable(joinColumns = @JoinColumn(name = "manga_id",
            foreignKey = @ForeignKey(name = "FK_CATEGORIES_MANGA")),
            inverseJoinColumns = @JoinColumn(name = "category_id",
                    foreignKey = @ForeignKey(name = "FK_MANGA_CATEGORIES")),
            name = "categories"
    )
    private List<Category> categories = new ArrayList<>();

    @ManyToMany(mappedBy = "wishList", fetch = FetchType.EAGER)
    private List<User> listaDeDeseos;

    public void addCharacter(Character character) {
        characters.add(character);
        character.setManga(this);
    }
}
