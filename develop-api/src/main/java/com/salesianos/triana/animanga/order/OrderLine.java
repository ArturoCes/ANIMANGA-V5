package com.salesianos.triana.animanga.order;

import com.salesianos.triana.animanga.catalog.Volume;
import jakarta.persistence.*;
import lombok.*;

import java.math.BigDecimal;
import java.util.UUID;

/**
 * Línea de pedido. Guarda una copia del título, la portada y el precio para que
 * el pedido no cambie si después se edita o se borra el volumen.
 */
@Entity
@Table(name = "order_lines")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class OrderLine {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @ManyToOne(optional = false, fetch = FetchType.LAZY)
    @JoinColumn(name = "order_id")
    private Order order;

    /** Puede quedar a null si el volumen se elimina del catálogo. */
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "volume_id")
    private Volume volume;

    @Column(nullable = false, length = 150)
    private String volumeTitle;

    @Column(length = 150)
    private String mangaTitle;

    private java.util.UUID mangaId;

    private String coverImage;

    @Column(nullable = false, precision = 8, scale = 2)
    private BigDecimal unitPrice;

    @Column(nullable = false)
    private int quantity;

    public BigDecimal subtotal() {
        return unitPrice.multiply(BigDecimal.valueOf(quantity));
    }
}
