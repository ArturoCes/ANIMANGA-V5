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
public class Volumen implements Serializable {


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


        private String nombre;

        private Double precio;


        private String isbn;

        private Integer cantidad;

        private String posterPath;
        @ManyToOne
        @JoinColumn(name = "manga_id")
        private Manga manga;


        public void addVolumenFromManga(Manga m) {
                manga = m;
                m.getTomos().add(this);
        }

        public void removeVolumenFromManga(Manga m) {
                m.getTomos().remove(this);
                manga = null;
        }

}
