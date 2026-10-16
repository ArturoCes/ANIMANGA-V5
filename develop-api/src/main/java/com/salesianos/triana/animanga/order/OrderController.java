package com.salesianos.triana.animanga.order;

import com.salesianos.triana.animanga.common.PageResponse;
import com.salesianos.triana.animanga.order.OrderDtos.*;
import com.salesianos.triana.animanga.user.User;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.UUID;

@Tag(name = "Pedidos")
@RestController
@RequiredArgsConstructor
public class OrderController {

    private final OrderService orders;

    @Operation(summary = "Pagar el carrito y crear el pedido (pasarela simulada)")
    @PostMapping("/orders")
    @ResponseStatus(HttpStatus.CREATED)
    public OrderDto checkout(@AuthenticationPrincipal User user, @Valid @RequestBody CheckoutRequest req) {
        return orders.checkout(user, req);
    }

    @Operation(summary = "Mis pedidos")
    @GetMapping("/orders/me")
    public PageResponse<OrderDto> mine(@AuthenticationPrincipal User user,
                                       @RequestParam(defaultValue = "0") int page,
                                       @RequestParam(defaultValue = "20") int size) {
        return orders.mine(user, page, size);
    }

    @Operation(summary = "Detalle de un pedido propio")
    @GetMapping("/orders/{id}")
    public OrderDto get(@AuthenticationPrincipal User user, @PathVariable UUID id) {
        return orders.get(user, id);
    }

    @Operation(summary = "Cancelar un pedido que aún no se ha enviado")
    @PostMapping("/orders/{id}/cancel")
    public OrderDto cancel(@AuthenticationPrincipal User user, @PathVariable UUID id) {
        return orders.cancel(user, id);
    }

    @Tag(name = "Administración · Pedidos")
    @Operation(summary = "Buscar pedidos por estado, número o cliente")
    @GetMapping("/admin/orders")
    public PageResponse<OrderDto> search(@RequestParam(required = false) OrderStatus status,
                                         @RequestParam(required = false) String q,
                                         @RequestParam(defaultValue = "0") int page,
                                         @RequestParam(defaultValue = "10") int size) {
        return orders.search(status, q, page, size);
    }

    @Tag(name = "Administración · Pedidos")
    @Operation(summary = "Cambiar el estado de un pedido (enviado, entregado, cancelado)")
    @PatchMapping("/admin/orders/{id}/status")
    public OrderDto status(@PathVariable UUID id, @Valid @RequestBody StatusRequest req) {
        return orders.updateStatus(id, req.status());
    }
}
