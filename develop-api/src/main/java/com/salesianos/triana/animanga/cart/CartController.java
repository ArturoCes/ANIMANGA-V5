package com.salesianos.triana.animanga.cart;

import com.salesianos.triana.animanga.cart.CartService.*;
import com.salesianos.triana.animanga.user.User;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.UUID;

@Tag(name = "Carrito")
@RestController
@RequestMapping("/cart")
@RequiredArgsConstructor
public class CartController {

    private final CartService cart;

    @Operation(summary = "Ver mi carrito")
    @GetMapping
    public CartDto get(@AuthenticationPrincipal User user) {
        return cart.get(user);
    }

    @Operation(summary = "Añadir unidades de un volumen")
    @PostMapping("/items")
    public CartDto add(@AuthenticationPrincipal User user, @Valid @RequestBody AddItemRequest req) {
        return cart.add(user, req);
    }

    @Operation(summary = "Cambiar la cantidad de un volumen (0 lo quita)")
    @PutMapping("/items/{volumeId}")
    public CartDto update(@AuthenticationPrincipal User user, @PathVariable UUID volumeId,
                          @Valid @RequestBody QuantityRequest req) {
        return cart.update(user, volumeId, req.quantity());
    }

    @Operation(summary = "Quitar un volumen del carrito")
    @DeleteMapping("/items/{volumeId}")
    public CartDto remove(@AuthenticationPrincipal User user, @PathVariable UUID volumeId) {
        return cart.remove(user, volumeId);
    }

    @Operation(summary = "Vaciar el carrito")
    @DeleteMapping
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void clear(@AuthenticationPrincipal User user) {
        cart.clear(user);
    }
}
