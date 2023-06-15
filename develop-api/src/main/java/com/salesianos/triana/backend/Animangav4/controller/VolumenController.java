package com.salesianos.triana.backend.Animangav4.controller;

import com.salesianos.triana.backend.Animangav4.dtos.*;
import com.salesianos.triana.backend.Animangav4.models.Manga;
import com.salesianos.triana.backend.Animangav4.models.User;
import com.salesianos.triana.backend.Animangav4.models.Volumen;
import com.salesianos.triana.backend.Animangav4.repository.CategoryRepository;
import com.salesianos.triana.backend.Animangav4.service.CharacterService;
import com.salesianos.triana.backend.Animangav4.service.MangaService;
import com.salesianos.triana.backend.Animangav4.service.VolumenService;
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
import java.util.UUID;

@RestController
@RequiredArgsConstructor
@RequestMapping("/volumen")
public class VolumenController {

    private final MangaService mangaService;
    private final VolumenService volumenService;
    private final PaginationLinksUtils paginationLinksUtils;
    private final VolumenDtoConverter volumenDtoConverter;


    @Operation(summary = "Listar todos los volumenes")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200",
                    description = "Se devuelve una lista con todos los volumenes",
                    content = {@Content(mediaType = "aplication/json",
                            schema = @Schema(implementation = Volumen.class))}),
            @ApiResponse(responseCode = "404",
                    description = "La lista esta vacia",
                    content = @Content),
    })
    @GetMapping("/all")
    public ResponseEntity<Page<GetVolumenDto>> findAllVolums(@PageableDefault(size = 10, page = 0) Pageable pageable,
                                                             @AuthenticationPrincipal User user,
                                                             @NotNull HttpServletRequest request) {
        Page<GetVolumenDto> list = volumenService.findAllVolums(pageable);
        UriComponentsBuilder uriBuilder = UriComponentsBuilder.fromHttpUrl(request.getRequestURL().toString());
        return ResponseEntity.ok().header("link", paginationLinksUtils.createLinkHeader(list, uriBuilder)).body(list);
    }

    @Operation(summary = "Crea un Volumen")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "201",
                    description = "Si se crea el manga correctamente",
                    content = {@Content(mediaType = "aplication/json",
                            schema = @Schema(implementation = Volumen.class))}),
            @ApiResponse(responseCode = "400",
                    description = "Error en los datos",
                    content = @Content),
    })
    @PostMapping("/new/{idManga}")
    public ResponseEntity<GetVolumenDto> createVolumen(@Valid @RequestPart("volumen") CreateVolumenDto c,
                                                   @RequestPart("file") MultipartFile file, @PathVariable UUID idManga) {
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(volumenDtoConverter.volumenToGetVolumenDto(volumenService.save(idManga, c, file)));
    }

    @Operation(summary = "Obtener un volumen")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200",
                    description = "Se encuentra el volumen con el id proporcionado",
                    content = {@Content(mediaType = "aplication/json",
                            schema = @Schema(implementation = Manga.class))}),
            @ApiResponse(responseCode = "404",
                    description = "No se encontró ningún volumen",
                    content = @Content),
    })
    @GetMapping("/{id}")
    public GetVolumenDto findVolumenById(@PathVariable UUID id) {
        return volumenDtoConverter.volumenToGetVolumenDto(volumenService.findById(id));
    }

    @Operation(summary = "Editar un volumen")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200",
                    description = "Se edita el manga correctamente",
                    content = {@Content(mediaType = "aplication/json",
                            schema = @Schema(implementation = Volumen.class))}),
            @ApiResponse(responseCode = "400",
                    description = "Error en los datos",
                    content = @Content),
            @ApiResponse(responseCode = "404",
                    description = "No se encontró el volumen",
                    content = @Content),
    })
    @PutMapping("/{id}")
    public GetVolumenDto editVolumen(@Valid @RequestPart("volumen") CreateVolumenDto c,
                                 @AuthenticationPrincipal User user,
                                 @PathVariable UUID id) {
        return volumenDtoConverter.volumenToGetVolumenDto(volumenService.editVolumen(c, user, id));
    }


    @Operation(summary = "Eliminar un volumen")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "204",
                    description = "Se elimina el volumen correctamente",
                    content = {@Content(mediaType = "aplication/json",
                            schema = @Schema(implementation = Manga.class))}),
            @ApiResponse(responseCode = "404",
                    description = "No se encontró el volumen",
                    content = @Content),
    })
    @DeleteMapping("/{id}")
    public ResponseEntity<?> delete(@PathVariable UUID id) {
        volumenService.deleteVolumen(id);
        return ResponseEntity.status(HttpStatus.NO_CONTENT).build();
    }



}
