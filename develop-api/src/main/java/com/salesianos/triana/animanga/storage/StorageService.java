package com.salesianos.triana.animanga.storage;

import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.io.UncheckedIOException;
import java.util.Optional;

/** Almacén de imágenes. Los ficheros se identifican por un nombre único generado. */
public interface StorageService {

    /** Imagen leída del almacén. */
    record StoredImage(byte[] data, String contentType) {}

    /** Guarda una imagen subida por un usuario (se valida que sea realmente una imagen). */
    default String store(MultipartFile file) {
        try {
            byte[] data = file.getBytes();
            String contentType = ImageValidator.validate(data, file.getOriginalFilename());
            return save(ImageValidator.generateName(contentType), data, contentType);
        } catch (IOException e) {
            throw new UncheckedIOException(e);
        }
    }

    /** Guarda con un nombre concreto (datos de ejemplo). */
    String save(String name, byte[] data, String contentType);

    Optional<StoredImage> load(String name);

    boolean exists(String name);

    void delete(String name);
}
