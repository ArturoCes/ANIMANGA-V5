package com.salesianos.triana.animanga.imagesearch;

import com.salesianos.triana.animanga.imagesearch.ImageSearchService.ImageSearchResult;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.servlet.http.HttpServletRequest;
import lombok.RequiredArgsConstructor;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestPart;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;

@Tag(name = "Catálogo")
@RestController
@RequiredArgsConstructor
public class ImageSearchController {

    private final ImageSearchService service;
    private final ImageSearchRateLimiter limiter;

    @Operation(summary = "Buscar un manga a partir de una foto o captura de su portada",
            description = "Compara la imagen con las portadas del catálogo. `found` indica si hay una coincidencia clara; "
                    + "`matches` trae hasta 5 mangas ordenados por parecido (0-100). Máximo 10 búsquedas por minuto.")
    @PostMapping(value = "/mangas/search-by-image", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public ImageSearchResult search(@RequestPart("image") MultipartFile image, HttpServletRequest request) {
        limiter.check(request.getRemoteAddr());
        return service.search(image);
    }
}
