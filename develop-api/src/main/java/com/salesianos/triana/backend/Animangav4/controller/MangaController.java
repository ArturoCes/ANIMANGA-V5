package com.salesianos.triana.backend.Animangav4.controller;


import com.salesianos.triana.backend.Animangav4.dtos.*;
import com.salesianos.triana.backend.Animangav4.models.Category;
import com.salesianos.triana.backend.Animangav4.models.Character;
import com.salesianos.triana.backend.Animangav4.models.Manga;
import com.salesianos.triana.backend.Animangav4.models.User;
import com.salesianos.triana.backend.Animangav4.repository.CategoryRepository;
import com.salesianos.triana.backend.Animangav4.service.CategoryService;
import com.salesianos.triana.backend.Animangav4.service.CharacterService;
import com.salesianos.triana.backend.Animangav4.service.MangaService;
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
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.util.UriComponentsBuilder;

import javax.servlet.http.HttpServletRequest;
import javax.validation.Valid;
import javax.validation.constraints.NotNull;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.UUID;

@RestController
@RequiredArgsConstructor
@RequestMapping("/manga")


public class MangaController {
    private final MangaService mangaService;
    private final MangaDtoConverter mangaDtoConverter;

    private final CategoryRepository categoryRepository;
    private final PaginationLinksUtils paginationLinksUtils;

    private final CharacterService characterService;

    @Operation(summary = "Listar todos los mangas")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200",
                    description = "Se devuelve una lista con todos los mangas",
                    content = {@Content(mediaType = "aplication/json",
                            schema = @Schema(implementation = Manga.class))}),
            @ApiResponse(responseCode = "404",
                    description = "La lista esta vacia",
                    content = @Content),
    })
    @GetMapping("/all")
    public ResponseEntity<Page<GetMangaDto>> findAllMangas(@PageableDefault(size = 10, page = 0) Pageable pageable,
                                                           @AuthenticationPrincipal User user,
                                                           @NotNull HttpServletRequest request) {
        Page<GetMangaDto> list = mangaService.findAllMangas(pageable);
        UriComponentsBuilder uriBuilder = UriComponentsBuilder.fromHttpUrl(request.getRequestURL().toString());
        return ResponseEntity.ok().header("link", paginationLinksUtils.createLinkHeader(list, uriBuilder)).body(list);
    }

    @Operation(summary = "Crea un Manga")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "201",
                    description = "Si se crea el manga correctamente",
                    content = {@Content(mediaType = "aplication/json",
                            schema = @Schema(implementation = Manga.class))}),
            @ApiResponse(responseCode = "400",
                    description = "Error en los datos",
                    content = @Content),
    })
    @PostMapping("/new")
    public ResponseEntity<GetMangaDto> createManga(@Valid @RequestPart("manga") CreateMangaDto c,
                                                   @RequestPart("file") MultipartFile file) {
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(mangaDtoConverter.mangaToGetMangaDto(mangaService.save(c, file)));
    }

    @Operation(summary = "Obtener un manga")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200",
                    description = "Se encuentra el manga con el id proporcionado",
                    content = {@Content(mediaType = "aplication/json",
                            schema = @Schema(implementation = Manga.class))}),
            @ApiResponse(responseCode = "404",
                    description = "No se encontró ningún manga",
                    content = @Content),
    })
    @GetMapping("/{id}")
    public GetMangaDto findMangaById(@PathVariable UUID id) {
        return mangaDtoConverter.mangaToGetMangaDto(mangaService.findById(id));
    }

    @Operation(summary = "Editar un manga")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200",
                    description = "Se edita el manga correctamente",
                    content = {@Content(mediaType = "aplication/json",
                            schema = @Schema(implementation = Manga.class))}),
            @ApiResponse(responseCode = "400",
                    description = "Error en los datos",
                    content = @Content),
            @ApiResponse(responseCode = "404",
                    description = "No se encontró el manga",
                    content = @Content),
    })
    @PutMapping("/{id}")
    public GetMangaDto editManga(@Valid @RequestPart("manga") CreateMangaDto c,
                                 @AuthenticationPrincipal User user,
                                 @PathVariable UUID id) {
        return mangaDtoConverter.mangaToGetMangaDto(mangaService.editManga(c, user, id));
    }


    @Operation(summary = "Eliminar un manga")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "204",
                    description = "Se elimina el manga correctamente",
                    content = {@Content(mediaType = "aplication/json",
                            schema = @Schema(implementation = Manga.class))}),
            @ApiResponse(responseCode = "404",
                    description = "No se encontró el manga",
                    content = @Content),
    })
    @DeleteMapping("/{id}")
    public ResponseEntity<?> delete(@PathVariable UUID id) {
        mangaService.deleteManga(id);
        return ResponseEntity.status(HttpStatus.NO_CONTENT).build();
    }

    //TODO terminar de hacer los favoritos
    @Operation(summary = "Agregar a favoritos")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200",
                    description = "Agrega un manga a la lista de favoritos del usuario",
                    content = {@Content(mediaType = "aplication/json",
                            schema = @Schema(implementation = Manga.class))}),
            @ApiResponse(responseCode = "404",
                    description = "No se encontro el manga",
                    content = @Content),
    })
    @PostMapping("/favorite/{id}")
    public ResponseEntity<GetMangaDto> addFavorite(@PathVariable UUID id,
                                                   @AuthenticationPrincipal User user) {
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(mangaDtoConverter.mangaToGetMangaDto(mangaService.addFavorite(id, user)));
    }

    @Operation(summary = "Listar todos los mangas favoritos de un usuario")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200",
                    description = "Se devuelve una lista con todos los mangas favoritos del usuario",
                    content = {@Content(mediaType = "aplication/json",
                            schema = @Schema(implementation = Manga.class))}),
            @ApiResponse(responseCode = "404",
                    description = "La lista esta vacia",
                    content = @Content),
    })
    @GetMapping("/all/favorite/{username}")
    public ResponseEntity<Page<GetMangaDto>> findAllFavoriteMangas(@PageableDefault(size = 10, page = 0) Pageable pageable,
                                                                   HttpServletRequest request,
                                                                   @PathVariable String username) {
        Page<GetMangaDto> lista = mangaService.findAllFavoriteMangas(username, pageable);
        UriComponentsBuilder uriBuilder = UriComponentsBuilder.fromHttpUrl(request.getRequestURL().toString());
        return ResponseEntity.ok().header("link", paginationLinksUtils.createLinkHeader(lista, uriBuilder)).body(lista);
    }

    @Operation(summary = "Eliminar de favoritos")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200",
                    description = "Elimina un manga a la lista de favoritos del usuario",
                    content = {@Content(mediaType = "aplication/json",
                            schema = @Schema(implementation = User.class))}),
            @ApiResponse(responseCode = "404",
                    description = "No se encontro el libro",
                    content = @Content),
    })
    @PostMapping("/favorite/remove/{id}")
    public ResponseEntity<GetMangaDto> removeFavoriteBook(@PathVariable UUID id,
                                                          @AuthenticationPrincipal User user) {

        return ResponseEntity.status(HttpStatus.CREATED)
                .body(mangaDtoConverter.mangaToGetMangaDto(mangaService.removeFavorite(id, user)));
    }

    @Operation(summary = "Comprobar si un manga es favorito")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200",
                    description = "Si el manga esta en la lista de favoritos del usuario",
                    content = {@Content(mediaType = "aplication/json",
                            schema = @Schema(implementation = Manga.class))}),
            @ApiResponse(responseCode = "404",
                    description = "No se encontro el manga",
                    content = @Content),
    })
    @GetMapping("/favorite/bool/{id}")
    public DtoFavorite isFavoriteManga(@PathVariable UUID id, @AuthenticationPrincipal User user) {
        DtoFavorite f = DtoFavorite.builder()
                .favorito(mangaService.isFavorite(id, user))
                .build();
        return f;
    }


    @GetMapping("/{id}/characters")
    public ResponseEntity<Page<CharacterDto>> getAllCharactersFromManga(
            @PathVariable UUID id,
            @PageableDefault(size = 10, page = 0) Pageable pageable,
            @AuthenticationPrincipal User user,
            @NotNull HttpServletRequest request) {
        Page<CharacterDto> characters = characterService.findAllCharactersByMangaId(id, pageable);
        UriComponentsBuilder uriBuilder = UriComponentsBuilder.fromHttpUrl(request.getRequestURL().toString());
        return ResponseEntity.ok().header("link", paginationLinksUtils.createLinkHeader(characters, uriBuilder)).body(characters);
    }

    //TODO pintar todos los mangas separados por categoria


    @GetMapping("/all/categories/{name}")
    public ResponseEntity<Page<GetMangaDto>> findAllMangasByCategories(@PathVariable String name, @PageableDefault(size = 10, page = 0) Pageable pageable,
                                                                       @AuthenticationPrincipal User user,
                                                                       @NotNull HttpServletRequest request) {
        UriComponentsBuilder uriBuilder = UriComponentsBuilder.fromHttpUrl(request.getRequestURL().toString());

        Page<GetMangaDto> mangas =   mangaService.findAllMangasByCategory(name, pageable).map(mangaDtoConverter::mangaToGetMangaDto);

        return ResponseEntity.ok().header("link", paginationLinksUtils.createLinkHeader(mangas, uriBuilder)).body(mangas);
    }

    @Operation(summary = "Buscar manga")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200",
                    description = "Devuelve una lista con los mangas que coincidan en el nombre",
                    content = {@Content(mediaType = "aplication/json",
                            schema = @Schema(implementation = Manga.class))}),
            @ApiResponse(responseCode = "404",
                    description = "La lista esta vacia",
                    content = @Content),
    })
    @PostMapping("/search/all")
    public ResponseEntity<Page<GetMangaDto>> findByName (@RequestPart("search") SearchDto searchDto,
                                                        @PageableDefault(size = 10, page = 0) Pageable pageable,
                                                        HttpServletRequest request) {
        Page<GetMangaDto> lista = mangaService.findByName(searchDto.getName(), pageable);
        UriComponentsBuilder uriBuilder = UriComponentsBuilder.fromHttpUrl(request.getRequestURL().toString());
        return ResponseEntity.ok().header("link", paginationLinksUtils.createLinkHeader(lista, uriBuilder)).body(lista);
    }


    @Operation(summary = "Editar el poster de un manga")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200",
                    description = "Se edita el cover del libro correctamente",
                    content = {@Content(mediaType = "aplication/json",
                            schema = @Schema(implementation = Manga.class))}),
            @ApiResponse(responseCode = "400",
                    description = "Error en los datos",
                    content = @Content),
            @ApiResponse(responseCode = "404",
                    description = "No se encontró el libro",
                    content = @Content),
    })
    @PutMapping("/poster/{id}")
    public GetMangaDto editPosterManga(@RequestPart("file")MultipartFile file,
                                    @AuthenticationPrincipal User user,
                                    @PathVariable UUID id) {
        return mangaDtoConverter.mangaToGetMangaDto(mangaService.editPosterPath(user,file, id));
    }

}
