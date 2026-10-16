package com.salesianos.triana.animanga.order;

import jakarta.validation.Valid;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;

import java.math.BigDecimal;
import java.time.Instant;
import java.util.List;
import java.util.UUID;

public final class OrderDtos {

    private OrderDtos() {}

    public record ShippingDto(
            @NotBlank(message = "El nombre del destinatario es obligatorio") @Size(max = 100) String fullName,
            @NotBlank(message = "La dirección es obligatoria") @Size(max = 200) String address,
            @NotBlank(message = "La ciudad es obligatoria") @Size(max = 80) String city,
            @NotBlank @Pattern(regexp = "^\\d{5}$", message = "El código postal debe tener 5 dígitos") String postalCode,
            @NotBlank @Pattern(regexp = "^\\+?[0-9 ]{9,15}$", message = "El teléfono no es válido") String phone) {

        static ShippingDto from(ShippingAddress s) {
            return new ShippingDto(s.getFullName(), s.getAddress(), s.getCity(), s.getPostalCode(), s.getPhone());
        }

        ShippingAddress toEntity() {
            return new ShippingAddress(fullName.trim(), address.trim(), city.trim(), postalCode.trim(), phone.trim());
        }
    }

    public record CheckoutRequest(
            @NotNull(message = "Indica la dirección de envío") @Valid ShippingDto shipping,
            @NotBlank(message = "Introduce el número de tarjeta") String cardNumber,
            @NotBlank(message = "Introduce la caducidad de la tarjeta") String cardExpiry,
            @NotBlank(message = "Introduce el CVC") String cardCvc) {}

    public record StatusRequest(@NotNull(message = "Indica el estado") OrderStatus status) {}

    public record Customer(UUID id, String username, String fullName, String email) {}

    public record OrderLineDto(UUID volumeId, UUID mangaId, String volumeTitle, String mangaTitle,
                               String coverImage, BigDecimal unitPrice, int quantity, BigDecimal subtotal) {}

    public record OrderDto(UUID id, String number, OrderStatus status, Instant createdAt, Instant updatedAt,
                           Customer customer, ShippingDto shipping, String cardLast4, BigDecimal total,
                           int totalUnits, List<OrderLineDto> items) {

        public static OrderDto from(Order o) {
            var u = o.getUser();
            return new OrderDto(o.getId(), o.getNumber(), o.getStatus(), o.getCreatedAt(), o.getUpdatedAt(),
                    new Customer(u.getId(), u.getUsername(), u.getFullName(), u.getEmail()),
                    ShippingDto.from(o.getShipping()), o.getCardLast4(), o.getTotal(), o.totalUnits(),
                    o.getLines().stream().map(l -> new OrderLineDto(
                            l.getVolume() == null ? null : l.getVolume().getId(), l.getMangaId(),
                            l.getVolumeTitle(), l.getMangaTitle(), l.getCoverImage(), l.getUnitPrice(),
                            l.getQuantity(), l.subtotal())).toList());
        }
    }
}
