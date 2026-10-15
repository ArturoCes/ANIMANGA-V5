package com.salesianos.triana.backend.Animangav4.controller;

import com.salesianos.triana.backend.Animangav4.dtos.ItemDto;
import com.salesianos.triana.backend.Animangav4.models.User;
import com.salesianos.triana.backend.Animangav4.service.CartService;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.web.PageableDefault;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.UUID;

@RestController
@RequiredArgsConstructor
@RequestMapping("/cart")
public class CartController {

    private final CartService cartService;

    // Los ids de la ruta se mantienen por compatibilidad con los clientes,
    // pero el servicio comprueba que pertenezcan al usuario autenticado.
    @PostMapping("/{userId}/items/{volumenId}")
    public ResponseEntity<String> addItemToCart(@PathVariable UUID userId, @PathVariable UUID volumenId,
                                                @AuthenticationPrincipal User user) {
        cartService.addItemToCart(user, userId, volumenId);
        return ResponseEntity.ok("Item added to cart successfully.");
    }

    @PostMapping("/{userId}/items/remove/{volumenId}")
    public ResponseEntity<String> removeItemFromCart(@PathVariable UUID userId, @PathVariable UUID volumenId,
                                                     @AuthenticationPrincipal User user) {
        cartService.removeItemFromCart(user, userId, volumenId);
        return ResponseEntity.ok("Item removed from cart successfully.");
    }

    @GetMapping("/{cartId}")
    public Page<ItemDto> getAllCartItemsByCartId(@PathVariable UUID cartId, @PageableDefault(size = 50) Pageable pageable,
                                                 @AuthenticationPrincipal User user) {
        return cartService.getAllItemsByCartId(user, cartId, pageable);
    }

}
