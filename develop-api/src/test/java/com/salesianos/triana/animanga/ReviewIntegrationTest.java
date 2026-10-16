package com.salesianos.triana.animanga;

import com.jayway.jsonpath.JsonPath;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import static org.hamcrest.Matchers.*;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.delete;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@DisplayName("Reseñas")
class ReviewIntegrationTest extends IntegrationTest {

    @Test
    void valorarActualizaLaMediaYSoloHayUnaPorUsuario() throws Exception {
        String manga = mangaId("Jujutsu Kaisen 0");
        String token = newCustomer();

        sendJson(post("/mangas/" + manga + "/reviews"), token, json("rating", 1, "comment", "No me ha gustado"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.verifiedPurchase").value(false));
        sendJson(post("/mangas/" + manga + "/reviews"), token, json("rating", 3, "comment", "Mejor en la relectura"))
                .andExpect(status().isOk());

        getJson("/mangas/" + manga, token)
                .andExpect(jsonPath("$.myRating").value(3))
                .andExpect(jsonPath("$.ratingCount").value(2)); // la del seed + la nueva
        getJson("/mangas/" + manga + "/reviews", null)
                .andExpect(jsonPath("$.content[0].comment").value("Mejor en la relectura"));
    }

    @Test
    void validaLaPuntuacion() throws Exception {
        sendJson(post("/mangas/" + mangaId("Naruto") + "/reviews"), newCustomer(), json("rating", 6))
                .andExpect(status().isBadRequest());
        sendJson(post("/mangas/" + mangaId("Naruto") + "/reviews"), null, json("rating", 4))
                .andExpect(status().isUnauthorized());
    }

    @Test
    void soloElAutorOUnAdminBorranUnaResena() throws Exception {
        String manga = mangaId("Chainsaw Man");
        String author = newCustomer();
        String reviewId = JsonPath.read(sendJson(post("/mangas/" + manga + "/reviews"), author, json("rating", 5))
                .andReturn().getResponse().getContentAsString(), "$.id");

        perform(delete("/reviews/" + reviewId), newCustomer()).andExpect(status().isForbidden());
        perform(delete("/reviews/" + reviewId), adminToken()).andExpect(status().isNoContent());
        getJson("/mangas/" + manga + "/reviews?size=50", null)
                .andExpect(jsonPath("$.content[*].id", not(hasItem(reviewId))));
    }
}
