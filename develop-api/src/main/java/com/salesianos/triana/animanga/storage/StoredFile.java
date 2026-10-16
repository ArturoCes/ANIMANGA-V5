package com.salesianos.triana.animanga.storage;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import lombok.*;

/** Imagen guardada en la base de datos (perfil de producción). */
@Entity
@Table(name = "stored_files")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class StoredFile {

    @Id
    @Column(length = 130)
    private String name;

    @Column(nullable = false, length = 50)
    private String contentType;

    @Column(nullable = false, length = 6_000_000)
    private byte[] data;
}
