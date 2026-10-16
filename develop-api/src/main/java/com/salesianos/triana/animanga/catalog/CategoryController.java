package com.salesianos.triana.animanga.catalog;

import com.salesianos.triana.animanga.catalog.CatalogDtos.*;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@Tag(name = "Categorías")
@RestController
@RequestMapping("/categories")
@RequiredArgsConstructor
public class CategoryController {

    private final CatalogService catalog;

    @Operation(summary = "Listar categorías")
    @GetMapping
    public List<CategoryDto> all() {
        return catalog.categories();
    }

    @Operation(summary = "Crear una categoría")
    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    public CategoryDto create(@Valid @RequestBody CategoryRequest req) {
        return catalog.createCategory(req);
    }

    @Operation(summary = "Editar una categoría")
    @PutMapping("/{id}")
    public CategoryDto update(@PathVariable UUID id, @Valid @RequestBody CategoryRequest req) {
        return catalog.updateCategory(id, req);
    }

    @Operation(summary = "Eliminar una categoría (se quita de los mangas que la usan)")
    @DeleteMapping("/{id}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void delete(@PathVariable UUID id) {
        catalog.deleteCategory(id);
    }
}
