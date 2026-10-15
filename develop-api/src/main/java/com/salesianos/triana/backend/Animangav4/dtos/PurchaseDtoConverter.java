package com.salesianos.triana.backend.Animangav4.dtos;

import com.salesianos.triana.backend.Animangav4.models.Purchase;
import com.salesianos.triana.backend.Animangav4.models.User;
import com.salesianos.triana.backend.Animangav4.models.Volumen;
import org.springframework.stereotype.Component;

@Component
public class PurchaseDtoConverter {

    public GetPurchaseDto purchaseToGetPurchaseDto(Purchase purchase) {
        User user = purchase.getCart().getUser();
        Volumen volumen = purchase.getVolumen();
        int quantity = purchase.getQuantity() == null ? 1 : purchase.getQuantity();
        double price = purchase.getUnitPrice() != null ? purchase.getUnitPrice() : volumen.getPrecio();

        return GetPurchaseDto.builder()
                .idPurchase(purchase.getId())
                .numCreditCard(purchase.getNumCreditCard())
                .purchaseDate(purchase.getPurchaseDate())
                .idCart(purchase.getCart().getId())
                .idUser(user.getId())
                .username(user.getUsername())
                .fullName(user.getFullName())
                .idVolumen(volumen.getId())
                .nombreVolumen(volumen.getNombre())
                .nameManga(volumen.getManga() != null ? volumen.getManga().getName() : null)
                .posterPath(volumen.getPosterPath())
                .quantity(quantity)
                .precio(price)
                .total(Math.round(price * quantity * 100.0) / 100.0)
                .build();
    }
}
