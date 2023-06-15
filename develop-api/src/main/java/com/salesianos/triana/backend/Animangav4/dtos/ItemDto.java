package com.salesianos.triana.backend.Animangav4.dtos;

import lombok.*;

import java.util.UUID;
@AllArgsConstructor
@NoArgsConstructor
@Builder
@Getter
@Setter
public class ItemDto {
    private UUID id;

    private UUID idCarrito;

    private Integer quantity;

    private GetVolumenDto volumen;
}
