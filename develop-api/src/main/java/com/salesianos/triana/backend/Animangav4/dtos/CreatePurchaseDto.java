package com.salesianos.triana.backend.Animangav4.dtos;

import lombok.*;

import java.time.LocalDateTime;
import java.util.UUID;

@NoArgsConstructor
@AllArgsConstructor
@Getter
@Setter
@Builder
public class CreatePurchaseDto {

    private String numCreditCard;

    private UUID idCart;

}
