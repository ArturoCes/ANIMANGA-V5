package com.salesianos.triana.backend.Animangav4.service;

import com.salesianos.triana.backend.Animangav4.dtos.ItemDto;
import com.salesianos.triana.backend.Animangav4.dtos.ItemDtoConverter;
import com.salesianos.triana.backend.Animangav4.exception.EntityNotFoundException;
import com.salesianos.triana.backend.Animangav4.models.*;

import com.salesianos.triana.backend.Animangav4.repository.CartRepository;
import com.salesianos.triana.backend.Animangav4.repository.ItemRepository;
import com.salesianos.triana.backend.Animangav4.repository.UserRepository;
import com.salesianos.triana.backend.Animangav4.repository.VolumenRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class CartService {


    private final CartRepository cartRepository;


    private final VolumenRepository volumenRepository;

    private final UserRepository userRepository;
    private final ItemRepository itemRepository;

    private final ItemDtoConverter itemDtoConverter;
    public void addItemToCart(UUID userId, UUID volumenId) {
        Optional<User> user = userRepository.findById(userId);
        Optional<Volumen> volumen = volumenRepository.findById(volumenId);

        if (user.isPresent() && volumen.isPresent()) {
            User userData = user.get();
            Cart cart = userData.getCarrito();

            Item item = new Item();
            item.setCart(cart);
            item.setVolumen(volumen.get());
            item.setQuantity(1);  // O puedes agregar lógica para aumentar la cantidad si ya existe en el carrito

            itemRepository.save(item);
        } else {
            throw new EntityNotFoundException(volumenId.toString(), User.class); // Manejar el caso en que el usuario o el volumen no existen
        }
    }

    public void removeItemFromCart(UUID userId, UUID volumenId) {
        Optional<User> user = userRepository.findById(userId);
        Optional<Volumen> volumen = volumenRepository.findById(volumenId);

        if (user.isPresent() && volumen.isPresent()) {
            User userData = user.get();
            Cart cart = userData.getCarrito();

            Optional<Item> item = itemRepository.findByCartAndVolumen(cart, volumen.get());

            if (item.isPresent()) {
                itemRepository.delete(item.get());
            } else {
                // Manejar el caso en que el ítem no existe en el carrito
            }
        } else {
            throw new EntityNotFoundException(volumenId.toString(), User.class); // Manejar el caso en que el usuario o el volumen no existen
        }
    }


    public Page<ItemDto> getAllItemsByCartId(UUID cartId, Pageable pageable) {
        Page<Item> itemsPage = itemRepository.findByCartId(cartId, pageable);

        if (itemsPage.isEmpty()) {
            throw new IllegalArgumentException("No items found for the user");
        } else {
            return itemsPage.map(itemDtoConverter::itemToItemDto);
        }
    }

}
