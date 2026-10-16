package com.salesianos.triana.animanga;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.mock.web.MockMultipartFile;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@DisplayName("Permisos por rol")
class SecurityIntegrationTest extends IntegrationTest {

    @Test
    void elCatalogoEsPublicoParaLeer() throws Exception {
        getJson("/mangas", null).andExpect(status().isOk());
        getJson("/mangas/home", null).andExpect(status().isOk());
        getJson("/categories", null).andExpect(status().isOk());
        getJson("/mangas/" + mangaId("Naruto"), null).andExpect(status().isOk());
        getJson("/mangas/" + mangaId("Naruto") + "/reviews", null).andExpect(status().isOk());
        getJson("/images/nar-01.jpg", null).andExpect(status().isOk());
    }

    @Test
    void unClienteNoPuedeAdministrarElCatalogo() throws Exception {
        String user = login("demo", USER_PASSWORD);
        String naruto = mangaId("Naruto");

        sendJson(post("/categories"), user, json("name", "Hackeo")).andExpect(status().isForbidden());
        perform(delete("/mangas/" + naruto), user).andExpect(status().isForbidden());
        perform(delete("/volumes/" + volumeId("Naruto", 1)), user).andExpect(status().isForbidden());
        sendJson(put("/volumes/" + volumeId("Naruto", 1)), user,
                json("number", 1, "price", 0.01, "stock", 999)).andExpect(status().isForbidden());
        perform(multipart("/mangas").file(new MockMultipartFile("cover", "c.jpg", "image/jpeg", new byte[]{1})), user)
                .andExpect(status().isForbidden());
    }

    @Test
    void unClienteNoPuedeEntrarEnLaAdministracion() throws Exception {
        String user = login("demo", USER_PASSWORD);
        getJson("/admin/stats", user).andExpect(status().isForbidden());
        getJson("/admin/users", user).andExpect(status().isForbidden());
        getJson("/admin/orders", user).andExpect(status().isForbidden());
        sendJson(patch("/admin/users/00000000-0000-0000-0000-000000000000/role"), user, json("role", "ADMIN"))
                .andExpect(status().isForbidden());
    }

    @Test
    void sinSesionNoHayCarritoNiPedidos() throws Exception {
        getJson("/cart", null).andExpect(status().isUnauthorized());
        getJson("/orders/me", null).andExpect(status().isUnauthorized());
        getJson("/admin/stats", null).andExpect(status().isUnauthorized());
    }

    @Test
    void elAdministradorAccedeAlPanel() throws Exception {
        String admin = adminToken();
        getJson("/admin/stats", admin).andExpect(status().isOk());
        getJson("/admin/users", admin).andExpect(status().isOk());
        getJson("/admin/orders", admin).andExpect(status().isOk());
    }

    @Test
    void lasImagenesNoPermitenSalirDelDirectorio() throws Exception {
        getJson("/images/..%2F..%2Fpom.xml", null).andExpect(status().is4xxClientError());
        getJson("/images/no-existe.jpg", null).andExpect(status().isNotFound());
    }
}
