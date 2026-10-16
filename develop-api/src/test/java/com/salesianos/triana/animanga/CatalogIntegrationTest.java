package com.salesianos.triana.animanga;

import com.jayway.jsonpath.JsonPath;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.http.MediaType;
import org.springframework.mock.web.MockMultipartFile;

import java.nio.file.Files;
import java.nio.file.Path;
import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;
import static org.hamcrest.Matchers.*;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@DisplayName("Catálogo: búsqueda, filtros y administración")
class CatalogIntegrationTest extends IntegrationTest {

    @Test
    void filtraPorCategoriaEditorialYTexto() throws Exception {
        getJson("/mangas?category=Comedia", null)
                .andExpect(jsonPath("$.content[*].title", containsInAnyOrder("One Piece", "Spy×Family")));
        getJson("/mangas?publisher=Planeta Cómic", null)
                .andExpect(jsonPath("$.content[*].title", containsInAnyOrder("One Piece", "Naruto")));
        getJson("/mangas?q=kaisen", null)
                .andExpect(jsonPath("$.totalElements").value(2));
        getJson("/mangas?q=akutami", null) // también busca por autor
                .andExpect(jsonPath("$.totalElements").value(2));
    }

    @Test
    void filtraPorPrecioYOrdena() throws Exception {
        getJson("/mangas?minPrice=8.9&sort=price_asc", null)
                .andExpect(jsonPath("$.content[*].minPrice", everyItem(greaterThanOrEqualTo(8.9))));

        String body = getJson("/mangas?sort=price_desc&size=50", null).andReturn().getResponse().getContentAsString();
        List<Double> prices = JsonPath.read(body, "$.content[*].minPrice");
        assertThat(prices).isSortedAccordingTo((a, b) -> Double.compare(b, a));
    }

    @Test
    void paginaLosResultados() throws Exception {
        getJson("/mangas?size=3&page=0", null)
                .andExpect(jsonPath("$.content", hasSize(3)))
                .andExpect(jsonPath("$.totalElements").value(greaterThanOrEqualTo(8)))
                .andExpect(jsonPath("$.last").value(false));
    }

    @Test
    void laFichaIncluyeVolumenesPersonajesYValoracion() throws Exception {
        getJson("/mangas/" + mangaId("Spy×Family"), null)
                .andExpect(jsonPath("$.volumes", hasSize(4)))
                .andExpect(jsonPath("$.volumes[0].number").value(1))
                .andExpect(jsonPath("$.characters[*].name", hasItem("Anya Forger")))
                .andExpect(jsonPath("$.ratingCount").value(greaterThan(0)))
                .andExpect(jsonPath("$.favorite").value(false));
    }

    @Test
    void laPortadaTieneSeccionesYRecomendaciones() throws Exception {
        getJson("/mangas/home", login("demo", USER_PASSWORD))
                .andExpect(jsonPath("$.latest", not(empty())))
                .andExpect(jsonPath("$.bestSellers", not(empty())))
                .andExpect(jsonPath("$.topRated", not(empty())))
                .andExpect(jsonPath("$.recommended", not(empty())));
    }

    @Test
    void favoritos() throws Exception {
        String token = newCustomer();
        String naruto = mangaId("Naruto");
        perform(put("/users/me/favorites/" + naruto), token).andExpect(status().isNoContent());
        getJson("/users/me/favorites", token).andExpect(jsonPath("$[*].title", contains("Naruto")));
        getJson("/mangas/" + naruto, token).andExpect(jsonPath("$.favorite").value(true));
        perform(delete("/users/me/favorites/" + naruto), token).andExpect(status().isNoContent());
        getJson("/users/me/favorites", token).andExpect(jsonPath("$", empty()));
    }

    @Test
    void elAdminCreaUnMangaConVolumenYPersonaje() throws Exception {
        String admin = adminToken();
        String categoryId = JsonPath.read(sendJson(post("/categories"), admin,
                        json("name", "Deportes", "description", "Mangas de deporte"))
                .andExpect(status().isCreated()).andReturn().getResponse().getContentAsString(), "$.id");

        String manga = """
                {"title":"Haikyu!!","author":"Haruichi Furudate","publisher":"Planeta Cómic",
                 "releaseDate":"2012-07-03","synopsis":"Voleibol de instituto.","categoryIds":["%s"]}
                """.formatted(categoryId);

        String created = perform(multipart("/mangas")
                .file(new MockMultipartFile("manga", "", MediaType.APPLICATION_JSON_VALUE, manga.getBytes()))
                .file(image("cover")), admin)
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.title").value("Haikyu!!"))
                .andExpect(jsonPath("$.categories[0].name").value("Deportes"))
                .andReturn().getResponse().getContentAsString();
        String mangaId = JsonPath.read(created, "$.id");

        perform(multipart("/mangas/" + mangaId + "/volumes")
                .file(new MockMultipartFile("volume", "", MediaType.APPLICATION_JSON_VALUE,
                        json("number", 1, "price", 7.95, "isbn", "9788491460001", "stock", 10).getBytes()))
                .file(image("cover")), admin)
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.title").value("Haikyu!! 1"));

        perform(multipart("/mangas/" + mangaId + "/characters")
                .file(new MockMultipartFile("character", "", MediaType.APPLICATION_JSON_VALUE,
                        json("name", "Shoyo Hinata", "age", 15, "description", "Rematador").getBytes())), admin)
                .andExpect(status().isCreated());

        getJson("/mangas/" + mangaId, null)
                .andExpect(jsonPath("$.minPrice").value(7.95))
                .andExpect(jsonPath("$.inStock").value(true))
                .andExpect(jsonPath("$.characters[0].name").value("Shoyo Hinata"));

        perform(delete("/mangas/" + mangaId), admin).andExpect(status().isNoContent());
        getJson("/mangas/" + mangaId, null).andExpect(status().isNotFound());
    }

    @Test
    void rechazaFicherosQueNoSonImagenes() throws Exception {
        String admin = adminToken();
        perform(multipart("/mangas/" + mangaId("Naruto") + "/cover").file(
                new MockMultipartFile("cover", "virus.jpg", "image/jpeg", "#!/bin/sh echo hola".getBytes()))
                .with(r -> { r.setMethod("PUT"); return r; }), admin)
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.message", containsString("imágenes")));
    }

    @Test
    void borrarUnaCategoriaEnUsoLaQuitaDeLosMangas() throws Exception {
        String admin = adminToken();
        String body = getJson("/categories", null).andReturn().getResponse().getContentAsString();
        List<String> ids = JsonPath.read(body, "$[?(@.name == 'Drama')].id");
        perform(delete("/categories/" + ids.get(0)), admin).andExpect(status().isNoContent());
        getJson("/mangas/" + mangaId("Ataque a los Titanes"), null)
                .andExpect(jsonPath("$.categories[*].name", not(hasItem("Drama"))));
    }

    private static MockMultipartFile image(String part) throws Exception {
        byte[] jpg = Files.readAllBytes(Path.of("src/main/resources/seed/covers/char-anya.jpg"));
        return new MockMultipartFile(part, "portada.jpg", "image/jpeg", jpg);
    }
}
