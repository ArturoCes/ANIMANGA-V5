package com.salesianos.triana.animanga.catalog;

import com.salesianos.triana.animanga.catalog.CatalogDtos.*;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.util.UUID;

@Tag(name = "Administración · Volúmenes y personajes")
@RestController
@RequiredArgsConstructor
public class VolumeController {

    private final CatalogService catalog;

    @Operation(summary = "Editar un volumen")
    @PutMapping("/volumes/{id}")
    public VolumeDto update(@PathVariable UUID id, @Valid @RequestBody VolumeRequest req) {
        return catalog.updateVolume(id, req);
    }

    @Operation(summary = "Cambiar la portada de un volumen")
    @PutMapping(value = "/volumes/{id}/cover", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public VolumeDto cover(@PathVariable UUID id, @RequestPart("cover") MultipartFile cover) {
        return catalog.updateVolumeCover(id, cover);
    }

    @Operation(summary = "Eliminar un volumen")
    @DeleteMapping("/volumes/{id}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void delete(@PathVariable UUID id) {
        catalog.deleteVolume(id);
    }

    @Operation(summary = "Editar un personaje")
    @PutMapping("/characters/{id}")
    public CharacterDto updateCharacter(@PathVariable UUID id, @Valid @RequestBody CharacterRequest req) {
        return catalog.updateCharacter(id, req);
    }

    @Operation(summary = "Cambiar la imagen de un personaje")
    @PutMapping(value = "/characters/{id}/image", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public CharacterDto characterImage(@PathVariable UUID id, @RequestPart("image") MultipartFile image) {
        return catalog.updateCharacterImage(id, image);
    }

    @Operation(summary = "Eliminar un personaje")
    @DeleteMapping("/characters/{id}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void deleteCharacter(@PathVariable UUID id) {
        catalog.deleteCharacter(id);
    }
}
