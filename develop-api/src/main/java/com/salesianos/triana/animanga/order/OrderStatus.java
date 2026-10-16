package com.salesianos.triana.animanga.order;

import java.util.Set;

/** Ciclo de vida de un pedido: PAID → SHIPPED → DELIVERED, o PAID → CANCELLED. */
public enum OrderStatus {
    PAID, SHIPPED, DELIVERED, CANCELLED;

    public boolean canChangeTo(OrderStatus next) {
        return switch (this) {
            case PAID -> Set.of(SHIPPED, CANCELLED).contains(next);
            case SHIPPED -> next == DELIVERED;
            case DELIVERED, CANCELLED -> false;
        };
    }
}
