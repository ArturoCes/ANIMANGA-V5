package com.salesianos.triana.animanga.storage;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.http.CacheControl;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RestController;

import java.time.Duration;

@Tag(name = "Imágenes")
@RestController
@RequiredArgsConstructor
public class ImageController {

    private final StorageService storage;

    @Operation(summary = "Descargar una imagen (portadas, personajes, avatares)")
    @GetMapping("/images/{name:.+}")
    public ResponseEntity<byte[]> image(@PathVariable String name) {
        var image = storage.load(name).orElseThrow(() -> new StorageException("Imagen no encontrada", true));
        return ResponseEntity.ok()
                .contentType(MediaType.parseMediaType(image.contentType()))
                // Los nombres son únicos: al cambiar una portada cambia la URL
                .cacheControl(CacheControl.maxAge(Duration.ofDays(30)).cachePublic())
                .body(image.data());
    }
}
