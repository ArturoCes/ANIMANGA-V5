package com.salesianos.triana.animanga.cart;

import com.salesianos.triana.animanga.catalog.Volume;
import com.salesianos.triana.animanga.user.User;
import jakarta.persistence.*;
import lombok.*;

import java.util.UUID;

/** Línea del carrito de un usuario. El carrito es el conjunto de sus líneas. */
@Entity
@Table(name = "cart_items", uniqueConstraints = @UniqueConstraint(columnNames = {"user_id", "volume_id"}))
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class CartItem {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @ManyToOne(optional = false, fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id")
    private User user;

    @ManyToOne(optional = false, fetch = FetchType.LAZY)
    @JoinColumn(name = "volume_id")
    private Volume volume;

    @Column(nullable = false)
    private int quantity;
}
