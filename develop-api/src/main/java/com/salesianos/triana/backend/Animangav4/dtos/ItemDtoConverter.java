package com.salesianos.triana.backend.Animangav4.dtos;

import com.salesianos.triana.backend.Animangav4.models.Item;
import com.salesianos.triana.backend.Animangav4.models.Manga;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

@Component
@RequiredArgsConstructor
public class ItemDtoConverter {

    private final VolumenDtoConverter volumenDtoConverter;

    public ItemDto itemToItemDto(Item item) {
        return ItemDto.builder()
                .id(item.getId())
                .idCarrito(item.getCart().getId())
                .volumen(volumenDtoConverter.volumenToGetVolumenDto(item.getVolumen()))
                .quantity(item.getQuantity())
                .build();
    }
}