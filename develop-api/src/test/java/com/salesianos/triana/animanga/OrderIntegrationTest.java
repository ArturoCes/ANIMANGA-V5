package com.salesianos.triana.animanga;

import com.jayway.jsonpath.JsonPath;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import java.time.YearMonth;
import java.time.format.DateTimeFormatter;

import static org.assertj.core.api.Assertions.assertThat;
import static org.hamcrest.Matchers.*;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@DisplayName("Carrito y pedidos")
class OrderIntegrationTest extends IntegrationTest {

    private static final String CARD = "4242 4242 4242 4242";
    private static final String FUTURE = YearMonth.now().plusYears(3).format(DateTimeFormatter.ofPattern("MM/yy"));

    @Test
    void elCarritoControlaElStock() throws Exception {
        String token = newCustomer();
        // Ataque a los Titanes 2 está agotado en los datos de ejemplo
        sendJson(post("/cart/items"), token, json("volumeId", volumeId("Ataque a los Titanes", 2), "quantity", 1))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.message", containsString("agotado")));

        int stock = stockOf("Guardianes de la Noche", 4);
        sendJson(post("/cart/items"), token, json("volumeId", volumeId("Guardianes de la Noche", 4), "quantity", stock + 1))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.message", containsString("Solo quedan")));
    }

    @Test
    void anadirCambiarYQuitarDelCarrito() throws Exception {
        String token = newCustomer();
        String v1 = volumeId("One Piece", 1);
        sendJson(post("/cart/items"), token, json("volumeId", v1, "quantity", 2))
                .andExpect(jsonPath("$.totalItems").value(2))
                .andExpect(jsonPath("$.total").value(17.0));
        sendJson(put("/cart/items/" + v1), token, json("quantity", 1))
                .andExpect(jsonPath("$.items[0].quantity").value(1));
        perform(delete("/cart/items/" + v1), token)
                .andExpect(jsonPath("$.items", empty()));
    }

    @Test
    void pagarCreaElPedidoDescuentaStockYVaciaElCarrito() throws Exception {
        String token = newCustomer();
        String volume = volumeId("Naruto", 1);
        int before = stockOf("Naruto", 1);
        sendJson(post("/cart/items"), token, json("volumeId", volume, "quantity", 2));

        String order = sendJson(post("/orders"), token, checkout(CARD, FUTURE))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.number", startsWith("AM-")))
                .andExpect(jsonPath("$.status").value("PAID"))
                .andExpect(jsonPath("$.cardLast4").value("4242"))
                .andExpect(jsonPath("$.total").value(17.9))
                .andExpect(jsonPath("$.shipping.city").value("Sevilla"))
                .andExpect(jsonPath("$.items[0].quantity").value(2))
                .andReturn().getResponse().getContentAsString();

        assertThat(order).doesNotContain("4242 4242").doesNotContain("4242424242424242");
        assertThat(stockOf("Naruto", 1)).isEqualTo(before - 2);
        getJson("/cart", token).andExpect(jsonPath("$.items", empty()));
        getJson("/orders/me", token).andExpect(jsonPath("$.content", hasSize(1)));
    }

    @Test
    void validaLaTarjetaYElCarrito() throws Exception {
        String token = newCustomer();
        sendJson(post("/orders"), token, checkout(CARD, FUTURE))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.message", containsString("vacío")));

        sendJson(post("/cart/items"), token, json("volumeId", volumeId("One Piece", 2), "quantity", 1));
        sendJson(post("/orders"), token, checkout("4242 4242 4242 4241", FUTURE))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.message", containsString("tarjeta")));
        sendJson(post("/orders"), token, checkout(CARD, "01/20"))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.message", containsString("caducada")));
        String badAddress = checkout(CARD, FUTURE).replace("41001", "123");
        sendJson(post("/orders"), token, badAddress).andExpect(status().isBadRequest());
    }

    @Test
    void nadieVeLosPedidosDeOtro() throws Exception {
        String owner = newCustomer();
        sendJson(post("/cart/items"), owner, json("volumeId", volumeId("One Piece", 3), "quantity", 1));
        String orderId = JsonPath.read(sendJson(post("/orders"), owner, checkout(CARD, FUTURE))
                .andReturn().getResponse().getContentAsString(), "$.id");

        String other = newCustomer();
        getJson("/orders/" + orderId, other).andExpect(status().isNotFound());
        perform(post("/orders/" + orderId + "/cancel"), other).andExpect(status().isNotFound());
        getJson("/orders/" + orderId, owner).andExpect(status().isOk());
        getJson("/orders/" + orderId, adminToken()).andExpect(status().isOk());
    }

    @Test
    void cancelarDevuelveElStock() throws Exception {
        String token = newCustomer();
        int before = stockOf("Spy×Family", 2);
        sendJson(post("/cart/items"), token, json("volumeId", volumeId("Spy×Family", 2), "quantity", 3));
        String orderId = JsonPath.read(sendJson(post("/orders"), token, checkout(CARD, FUTURE))
                .andReturn().getResponse().getContentAsString(), "$.id");
        assertThat(stockOf("Spy×Family", 2)).isEqualTo(before - 3);

        perform(post("/orders/" + orderId + "/cancel"), token)
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.status").value("CANCELLED"));
        assertThat(stockOf("Spy×Family", 2)).isEqualTo(before);
    }

    @Test
    void elAdminGestionaElEstadoSiguiendoElFlujo() throws Exception {
        String token = newCustomer();
        sendJson(post("/cart/items"), token, json("volumeId", volumeId("Chainsaw Man", 1), "quantity", 1));
        String orderId = JsonPath.read(sendJson(post("/orders"), token, checkout(CARD, FUTURE))
                .andReturn().getResponse().getContentAsString(), "$.id");
        String admin = adminToken();

        sendJson(patch("/admin/orders/" + orderId + "/status"), admin, json("status", "DELIVERED"))
                .andExpect(status().isConflict()); // no se puede entregar sin enviar
        sendJson(patch("/admin/orders/" + orderId + "/status"), admin, json("status", "SHIPPED"))
                .andExpect(jsonPath("$.status").value("SHIPPED"));
        // Una vez enviado el cliente ya no puede cancelarlo
        perform(post("/orders/" + orderId + "/cancel"), token).andExpect(status().isConflict());
        sendJson(patch("/admin/orders/" + orderId + "/status"), admin, json("status", "DELIVERED"))
                .andExpect(jsonPath("$.status").value("DELIVERED"));

        getJson("/admin/orders?status=DELIVERED&q=" + JsonPath.read(getJson("/orders/" + orderId, token)
                .andReturn().getResponse().getContentAsString(), "$.number"), admin)
                .andExpect(jsonPath("$.content", hasSize(1)));
    }

    @Test
    void lasEstadisticasReflejanLosPedidos() throws Exception {
        getJson("/admin/stats", adminToken())
                .andExpect(jsonPath("$.totals.mangas").value(greaterThanOrEqualTo(8)))
                .andExpect(jsonPath("$.totals.revenue").value(greaterThan(0.0)))
                .andExpect(jsonPath("$.revenueByMonth", hasSize(6)))
                .andExpect(jsonPath("$.topVolumes", not(empty())))
                .andExpect(jsonPath("$.lowStock[*].stock", everyItem(lessThanOrEqualTo(5))));
    }
}
