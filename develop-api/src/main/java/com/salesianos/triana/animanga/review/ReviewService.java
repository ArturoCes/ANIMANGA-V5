package com.salesianos.triana.animanga.review;

import com.salesianos.triana.animanga.catalog.Manga;
import com.salesianos.triana.animanga.catalog.MangaRepository;
import com.salesianos.triana.animanga.catalog.MangaStatsUpdater;
import com.salesianos.triana.animanga.common.ApiException;
import com.salesianos.triana.animanga.common.PageResponse;
import com.salesianos.triana.animanga.order.OrderRepository;
import com.salesianos.triana.animanga.user.User;
import com.salesianos.triana.animanga.user.UserRepository;
import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.Size;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.PageRequest;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class ReviewService {

    public record Author(String username, String fullName, String avatar) {}

    public record ReviewDto(UUID id, int rating, String comment, Instant createdAt, Author author,
                            boolean verifiedPurchase) {}

    public record ReviewRequest(
            @Min(value = 1, message = "La valoración va de 1 a 5") @Max(value = 5, message = "La valoración va de 1 a 5")
            int rating,
            @Size(max = 1000, message = "El comentario no puede superar los 1000 caracteres") String comment) {}

    private final ReviewRepository reviews;
    private final MangaRepository mangas;
    private final UserRepository users;
    private final OrderRepository orders;
    private final MangaStatsUpdater stats;

    @Transactional(readOnly = true)
    public PageResponse<ReviewDto> list(UUID mangaId, int page, int size) {
        Manga manga = mangas.findById(mangaId).orElseThrow(() -> ApiException.notFound("Manga"));
        var result = reviews.findByMangaOrderByCreatedAtDesc(manga, PageRequest.of(page, Math.min(size, 50)));
        return PageResponse.of(result, r -> toDto(r, manga));
    }

    /** Crea o actualiza la reseña del usuario para ese manga (una por persona). */
    @Transactional
    public ReviewDto upsert(User principal, UUID mangaId, ReviewRequest req) {
        Manga manga = mangas.findById(mangaId).orElseThrow(() -> ApiException.notFound("Manga"));
        User user = users.findById(principal.getId()).orElseThrow();
        Review review = reviews.findByUserAndManga(user, manga)
                .orElseGet(() -> Review.builder().user(user).manga(manga).build());
        review.setRating(req.rating());
        review.setComment(req.comment() == null || req.comment().isBlank() ? null : req.comment().trim());
        if (review.getId() != null) review.setCreatedAt(Instant.now());
        reviews.saveAndFlush(review);
        stats.refresh(manga);
        return toDto(review, manga);
    }

    @Transactional
    public void delete(User principal, UUID reviewId) {
        Review review = reviews.findById(reviewId).orElseThrow(() -> ApiException.notFound("Reseña"));
        if (!principal.isAdmin() && !review.getUser().getId().equals(principal.getId())) {
            throw ApiException.forbidden("Solo puedes borrar tus propias reseñas");
        }
        Manga manga = review.getManga();
        reviews.delete(review);
        reviews.flush();
        stats.refresh(manga);
    }

    private ReviewDto toDto(Review r, Manga manga) {
        User u = r.getUser();
        return new ReviewDto(r.getId(), r.getRating(), r.getComment(), r.getCreatedAt(),
                new Author(u.getUsername(), u.getFullName(), u.getAvatar()),
                orders.hasPurchased(u, manga));
    }
}
