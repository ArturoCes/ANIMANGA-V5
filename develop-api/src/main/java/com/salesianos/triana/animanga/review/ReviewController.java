package com.salesianos.triana.animanga.review;

import com.salesianos.triana.animanga.common.PageResponse;
import com.salesianos.triana.animanga.review.ReviewService.ReviewDto;
import com.salesianos.triana.animanga.review.ReviewService.ReviewRequest;
import com.salesianos.triana.animanga.user.User;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.UUID;

@Tag(name = "Reseñas")
@RestController
@RequiredArgsConstructor
public class ReviewController {

    private final ReviewService reviews;

    @Operation(summary = "Reseñas de un manga (más recientes primero)")
    @GetMapping("/mangas/{mangaId}/reviews")
    public PageResponse<ReviewDto> list(@PathVariable UUID mangaId,
                                        @RequestParam(defaultValue = "0") int page,
                                        @RequestParam(defaultValue = "10") int size) {
        return reviews.list(mangaId, page, size);
    }

    @Operation(summary = "Valorar un manga (crea o actualiza tu reseña)")
    @PostMapping("/mangas/{mangaId}/reviews")
    public ReviewDto upsert(@AuthenticationPrincipal User user, @PathVariable UUID mangaId,
                            @Valid @RequestBody ReviewRequest req) {
        return reviews.upsert(user, mangaId, req);
    }

    @Operation(summary = "Borrar una reseña (la tuya, o cualquiera si eres administrador)")
    @DeleteMapping("/reviews/{id}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void delete(@AuthenticationPrincipal User user, @PathVariable UUID id) {
        reviews.delete(user, id);
    }
}
