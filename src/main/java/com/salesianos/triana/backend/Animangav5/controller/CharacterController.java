package com.salesianos.triana.backend.Animangav5.controller;

import com.salesianos.triana.backend.Animangav5.dtos.CharacterDto;
import com.salesianos.triana.backend.Animangav5.models.User;
import com.salesianos.triana.backend.Animangav5.service.CharacterService;
import com.salesianos.triana.backend.Animangav5.utils.PaginationLinksUtils;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.web.PageableDefault;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.util.UriComponentsBuilder;

import javax.servlet.http.HttpServletRequest;
import javax.validation.constraints.NotNull;

@RestController
@RequiredArgsConstructor
@RequestMapping("/manga/character")
public class CharacterController {

    private final CharacterService characterService;
    private final PaginationLinksUtils paginationLinksUtils;

    @Operation(summary = "Listar todos los personajes de un manga")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200",
                    description = "Se devuelve una lista con todos los personajes de un manga",
                    content = {@Content(mediaType = "aplication/json",
                            schema = @Schema(implementation = Character.class))}),
            @ApiResponse(responseCode = "404",
                    description = "La lista esta vacia",
                    content = @Content),
    })
    @GetMapping("/all")
    public ResponseEntity<Page<CharacterDto>> findAllCharacters(@PageableDefault(size = 10, page = 0) Pageable pageable,
                                                                @AuthenticationPrincipal User user,
                                                                @NotNull HttpServletRequest request) {
        Page<CharacterDto> list = characterService.findAllCharacters(pageable);
        UriComponentsBuilder uriBuilder = UriComponentsBuilder.fromHttpUrl(request.getRequestURL().toString());
        return ResponseEntity.ok().header("link", paginationLinksUtils.createLinkHeader(list, uriBuilder)).body(list);
    }


}
