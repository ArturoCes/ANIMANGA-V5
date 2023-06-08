package com.salesianos.triana.backend.Animangav4.controller;

import com.salesianos.triana.backend.Animangav4.dtos.CategoryDtoConverter;
import com.salesianos.triana.backend.Animangav4.dtos.CreateCategoryDto;
import com.salesianos.triana.backend.Animangav4.dtos.GetCategoryDto;
import com.salesianos.triana.backend.Animangav4.models.Category;
import com.salesianos.triana.backend.Animangav4.models.User;
import com.salesianos.triana.backend.Animangav4.service.CategoryService;
import com.salesianos.triana.backend.Animangav4.utils.PaginationLinksUtils;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.web.PageableDefault;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.util.UriComponentsBuilder;

import javax.servlet.http.HttpServletRequest;
import javax.validation.Valid;

@RestController
@RequiredArgsConstructor
@RequestMapping("/category")
public class CategoryController {
    private final CategoryService categoryService;

    private final PaginationLinksUtils paginationLinksUtils;


    @Operation(summary = "Crear una categoria")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "201",
                    description = "Se crea la categoria correctamente",
                    content = {@Content(mediaType = "aplication/json",
                            schema = @Schema(implementation = Category.class))}),
            @ApiResponse(responseCode = "400",
                    description = "Error en los datos",
                    content = @Content),
    })
    @PostMapping("/new")
    public ResponseEntity<GetCategoryDto> createCategory(@Valid @RequestPart("category") CreateCategoryDto c,
                                                         @AuthenticationPrincipal User user) {
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(categoryService.save(c, user));
    }

    @Operation(summary = "Listar todas las categorias")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200",
                    description = "Se devuelve una lista con todas las categorias",
                    content = {@Content(mediaType = "aplication/json",
                            schema = @Schema(implementation = Category.class))}),
            @ApiResponse(responseCode = "404",
                    description = "La lista esta vacia",
                    content = @Content),
    })
    @GetMapping("/all")
    public ResponseEntity<Page<GetCategoryDto>> findAllCategories (@PageableDefault(size = 10, page = 0) Pageable pageable,
                                                               @AuthenticationPrincipal User user,
                                                               HttpServletRequest request) {
        Page<GetCategoryDto> lista = categoryService.findAllCategories(pageable);
        UriComponentsBuilder uriBuilder = UriComponentsBuilder.fromHttpUrl(request.getRequestURL().toString());
        return ResponseEntity.ok().header("link", paginationLinksUtils.createLinkHeader(lista, uriBuilder)).body(lista);

    }

}
