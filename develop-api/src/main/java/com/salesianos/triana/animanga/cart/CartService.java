package com.salesianos.triana.animanga.cart;

import com.salesianos.triana.animanga.catalog.CatalogDtos.VolumeDto;
import com.salesianos.triana.animanga.catalog.CatalogMapper;
import com.salesianos.triana.animanga.catalog.Volume;
import com.salesianos.triana.animanga.catalog.VolumeRepository;
import com.salesianos.triana.animanga.common.ApiException;
import com.salesianos.triana.animanga.user.User;
import com.salesianos.triana.animanga.user.UserRepository;
import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotNull;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.util.List;
import java.util.UUID;

/** Carrito del usuario autenticado: siempre se trabaja sobre el suyo, nunca sobre otro. */
@Service
@RequiredArgsConstructor
public class CartService {

    public record CartLine(VolumeDto volume, int quantity, BigDecimal subtotal) {}

    public record CartDto(List<CartLine> items, int totalItems, BigDecimal total) {}

    public record AddItemRequest(@NotNull(message = "Indica el volumen") UUID volumeId,
                                 @Min(value = 1, message = "La cantidad mínima es 1")
                                 @Max(value = 20, message = "Máximo 20 unidades por volumen") Integer quantity) {}

    public record QuantityRequest(@Min(value = 0, message = "La cantidad no puede ser negativa")
                                  @Max(value = 20, message = "Máximo 20 unidades por volumen") int quantity) {}

    private final CartItemRepository items;
    private final VolumeRepository volumes;
    private final UserRepository users;

    @Transactional(readOnly = true)
    public CartDto get(User principal) {
        return toDto(items.findByUserOrderByVolumeTitleAsc(user(principal)));
    }

    @Transactional
    public CartDto add(User principal, AddItemRequest req) {
        User user = user(principal);
        Volume volume = volumes.findById(req.volumeId()).orElseThrow(() -> ApiException.notFound("Volumen"));
        CartItem item = items.findByUserAndVolume(user, volume)
                .orElseGet(() -> CartItem.builder().user(user).volume(volume).quantity(0).build());
        setQuantity(item, item.getQuantity() + (req.quantity() == null ? 1 : req.quantity()));
        items.save(item);
        return get(principal);
    }

    @Transactional
    public CartDto update(User principal, UUID volumeId, int quantity) {
        User user = user(principal);
        Volume volume = volumes.findById(volumeId).orElseThrow(() -> ApiException.notFound("Volumen"));
        CartItem item = items.findByUserAndVolume(user, volume)
                .orElseThrow(() -> ApiException.notFound("El volumen en el carrito"));
        if (quantity == 0) items.delete(item);
        else setQuantity(item, quantity);
        items.flush();
        return get(principal);
    }

    @Transactional
    public CartDto remove(User principal, UUID volumeId) {
        User user = user(principal);
        volumes.findById(volumeId).flatMap(v -> items.findByUserAndVolume(user, v)).ifPresent(items::delete);
        items.flush();
        return get(principal);
    }

    @Transactional
    public void clear(User principal) {
        items.deleteByUser(user(principal));
    }

    private static void setQuantity(CartItem item, int quantity) {
        Volume v = item.getVolume();
        if (v.getStock() <= 0) throw ApiException.badRequest(v.getTitle() + " está agotado");
        if (quantity > v.getStock()) {
            throw ApiException.badRequest("Solo quedan " + v.getStock() + " unidades de " + v.getTitle());
        }
        if (quantity > 20) throw ApiException.badRequest("Máximo 20 unidades por volumen");
        item.setQuantity(quantity);
    }

    private User user(User principal) {
        return users.findById(principal.getId()).orElseThrow();
    }

    static CartDto toDto(List<CartItem> list) {
        var lines = list.stream().map(i -> new CartLine(CatalogMapper.volume(i.getVolume()), i.getQuantity(),
                i.getVolume().getPrice().multiply(BigDecimal.valueOf(i.getQuantity())))).toList();
        int count = lines.stream().mapToInt(CartLine::quantity).sum();
        BigDecimal total = lines.stream().map(CartLine::subtotal).reduce(BigDecimal.ZERO, BigDecimal::add);
        return new CartDto(lines, count, total);
    }
}
