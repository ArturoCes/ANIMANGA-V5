package com.salesianos.triana.animanga;

import com.jayway.jsonpath.JsonPath;
import com.salesianos.triana.animanga.mail.MailService;
import com.salesianos.triana.animanga.security.LoginAttemptService;
import org.junit.jupiter.api.BeforeEach;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.webmvc.test.autoconfigure.AutoConfigureMockMvc;
import org.springframework.http.MediaType;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.ResultActions;
import org.springframework.test.web.servlet.request.AbstractMockHttpServletRequestBuilder;

import java.util.List;
import java.util.UUID;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

/**
 * Base de los tests de integración: arranca la aplicación completa con H2 en memoria
 * y los datos de demostración, y prueba la API a través de HTTP simulado (MockMvc).
 */
@SpringBootTest
@AutoConfigureMockMvc
@ActiveProfiles("test")
public abstract class IntegrationTest {

    protected static final String ADMIN_PASSWORD = "Admin1234";
    protected static final String USER_PASSWORD = "Demo1234";

    @Autowired
    protected MockMvc mvc;

    @Autowired
    protected MailService mail;

    @Autowired
    private LoginAttemptService loginAttempts;

    @BeforeEach
    void resetState() {
        loginAttempts.reset();
        mail.clearOutbox();
    }

    // ------------------------------------------------------------- Peticiones

    protected ResultActions perform(AbstractMockHttpServletRequestBuilder<?> request, String token) throws Exception {
        if (token != null) request.header("Authorization", "Bearer " + token);
        return mvc.perform(request);
    }

    protected ResultActions getJson(String url, String token) throws Exception {
        return perform(get(url), token);
    }

    protected ResultActions sendJson(AbstractMockHttpServletRequestBuilder<?> request, String token, String json)
            throws Exception {
        return perform(request.contentType(MediaType.APPLICATION_JSON).content(json), token);
    }

    // ------------------------------------------------------------- Sesiones

    protected String login(String username, String password) throws Exception {
        String body = mvc.perform(post("/auth/login").contentType(MediaType.APPLICATION_JSON)
                        .content(json("username", username, "password", password)))
                .andExpect(status().isOk())
                .andReturn().getResponse().getContentAsString();
        return JsonPath.read(body, "$.accessToken");
    }

    protected String adminToken() throws Exception {
        return login("admin", ADMIN_PASSWORD);
    }

    /** Crea un cliente nuevo para el test y devuelve su token. */
    protected String newCustomer() throws Exception {
        String username = "u" + UUID.randomUUID().toString().substring(0, 8);
        String body = mvc.perform(post("/auth/register").contentType(MediaType.APPLICATION_JSON)
                        .content(json("username", username, "fullName", "Cliente de prueba",
                                "email", username + "@test.dev", "password", "Secreta123")))
                .andExpect(status().isCreated())
                .andReturn().getResponse().getContentAsString();
        return JsonPath.read(body, "$.accessToken");
    }

    // ------------------------------------------------------------- Datos de ejemplo

    protected String mangaId(String title) throws Exception {
        String body = mvc.perform(get("/mangas").param("q", title).param("size", "50"))
                .andReturn().getResponse().getContentAsString();
        List<String> ids = JsonPath.read(body, "$.content[?(@.title == '" + title + "')].id");
        return ids.get(0);
    }

    /** Id del volumen N de una serie. */
    protected String volumeId(String title, int number) throws Exception {
        String body = mvc.perform(get("/mangas/" + mangaId(title))).andReturn().getResponse().getContentAsString();
        List<String> ids = JsonPath.read(body, "$.volumes[?(@.number == " + number + ")].id");
        return ids.get(0);
    }

    protected int stockOf(String title, int number) throws Exception {
        String body = mvc.perform(get("/mangas/" + mangaId(title))).andReturn().getResponse().getContentAsString();
        List<Integer> stock = JsonPath.read(body, "$.volumes[?(@.number == " + number + ")].stock");
        return stock.get(0);
    }

    // ------------------------------------------------------------- JSON

    /** Construye un objeto JSON plano a partir de pares clave/valor. */
    protected static String json(Object... pairs) {
        StringBuilder sb = new StringBuilder("{");
        for (int i = 0; i < pairs.length; i += 2) {
            if (i > 0) sb.append(',');
            sb.append('"').append(pairs[i]).append("\":");
            Object v = pairs[i + 1];
            if (v == null) sb.append("null");
            else if (v instanceof Number || v instanceof Boolean || (v instanceof String s && s.startsWith("{")))
                sb.append(v);
            else sb.append('"').append(v.toString().replace("\"", "\\\"")).append('"');
        }
        return sb.append('}').toString();
    }

    protected static String checkout(String cardNumber, String expiry) {
        String shipping = json("fullName", "Ana Pérez", "address", "Calle Sol 1", "city", "Sevilla",
                "postalCode", "41001", "phone", "600123123");
        return json("shipping", shipping, "cardNumber", cardNumber, "cardExpiry", expiry, "cardCvc", "123");
    }
}
