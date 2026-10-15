package com.salesianos.triana.backend.Animangav4.dtos;

import lombok.*;

import javax.validation.constraints.NotBlank;
import javax.validation.constraints.NotNull;
import java.util.UUID;

@NoArgsConstructor
@AllArgsConstructor
@Getter
@Setter
@Builder
public class CreatePurchaseDto {

    @NotBlank(message = "Debe introducir un número de tarjeta")
    private String numCreditCard;

    @NotNull(message = "Debe indicar el carrito")
    private UUID idCart;
}
