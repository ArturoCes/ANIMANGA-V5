package com.salesianos.triana.animanga.catalog;

import com.salesianos.triana.animanga.catalog.CatalogDtos.*;
import com.salesianos.triana.animanga.common.PageResponse;
import com.salesianos.triana.animanga.user.User;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.math.BigDecimal;
import java.util.List;
import java.util.UUID;

@Tag(name = "Catálogo")
@RestController
@RequestMapping("/mangas")
@RequiredArgsConstructor
public class MangaController {

    private final CatalogService catalog;

    @Operation(summary = "Buscar en el catálogo con filtros, ordenación y paginación")
    @GetMapping
    public PageResponse<MangaSummary> search(
            @Parameter(description = "Texto en el título o el autor") @RequestParam(required = false) String q,
            @RequestParam(required = false) String category,
            @RequestParam(required = false) String publisher,
            @RequestParam(required = false) BigDecimal minPrice,
            @RequestParam(required = false) BigDecimal maxPrice,
            @RequestParam(required = false) Boolean inStock,
            @Parameter(description = "title | newest | price_asc | price_desc | rating | bestselling")
            @RequestParam(defaultValue = "title") String sort,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "12") int size) {
        var filter = new MangaSpecifications.Filter(q, category, publisher, minPrice, maxPrice, inStock);
        return catalog.search(filter, sort, page, size);
    }

    @Operation(summary = "Secciones de la portada: novedades, más vendidos, mejor valorados y recomendados")
    @GetMapping("/home")
    public HomeResponse home(@AuthenticationPrincipal User user) {
        return catalog.home(user);
    }

    @Operation(summary = "Editoriales disponibles (para los filtros)")
    @GetMapping("/publishers")
    public List<String> publishers() {
        return catalog.publishers();
    }

    @Operation(summary = "Ficha completa de un manga con volúmenes y personajes")
    @GetMapping("/{id}")
    public MangaDetail detail(@PathVariable UUID id, @AuthenticationPrincipal User user) {
        return catalog.detail(id, user);
    }

    @Operation(summary = "Crear un manga con su portada")
    @PostMapping(consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    @ResponseStatus(HttpStatus.CREATED)
    public MangaDetail create(@Valid @RequestPart("manga") MangaRequest req, @RequestPart("cover") MultipartFile cover) {
        return catalog.createManga(req, cover);
    }

    @Operation(summary = "Editar los datos de un manga")
    @PutMapping("/{id}")
    public MangaDetail update(@PathVariable UUID id, @Valid @RequestBody MangaRequest req) {
        return catalog.updateManga(id, req);
    }

    @Operation(summary = "Cambiar la portada de un manga")
    @PutMapping(value = "/{id}/cover", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public MangaDetail cover(@PathVariable UUID id, @RequestPart("cover") MultipartFile cover) {
        return catalog.updateMangaCover(id, cover);
    }

    @Operation(summary = "Eliminar un manga con sus volúmenes y personajes")
    @DeleteMapping("/{id}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void delete(@PathVariable UUID id) {
        catalog.deleteManga(id);
    }

    @Operation(summary = "Añadir un volumen a un manga")
    @PostMapping(value = "/{id}/volumes", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    @ResponseStatus(HttpStatus.CREATED)
    public VolumeDto createVolume(@PathVariable UUID id, @Valid @RequestPart("volume") VolumeRequest req,
                                  @RequestPart("cover") MultipartFile cover) {
        return catalog.createVolume(id, req, cover);
    }

    @Operation(summary = "Añadir un personaje a un manga (imagen opcional)")
    @PostMapping(value = "/{id}/characters", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    @ResponseStatus(HttpStatus.CREATED)
    public CharacterDto createCharacter(@PathVariable UUID id, @Valid @RequestPart("character") CharacterRequest req,
                                        @RequestPart(value = "image", required = false) MultipartFile image) {
        return catalog.createCharacter(id, req, image);
    }
}
