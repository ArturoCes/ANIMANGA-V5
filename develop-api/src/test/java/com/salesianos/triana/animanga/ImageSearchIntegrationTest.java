package com.salesianos.triana.animanga;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.mock.web.MockMultipartFile;

import javax.imageio.ImageIO;
import java.awt.*;
import java.awt.geom.AffineTransform;
import java.awt.image.BufferedImage;
import java.io.ByteArrayOutputStream;
import java.io.File;
import java.util.Random;

import static org.hamcrest.Matchers.*;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.multipart;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@DisplayName("Búsqueda por imagen")
class ImageSearchIntegrationTest extends IntegrationTest {

    private static final String COVERS = "src/main/resources/seed/covers/";

    @Test
    void encuentraElMangaConLaPortadaExacta() throws Exception {
        search(jpg(read("nar-01.jpg")))
                .andExpect(jsonPath("$.found").value(true))
                .andExpect(jsonPath("$.matches[0].manga.title").value("Naruto"))
                .andExpect(jsonPath("$.matches[0].volumeNumber").value(1))
                .andExpect(jsonPath("$.matches[0].similarity").value(greaterThan(90)));
    }

    @Test
    void encuentraElMangaEnUnaFotoGiradaConFondoYOtraLuz() throws Exception {
        BufferedImage cover = read("snk-01.jpg");
        // Simula una foto de móvil: portada más pequeña sobre una mesa, algo más oscura y guardada girada
        BufferedImage photo = new BufferedImage(900, 1200, BufferedImage.TYPE_INT_RGB);
        Graphics2D g = photo.createGraphics();
        Random rnd = new Random(1);
        for (int y = 0; y < photo.getHeight(); y += 6) {
            g.setColor(new Color(120 + rnd.nextInt(20), 85 + rnd.nextInt(15), 50 + rnd.nextInt(10)));
            g.fillRect(0, y, photo.getWidth(), 6);
        }
        g.drawImage(cover, 140, 160, 620, 900, null);
        g.setColor(new Color(0, 0, 0, 40));
        g.fillRect(0, 0, photo.getWidth(), photo.getHeight());
        g.dispose();

        search(jpg(rotate90(photo)))
                .andExpect(jsonPath("$.found").value(true))
                .andExpect(jsonPath("$.matches[0].manga.title").value("Ataque a los Titanes"));
    }

    @Test
    void encuentraElMangaEnUnaFotoTorcida() throws Exception {
        BufferedImage cover = read("kny-02.jpg");
        BufferedImage photo = new BufferedImage(1000, 1300, BufferedImage.TYPE_INT_RGB);
        Graphics2D g = photo.createGraphics();
        g.setColor(new Color(70, 90, 110));
        g.fillRect(0, 0, photo.getWidth(), photo.getHeight());
        g.rotate(Math.toRadians(5), 500, 650);
        g.drawImage(cover, 220, 230, 560, 840, null);
        g.dispose();

        search(jpg(photo))
                .andExpect(jsonPath("$.found").value(true))
                .andExpect(jsonPath("$.matches[0].manga.title").value("Guardianes de la Noche"))
                .andExpect(jsonPath("$.matches[0].volumeNumber").value(2));
    }

    @Test
    void encuentraElMangaEnUnaCapturaConMargenes() throws Exception {
        BufferedImage cover = read("sxf-01.jpg");
        BufferedImage shot = new BufferedImage(1080, 1400, BufferedImage.TYPE_INT_RGB);
        Graphics2D g = shot.createGraphics();
        g.setColor(Color.WHITE);
        g.fillRect(0, 0, shot.getWidth(), shot.getHeight());
        g.drawImage(cover, 240, 200, 600, 900, null);
        g.dispose();

        search(png(shot))
                .andExpect(jsonPath("$.found").value(true))
                .andExpect(jsonPath("$.matches[0].manga.title").value("Spy×Family"));
    }

    @Test
    void noInventaCoincidenciasConUnaImagenCualquiera() throws Exception {
        BufferedImage noise = new BufferedImage(600, 900, BufferedImage.TYPE_INT_RGB);
        Graphics2D g = noise.createGraphics();
        g.setPaint(new GradientPaint(0, 0, new Color(30, 140, 60), 600, 900, new Color(200, 220, 255)));
        g.fillRect(0, 0, 600, 900);
        g.setColor(Color.ORANGE);
        g.fillOval(150, 250, 300, 300);
        g.dispose();

        search(jpg(noise)).andExpect(jsonPath("$.found").value(false));
    }

    @Test
    void rechazaFicherosQueNoSonImagenes() throws Exception {
        mvc.perform(multipart("/mangas/search-by-image")
                        .file(new MockMultipartFile("image", "foto.jpg", "image/jpeg", "no soy una imagen".getBytes())))
                .andExpect(status().isBadRequest());
    }

    @Test
    void limitaLasBusquedasPorMinuto() throws Exception {
        byte[] image = jpg(read("op-01.jpg"));
        for (int i = 0; i < 10; i++) search(image).andExpect(status().isOk());
        search(image).andExpect(status().isTooManyRequests());
    }

    // ------------------------------------------------------------- Utilidades

    private org.springframework.test.web.servlet.ResultActions search(byte[] image) throws Exception {
        return mvc.perform(multipart("/mangas/search-by-image").file(new MockMultipartFile("image", "foto", null, image)));
    }

    private static BufferedImage read(String name) throws Exception {
        return ImageIO.read(new File(COVERS + name));
    }

    private static BufferedImage rotate90(BufferedImage src) {
        BufferedImage out = new BufferedImage(src.getHeight(), src.getWidth(), BufferedImage.TYPE_INT_RGB);
        Graphics2D g = out.createGraphics();
        AffineTransform t = new AffineTransform();
        t.translate(src.getHeight(), 0);
        t.rotate(Math.PI / 2);
        g.drawImage(src, t, null);
        g.dispose();
        return out;
    }

    private static byte[] jpg(BufferedImage img) throws Exception {
        return encode(img, "jpg");
    }

    private static byte[] png(BufferedImage img) throws Exception {
        return encode(img, "png");
    }

    private static byte[] encode(BufferedImage img, String format) throws Exception {
        ByteArrayOutputStream out = new ByteArrayOutputStream();
        ImageIO.write(img, format, out);
        return out.toByteArray();
    }
}
