package com.salesianos.triana.animanga;

import com.jayway.jsonpath.JsonPath;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import java.util.regex.Matcher;
import java.util.regex.Pattern;

import static org.assertj.core.api.Assertions.assertThat;
import static org.hamcrest.Matchers.*;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@DisplayName("Autenticación y cuentas")
class AuthIntegrationTest extends IntegrationTest {

    @Test
    void loginCorrectoDevuelveTokensYUsuario() throws Exception {
        sendJson(post("/auth/login"), null, json("username", "demo", "password", USER_PASSWORD))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.accessToken").isNotEmpty())
                .andExpect(jsonPath("$.refreshToken").isNotEmpty())
                .andExpect(jsonPath("$.user.username").value("demo"))
                .andExpect(jsonPath("$.user.role").value("USER"))
                .andExpect(jsonPath("$.user.password").doesNotExist());
    }

    @Test
    void elLoginNoRevelaSiElUsuarioExiste() throws Exception {
        String wrongPassword = sendJson(post("/auth/login"), null, json("username", "demo", "password", "mala"))
                .andExpect(status().isUnauthorized())
                .andReturn().getResponse().getContentAsString();
        String unknownUser = sendJson(post("/auth/login"), null, json("username", "nadie", "password", "mala"))
                .andExpect(status().isUnauthorized())
                .andReturn().getResponse().getContentAsString();
        assertThat((String) JsonPath.read(wrongPassword, "$.message"))
                .isEqualTo(JsonPath.read(unknownUser, "$.message"));
    }

    @Test
    void bloqueaElLoginTrasCincoIntentosFallidos() throws Exception {
        for (int i = 0; i < 5; i++) {
            sendJson(post("/auth/login"), null, json("username", "laura", "password", "incorrecta"))
                    .andExpect(status().isUnauthorized());
        }
        // Ni siquiera la contraseña buena entra mientras dura el bloqueo
        sendJson(post("/auth/login"), null, json("username", "laura", "password", USER_PASSWORD))
                .andExpect(status().isTooManyRequests())
                .andExpect(jsonPath("$.message", containsString("Demasiados intentos")));
    }

    @Test
    void registroCreaClienteYLeEnviaElEmailDeVerificacion() throws Exception {
        sendJson(post("/auth/register"), null, json("username", "nuevo1", "fullName", "Nuevo Cliente",
                "email", "nuevo1@test.dev", "password", "Secreta123"))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.user.role").value("USER"))
                .andExpect(jsonPath("$.user.emailVerified").value(false));

        assertThat(mail.outbox()).anySatisfy(m -> {
            assertThat(m.to()).isEqualTo("nuevo1@test.dev");
            assertThat(m.body()).contains("?verify=");
        });
    }

    @Test
    void registroRechazaDuplicadosYDatosNoValidos() throws Exception {
        sendJson(post("/auth/register"), null, json("username", "demo", "fullName", "X",
                "email", "otro@test.dev", "password", "Secreta123"))
                .andExpect(status().isConflict());
        sendJson(post("/auth/register"), null, json("username", "a", "fullName", "",
                "email", "no-es-email", "password", "123"))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.fieldErrors", hasSize(greaterThanOrEqualTo(3))));
    }

    @Test
    void elRefreshTokenRotaYNoSePuedeReutilizar() throws Exception {
        String body = sendJson(post("/auth/login"), null, json("username", "carlos", "password", USER_PASSWORD))
                .andReturn().getResponse().getContentAsString();
        String refresh = JsonPath.read(body, "$.refreshToken");

        sendJson(post("/auth/refresh"), null, json("refreshToken", refresh))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.accessToken").isNotEmpty())
                .andExpect(jsonPath("$.refreshToken", not(refresh)));
        sendJson(post("/auth/refresh"), null, json("refreshToken", refresh))
                .andExpect(status().isUnauthorized());
    }

    @Test
    void rutasProtegidasExigenUnTokenValido() throws Exception {
        getJson("/users/me", null).andExpect(status().isUnauthorized());
        getJson("/users/me", "token-falso").andExpect(status().isUnauthorized());
        getJson("/users/me", login("marta", USER_PASSWORD))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.username").value("marta"));
    }

    @Test
    void recuperarContrasenaConElEnlaceDelEmail() throws Exception {
        String token = newCustomer();
        String email = JsonPath.read(getJson("/users/me", token).andReturn().getResponse().getContentAsString(), "$.email");
        String username = JsonPath.read(getJson("/users/me", token).andReturn().getResponse().getContentAsString(), "$.username");
        mail.clearOutbox();

        sendJson(post("/auth/forgot-password"), null, json("email", email)).andExpect(status().isAccepted());
        // Un email inexistente responde igual (no se revela qué cuentas existen)
        sendJson(post("/auth/forgot-password"), null, json("email", "nadie@test.dev")).andExpect(status().isAccepted());

        String resetToken = tokenFromLastMail("reset");
        sendJson(post("/auth/reset-password"), null, json("token", resetToken, "password", "NuevaClave99"))
                .andExpect(status().isNoContent());
        // El token es de un solo uso
        sendJson(post("/auth/reset-password"), null, json("token", resetToken, "password", "OtraClave99"))
                .andExpect(status().isBadRequest());

        login(username, "NuevaClave99");
    }

    @Test
    void verificarEmail() throws Exception {
        String token = newCustomer();
        String verifyToken = tokenFromLastMail("verify");
        sendJson(post("/auth/verify-email"), null, json("token", verifyToken))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.emailVerified").value(true));
        getJson("/users/me", token).andExpect(jsonPath("$.emailVerified").value(true));
    }

    @Test
    void cambiarContrasenaExigeLaActual() throws Exception {
        String token = newCustomer();
        sendJson(put("/users/me/password"), token, json("currentPassword", "mala", "newPassword", "OtraClave99"))
                .andExpect(status().isBadRequest());
        sendJson(put("/users/me/password"), token, json("currentPassword", "Secreta123", "newPassword", "OtraClave99"))
                .andExpect(status().isNoContent());
    }

    private String tokenFromLastMail(String param) {
        String body = mail.outbox().get(mail.outbox().size() - 1).body();
        Matcher m = Pattern.compile("\\?" + param + "=([A-Za-z0-9_-]+)").matcher(body);
        assertThat(m.find()).as("el email contiene el enlace").isTrue();
        return m.group(1);
    }
}
