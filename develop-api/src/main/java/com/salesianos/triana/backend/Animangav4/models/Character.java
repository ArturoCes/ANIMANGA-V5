package com.salesianos.triana.backend.Animangav4.models;

import lombok.*;
import org.hibernate.annotations.GenericGenerator;
import org.hibernate.annotations.Parameter;
import org.springframework.data.jpa.domain.support.AuditingEntityListener;

import javax.persistence.*;
import java.io.Serializable;
import java.util.UUID;

@EntityListeners(AuditingEntityListener.class)
@Entity
@Getter
@Setter
@AllArgsConstructor
@NoArgsConstructor
@Builder
@Table(name = "characters")
public class Character implements Serializable {

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

    private Integer age;

    private String description;
    @ManyToOne
    @JoinColumn(name = "manga_id", foreignKey = @ForeignKey(name = "FK_CHARACTER_MANGA"))
    private Manga manga;
}
