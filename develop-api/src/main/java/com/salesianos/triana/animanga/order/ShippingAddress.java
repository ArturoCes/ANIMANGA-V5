package com.salesianos.triana.animanga.order;

import jakarta.persistence.Column;
import jakarta.persistence.Embeddable;
import lombok.*;

@Embeddable
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ShippingAddress {

    @Column(name = "ship_name", nullable = false, length = 100)
    private String fullName;

    @Column(name = "ship_address", nullable = false, length = 200)
    private String address;

    @Column(name = "ship_city", nullable = false, length = 80)
    private String city;

    @Column(name = "ship_postal_code", nullable = false, length = 10)
    private String postalCode;

    @Column(name = "ship_phone", nullable = false, length = 20)
    private String phone;
}
