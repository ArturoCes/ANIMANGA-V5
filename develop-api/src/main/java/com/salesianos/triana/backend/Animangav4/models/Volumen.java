package com.salesianos.triana.backend.Animangav4.models;

import javax.persistence.*;
import java.util.UUID;

@Entity
public class Volumen {


        @Id
        @GeneratedValue
        private UUID id;

        @ManyToOne
        @JoinColumn(name = "manga_id")
        private Manga manga;

        private Integer numero;


        private Double precio;


        private String isbn;

        // getters and setters

}
