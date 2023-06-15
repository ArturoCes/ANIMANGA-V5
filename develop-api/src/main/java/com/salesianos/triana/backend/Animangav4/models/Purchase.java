package com.salesianos.triana.backend.Animangav4.models;


import lombok.*;
import org.hibernate.annotations.GenericGenerator;
import org.hibernate.annotations.Parameter;
import org.springframework.data.annotation.CreatedDate;
import org.springframework.data.jpa.domain.support.AuditingEntityListener;

import javax.persistence.*;
import java.io.Serializable;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

@Entity
@Table(name = "purchase")
@EntityListeners(AuditingEntityListener.class)
@Getter
@Setter
@AllArgsConstructor
@NoArgsConstructor
@Builder

public class Purchase implements Serializable{
    @Id
    @GeneratedValue(generator = "UUID")
    @GenericGenerator(
            name = "UUID",
            strategy = "org.hibernate.id.UUIDGenerator",
            parameters = {
                    @Parameter(
                            name = "uuid_gen_strategy_class",
                            value = "org.hibernate.id.uuid.CustomVersionOneStrategy"

                    )
            }
    )
    @Column(columnDefinition = "uuid")
    private UUID id;

    @CreatedDate
    private LocalDateTime purchaseDate;

    private String numCreditCard;

    @ManyToOne
    @JoinColumn(name = "cart", foreignKey = @ForeignKey(name = "FK_PURCHASE_CART"))
    private Cart cart;

    @ManyToOne
    @JoinColumn(name = "volumen", foreignKey = @ForeignKey(name = "FK_PURCHASE_VOLUMEN"))
    private Volumen volumen;


}
