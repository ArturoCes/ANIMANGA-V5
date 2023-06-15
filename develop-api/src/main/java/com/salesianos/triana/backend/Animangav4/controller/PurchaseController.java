package com.salesianos.triana.backend.Animangav4.controller;

import com.salesianos.triana.backend.Animangav4.dtos.*;
import com.salesianos.triana.backend.Animangav4.models.Manga;
import com.salesianos.triana.backend.Animangav4.models.Purchase;
import com.salesianos.triana.backend.Animangav4.models.User;
import com.salesianos.triana.backend.Animangav4.service.PurchaseService;
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
import java.util.List;

@RestController
@RequiredArgsConstructor
@RequestMapping("/purchase")
public class PurchaseController {

    private final PurchaseService purchaseService;

    private final PaginationLinksUtils paginationLinksUtils;

    private final PurchaseDtoConverter purchaseDtoConverter;

    @Operation(summary = "Crea una linea de venta")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "201",
                    description = "Si se crea la linea de venta correctamente",
                    content = {@Content(mediaType = "aplication/json",
                            schema = @Schema(implementation = Purchase.class))}),
            @ApiResponse(responseCode = "400",
                    description = "Error en los datos",
                    content = @Content),
    })
    @PostMapping("/new")
    public ResponseEntity<Page<GetPurchaseDto>> createPurchase(@PageableDefault(size = 10, page = 0) Pageable pageable,
                                                               HttpServletRequest request, @RequestBody CreatePurchaseDto createPurchaseDto, @AuthenticationPrincipal User user) {
        Page<GetPurchaseDto> list = purchaseService.save(user, createPurchaseDto, pageable);
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(list);
    }

    @Operation(summary = "Listar todas las lineas de venta")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200",
                    description = "Se devuelve una lista con todas las lineas de venta",
                    content = {@Content(mediaType = "aplication/json",
                            schema = @Schema(implementation = Purchase.class))}),
            @ApiResponse(responseCode = "404",
                    description = "La lista esta vacia",
                    content = @Content),
    })
    @GetMapping("/all")
    public ResponseEntity<Page<GetPurchaseDto>> findAll(@PageableDefault(size = 10, page = 0) Pageable pageable,
                                                           @AuthenticationPrincipal User user,
                                                           @NotNull HttpServletRequest request) {
        Page<GetPurchaseDto> list = purchaseService.findAll(pageable).map(purchaseDtoConverter::purchaseToGetPurchaseDto);
        UriComponentsBuilder uriBuilder = UriComponentsBuilder.fromHttpUrl(request.getRequestURL().toString());
        return ResponseEntity.ok().header("link", paginationLinksUtils.createLinkHeader(list, uriBuilder)).body(list);
    }

}
