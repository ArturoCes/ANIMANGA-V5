package com.salesianos.triana.backend.Animangav4.service;

import com.salesianos.triana.backend.Animangav4.dtos.ItemDto;
import com.salesianos.triana.backend.Animangav4.dtos.ItemDtoConverter;
import com.salesianos.triana.backend.Animangav4.exception.BadRequestException;
import com.salesianos.triana.backend.Animangav4.exception.EntityNotFoundException;
import com.salesianos.triana.backend.Animangav4.exception.ForbiddenException;
import com.salesianos.triana.backend.Animangav4.models.*;
import com.salesianos.triana.backend.Animangav4.repository.CartRepository;
import com.salesianos.triana.backend.Animangav4.repository.ItemRepository;
import com.salesianos.triana.backend.Animangav4.repository.UserRepository;
import com.salesianos.triana.backend.Animangav4.repository.VolumenRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.UUID;

@Service
@RequiredArgsConstructor
public class CartService {

    private final CartRepository cartRepository;
    private final VolumenRepository volumenRepository;
    private final UserRepository userRepository;
    private final ItemRepository itemRepository;
    private final ItemDtoConverter itemDtoConverter;

    @Transactional
    public void addItemToCart(User principal, UUID userId, UUID volumenId) {
        Cart cart = ownCart(principal, userId);
        Volumen volumen = volumenRepository.findById(volumenId)
                .orElseThrow(() -> new EntityNotFoundException(volumenId.toString(), Volumen.class));

        Item item = itemRepository.findByCartAndVolumen(cart, volumen).orElse(null);
        int nuevaCantidad = item == null ? 1 : item.getQuantity() + 1;

        if (volumen.getCantidad() == null || nuevaCantidad > volumen.getCantidad()) {
            throw new BadRequestException("No hay stock suficiente de " + volumen.getNombre());
        }

        if (item == null) {
            item = Item.builder().cart(cart).volumen(volumen).quantity(1).build();
        } else {
            item.setQuantity(nuevaCantidad);
        }
        itemRepository.save(item);
    }

    @Transactional
    public void removeItemFromCart(User principal, UUID userId, UUID volumenId) {
        Cart cart = ownCart(principal, userId);
        Volumen volumen = volumenRepository.findById(volumenId)
                .orElseThrow(() -> new EntityNotFoundException(volumenId.toString(), Volumen.class));

        Item item = itemRepository.findByCartAndVolumen(cart, volumen)
                .orElseThrow(() -> new BadRequestException("El volumen no está en el carrito"));

        if (item.getQuantity() > 1) {
            item.setQuantity(item.getQuantity() - 1);
            itemRepository.save(item);
        } else {
            cart.getItems().remove(item);
            itemRepository.delete(item);
        }
    }

    @Transactional(readOnly = true)
    public Page<ItemDto> getAllItemsByCartId(User principal, UUID cartId, Pageable pageable) {
        Cart cart = cartRepository.findById(cartId)
                .orElseThrow(() -> new EntityNotFoundException(cartId.toString(), Cart.class));
        checkOwner(principal, cart.getUser().getId());
        return itemRepository.findByCartId(cartId, pageable).map(itemDtoConverter::itemToItemDto);
    }

    private Cart ownCart(User principal, UUID userId) {
        checkOwner(principal, userId);
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new EntityNotFoundException(userId.toString(), User.class));
        return user.getCarrito();
    }

    private void checkOwner(User principal, UUID ownerId) {
        if (!principal.getId().equals(ownerId) && principal.getRole() != UserRole.ADMIN) {
            throw new ForbiddenException("No puede acceder al carrito de otro usuario");
        }
    }

}
