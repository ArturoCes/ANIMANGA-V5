package com.salesianos.triana.backend.Animangav4.service;

import com.salesianos.triana.backend.Animangav4.dtos.CreatePurchaseDto;
import com.salesianos.triana.backend.Animangav4.dtos.GetMangaDto;
import com.salesianos.triana.backend.Animangav4.dtos.GetPurchaseDto;
import com.salesianos.triana.backend.Animangav4.dtos.PurchaseDtoConverter;
import com.salesianos.triana.backend.Animangav4.exception.EmptyMangaListException;
import com.salesianos.triana.backend.Animangav4.exception.ListNotFoundException;
import com.salesianos.triana.backend.Animangav4.models.*;
import com.salesianos.triana.backend.Animangav4.repository.CartRepository;
import com.salesianos.triana.backend.Animangav4.repository.PurchaseRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageImpl;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

@Service
@RequiredArgsConstructor
public class PurchaseService {

    private final PurchaseRepository purchaseRepository;

    private final CartRepository cartRepository;

    private final PurchaseDtoConverter purchaseDtoConverter;
    public Page<GetPurchaseDto> save(User user, CreatePurchaseDto createPurchaseDto, Pageable pageable) {
        Optional<Cart> carrito = cartRepository.findById(createPurchaseDto.getIdCart());
        List<Purchase> listaCompras = new ArrayList<>();

        if(carrito.isPresent()) {
            List<Item> items = new ArrayList<>(carrito.get().getItems());
            for (Item i: items) {
                Purchase p = Purchase.builder()
                        .cart(carrito.get())
                        .numCreditCard(createPurchaseDto.getNumCreditCard())
                        .volumen(i.getVolumen())
                        .build();
                purchaseRepository.save(p);
                listaCompras.add(p);
                carrito.get().getItems().remove(i);
            }
            cartRepository.save(carrito.get());
        }

        Page<GetPurchaseDto> page = new PageImpl<>(listaCompras, pageable, listaCompras.size()).map(purchaseDtoConverter::purchaseToGetPurchaseDto);

        return page;

    }


    public Page<Purchase> findAll(Pageable pageable) {
        Page<Purchase> list = purchaseRepository.findAll(pageable);

        if (list.isEmpty()) {
            throw new ListNotFoundException(Purchase.class);
        } else {
            return list;
        }
    }
}
