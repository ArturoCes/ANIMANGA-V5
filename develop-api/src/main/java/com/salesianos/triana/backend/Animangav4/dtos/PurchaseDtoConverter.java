package com.salesianos.triana.backend.Animangav4.dtos;

import com.salesianos.triana.backend.Animangav4.models.Purchase;
import com.salesianos.triana.backend.Animangav4.models.Volumen;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

@Component
@RequiredArgsConstructor
public class PurchaseDtoConverter {

    private final CategoryDtoConverter categoryDtoConverter;

    public GetPurchaseDto purchaseToGetPurchaseDto (Purchase purchase) {
        return GetPurchaseDto.builder()
                .idPurchase(purchase.getId())
                .numCreditCard(purchase.getNumCreditCard())
                .purchaseDate(purchase.getPurchaseDate())
                .idCart(purchase.getCart().getId())
                .idUser(purchase.getCart().getId())
                .fullName(purchase.getCart().getUser().getFullName())
                .idVolumen(purchase.getVolumen().getId())
                .precio(purchase.getVolumen().getPrecio())
                .build();
    }
}
