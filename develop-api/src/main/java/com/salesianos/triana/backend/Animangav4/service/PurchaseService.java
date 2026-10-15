package com.salesianos.triana.backend.Animangav4.service;

import com.salesianos.triana.backend.Animangav4.dtos.CreatePurchaseDto;
import com.salesianos.triana.backend.Animangav4.dtos.GetPurchaseDto;
import com.salesianos.triana.backend.Animangav4.dtos.PurchaseDtoConverter;
import com.salesianos.triana.backend.Animangav4.exception.BadRequestException;
import com.salesianos.triana.backend.Animangav4.exception.EntityNotFoundException;
import com.salesianos.triana.backend.Animangav4.exception.ForbiddenException;
import com.salesianos.triana.backend.Animangav4.models.*;
import com.salesianos.triana.backend.Animangav4.repository.CartRepository;
import com.salesianos.triana.backend.Animangav4.repository.PurchaseRepository;
import com.salesianos.triana.backend.Animangav4.repository.VolumenRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageImpl;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.ArrayList;
import java.util.List;

@Service
@RequiredArgsConstructor
public class PurchaseService {

    private final PurchaseRepository purchaseRepository;
    private final CartRepository cartRepository;
    private final VolumenRepository volumenRepository;
    private final PurchaseDtoConverter purchaseDtoConverter;

    /**
     * Convierte el carrito del usuario en compras. Es una pasarela simulada:
     * se valida el formato de la tarjeta (Luhn) pero solo se guarda enmascarada.
     */
    @Transactional
    public Page<GetPurchaseDto> save(User user, CreatePurchaseDto dto, Pageable pageable) {
        Cart cart = cartRepository.findById(dto.getIdCart())
                .orElseThrow(() -> new EntityNotFoundException(dto.getIdCart().toString(), Cart.class));

        if (!cart.getUser().getId().equals(user.getId())) {
            throw new ForbiddenException("Solo puede pagar su propio carrito");
        }
        if (cart.getItems().isEmpty()) {
            throw new BadRequestException("El carrito está vacío");
        }

        String maskedCard = maskCard(dto.getNumCreditCard());
        List<Purchase> compras = new ArrayList<>();

        for (Item item : new ArrayList<>(cart.getItems())) {
            Volumen volumen = item.getVolumen();
            int quantity = item.getQuantity() == null ? 1 : item.getQuantity();
            if (volumen.getCantidad() == null || volumen.getCantidad() < quantity) {
                throw new BadRequestException("No hay stock suficiente de " + volumen.getNombre());
            }
            volumen.setCantidad(volumen.getCantidad() - quantity);
            volumenRepository.save(volumen);

            compras.add(purchaseRepository.save(Purchase.builder()
                    .cart(cart)
                    .numCreditCard(maskedCard)
                    .volumen(volumen)
                    .quantity(quantity)
                    .unitPrice(volumen.getPrecio())
                    .build()));
            cart.getItems().remove(item);
        }
        cartRepository.save(cart);

        return new PageImpl<>(compras, pageable, compras.size())
                .map(purchaseDtoConverter::purchaseToGetPurchaseDto);
    }

    @Transactional(readOnly = true)
    public Page<GetPurchaseDto> findAll(Pageable pageable) {
        return purchaseRepository.findAllByOrderByPurchaseDateDesc(pageable)
                .map(purchaseDtoConverter::purchaseToGetPurchaseDto);
    }

    @Transactional(readOnly = true)
    public Page<GetPurchaseDto> findMine(User user, Pageable pageable) {
        return purchaseRepository.findByCartUserOrderByPurchaseDateDesc(user, pageable)
                .map(purchaseDtoConverter::purchaseToGetPurchaseDto);
    }

    static String maskCard(String raw) {
        String digits = raw == null ? "" : raw.replaceAll("[\\s-]", "");
        if (!digits.matches("\\d{13,19}") || !passesLuhn(digits)) {
            throw new BadRequestException("El número de tarjeta no es válido");
        }
        return "**** **** **** " + digits.substring(digits.length() - 4);
    }

    private static boolean passesLuhn(String digits) {
        int sum = 0;
        boolean doubleIt = false;
        for (int i = digits.length() - 1; i >= 0; i--) {
            int n = digits.charAt(i) - '0';
            if (doubleIt) {
                n *= 2;
                if (n > 9) n -= 9;
            }
            sum += n;
            doubleIt = !doubleIt;
        }
        return sum % 10 == 0;
    }
}
