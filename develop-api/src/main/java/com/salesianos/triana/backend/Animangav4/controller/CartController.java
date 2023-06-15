package com.salesianos.triana.backend.Animangav4.controller;

import com.salesianos.triana.backend.Animangav4.dtos.ItemDto;
import com.salesianos.triana.backend.Animangav4.dtos.ItemDtoConverter;
import com.salesianos.triana.backend.Animangav4.models.Item;
import com.salesianos.triana.backend.Animangav4.service.CartService;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.web.PageableDefault;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@RestController
@RequiredArgsConstructor
@RequestMapping("/cart")
public class CartController {

    private final CartService cartService;
    private final ItemDtoConverter itemDtoConverter;
    @PostMapping("/{userId}/items/{volumenId}")
    public ResponseEntity<String> addItemToCart(@PathVariable UUID userId, @PathVariable UUID volumenId) {
        cartService.addItemToCart(userId, volumenId);
        return ResponseEntity.ok("Item added to cart successfully.");
    }

    @PostMapping("/{userId}/items/remove/{volumenId}")
    public ResponseEntity<String> removeItemFromCart(@PathVariable UUID userId, @PathVariable UUID volumenId) {
        cartService.removeItemFromCart(userId, volumenId);
        return ResponseEntity.ok("Item removed from cart successfully.");
    }

    @GetMapping("/{cartId}")
    public Page<ItemDto> getAllCartItemsByCartId(@PathVariable UUID cartId, @PageableDefault(size = 10) Pageable pageable) {
        return cartService.getAllItemsByCartId(cartId, pageable);
    }

}
