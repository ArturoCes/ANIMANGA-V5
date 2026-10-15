package com.salesianos.triana.backend.Animangav4.dtos;

import lombok.*;

import java.time.LocalDateTime;
import java.util.UUID;

@AllArgsConstructor
@NoArgsConstructor
@Builder
@Getter
@Setter
public class GetPurchaseDto {

    private UUID idPurchase;
    private String numCreditCard;
    private UUID idCart;
    private UUID idUser;
    private String username;
    private UUID idVolumen;
    private String nombreVolumen;
    private String nameManga;
    private String posterPath;
    private Integer quantity;
    private Double precio;
    private Double total;
    private String fullName;
    private LocalDateTime purchaseDate;
}
