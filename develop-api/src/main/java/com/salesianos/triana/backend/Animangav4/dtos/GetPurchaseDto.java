package com.salesianos.triana.backend.Animangav4.dtos;

import com.salesianos.triana.backend.Animangav4.models.Cart;
import com.salesianos.triana.backend.Animangav4.models.Volumen;
import lombok.*;
import org.springframework.data.annotation.CreatedDate;

import javax.persistence.ForeignKey;
import javax.persistence.JoinColumn;
import javax.persistence.ManyToOne;
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

    private UUID idVolumen;

    private Double precio;

    private String fullName;

    private LocalDateTime purchaseDate;
}
