package com.salesianos.triana.animanga;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import java.time.YearMonth;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.*;

import static org.assertj.core.api.Assertions.assertThat;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.put;

@DisplayName("Compras simultáneas")
class ConcurrencyIntegrationTest extends IntegrationTest {

    @Test
    void dosClientesNoPuedenComprarLaMismaUltimaUnidad() throws Exception {
        String admin = adminToken();
        String volume = volumeId("Jujutsu Kaisen", 7);
        // Se deja una sola unidad en stock
        sendJson(put("/volumes/" + volume), admin, json("number", 7, "price", 8.5, "isbn", "9788467940077", "stock", 1));

        List<String> buyers = List.of(newCustomer(), newCustomer(), newCustomer());
        for (String buyer : buyers) {
            sendJson(post("/cart/items"), buyer, json("volumeId", volume, "quantity", 1));
        }

        String expiry = YearMonth.now().plusYears(2).format(DateTimeFormatter.ofPattern("MM/yy"));
        ExecutorService pool = Executors.newFixedThreadPool(buyers.size());
        CountDownLatch start = new CountDownLatch(1);
        List<Future<Integer>> results = new ArrayList<>();
        for (String buyer : buyers) {
            results.add(pool.submit(() -> {
                start.await();
                return sendJson(post("/orders"), buyer, checkout("4242424242424242", expiry))
                        .andReturn().getResponse().getStatus();
            }));
        }
        start.countDown();
        List<Integer> statuses = new ArrayList<>();
        for (Future<Integer> f : results) statuses.add(f.get(30, TimeUnit.SECONDS));
        pool.shutdown();

        assertThat(statuses).filteredOn(s -> s == 201).hasSize(1);
        assertThat(statuses).filteredOn(s -> s == 409).hasSize(2);
        assertThat(stockOf("Jujutsu Kaisen", 7)).isZero();
    }
}
