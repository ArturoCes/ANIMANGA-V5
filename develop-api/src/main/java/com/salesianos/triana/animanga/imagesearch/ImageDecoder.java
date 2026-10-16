package com.salesianos.triana.animanga.imagesearch;

import com.salesianos.triana.animanga.storage.StorageException;

import javax.imageio.ImageIO;
import javax.imageio.ImageReader;
import javax.imageio.stream.ImageInputStream;
import java.awt.geom.AffineTransform;
import java.awt.image.AffineTransformOp;
import java.awt.image.BufferedImage;
import java.io.ByteArrayInputStream;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;

/** Decodifica imágenes de forma segura y genera los recortes con los que se busca. */
final class ImageDecoder {

    /** Evita "bombas" de imagen: un PNG pequeño puede declarar millones de píxeles. */
    private static final long MAX_PIXELS = 40_000_000L;

    private ImageDecoder() {}

    static BufferedImage decode(byte[] data) {
        try (ImageInputStream in = ImageIO.createImageInputStream(new ByteArrayInputStream(data))) {
            Iterator<ImageReader> readers = in == null ? null : ImageIO.getImageReaders(in);
            if (readers == null || !readers.hasNext()) throw new StorageException("No se ha podido leer la imagen");
            ImageReader reader = readers.next();
            try {
                reader.setInput(in, true, true);
                if ((long) reader.getWidth(0) * reader.getHeight(0) > MAX_PIXELS) {
                    throw new StorageException("La imagen es demasiado grande");
                }
                BufferedImage image = reader.read(0);
                // Se trabaja sobre una copia reducida: la huella no necesita más resolución
                return shrink(image, 720);
            } finally {
                reader.dispose();
            }
        } catch (IOException e) {
            throw new StorageException("No se ha podido leer la imagen");
        }
    }

    /**
     * Variantes de la foto del usuario: completa, sin bordes lisos, centrada en formato portada y giros.
     * Así se encuentra la portada aunque la foto tenga mesa alrededor o el móvil la guarde girada.
     */
    static List<BufferedImage> candidates(BufferedImage photo) {
        List<BufferedImage> crops = new ArrayList<>();
        crops.add(photo);
        crops.add(trimBorders(photo));
        crops.add(center(photo, 0.8));
        crops.add(center(photo, 0.6));
        crops.add(portrait(photo, 1.0));
        crops.add(portrait(photo, 0.8));
        List<BufferedImage> all = new ArrayList<>();
        for (BufferedImage crop : crops) {
            all.add(crop);
            all.add(rotate(crop, 90));
            all.add(rotate(crop, 180));
            all.add(rotate(crop, 270));
        }
        // Fotos algo torcidas: pequeños giros del recorte tipo portada
        for (int degrees : new int[] {-6, -3, 3, 6}) all.add(tilt(portrait(photo, 0.85), degrees));
        return all;
    }

    private static BufferedImage shrink(BufferedImage image, int maxSide) {
        int w = image.getWidth(), h = image.getHeight();
        double scale = Math.min(1, (double) maxSide / Math.max(w, h));
        return ImageFingerprint.resize(image, Math.max(1, (int) (w * scale)), Math.max(1, (int) (h * scale)));
    }

    private static BufferedImage center(BufferedImage img, double fraction) {
        int w = (int) (img.getWidth() * fraction), h = (int) (img.getHeight() * fraction);
        return img.getSubimage((img.getWidth() - w) / 2, (img.getHeight() - h) / 2, Math.max(1, w), Math.max(1, h));
    }

    /** Recorte central con la proporción de una portada (2:3). */
    private static BufferedImage portrait(BufferedImage img, double fraction) {
        int h = (int) (img.getHeight() * fraction);
        int w = Math.min(img.getWidth(), (int) (h * 2 / 3.0));
        h = Math.min(h, (int) (w * 1.5));
        return img.getSubimage((img.getWidth() - w) / 2, (img.getHeight() - h) / 2, Math.max(1, w), Math.max(1, h));
    }

    /** Quita márgenes de color uniforme (capturas de pantalla, fondos blancos). */
    static BufferedImage trimBorders(BufferedImage img) {
        int top = 0, bottom = img.getHeight() - 1, left = 0, right = img.getWidth() - 1;
        int ref = img.getRGB(0, 0);
        while (top < bottom && uniformRow(img, top, ref)) top++;
        while (bottom > top && uniformRow(img, bottom, ref)) bottom--;
        while (left < right && uniformCol(img, left, ref, top, bottom)) left++;
        while (right > left && uniformCol(img, right, ref, top, bottom)) right--;
        int w = right - left + 1, h = bottom - top + 1;
        // Si casi no queda nada, la imagen era lisa: se devuelve tal cual
        if (w < img.getWidth() * 0.2 || h < img.getHeight() * 0.2) return img;
        return img.getSubimage(left, top, w, h);
    }

    private static boolean uniformRow(BufferedImage img, int y, int ref) {
        for (int x = 0; x < img.getWidth(); x += 2) if (!close(img.getRGB(x, y), ref)) return false;
        return true;
    }

    private static boolean uniformCol(BufferedImage img, int x, int ref, int top, int bottom) {
        for (int y = top; y <= bottom; y += 2) if (!close(img.getRGB(x, y), ref)) return false;
        return true;
    }

    private static boolean close(int a, int b) {
        return Math.abs((a >> 16 & 0xff) - (b >> 16 & 0xff)) < 24
                && Math.abs((a >> 8 & 0xff) - (b >> 8 & 0xff)) < 24
                && Math.abs((a & 0xff) - (b & 0xff)) < 24;
    }

    private static BufferedImage rotate(BufferedImage img, int degrees) {
        boolean swap = degrees % 180 != 0;
        int w = img.getWidth(), h = img.getHeight();
        AffineTransform t = new AffineTransform();
        t.translate(swap ? h / 2.0 : w / 2.0, swap ? w / 2.0 : h / 2.0);
        t.rotate(Math.toRadians(degrees));
        t.translate(-w / 2.0, -h / 2.0);
        BufferedImage out = new BufferedImage(swap ? h : w, swap ? w : h, BufferedImage.TYPE_INT_RGB);
        return new AffineTransformOp(t, AffineTransformOp.TYPE_BILINEAR).filter(toRgb(img), out);
    }

    /** Giro leve sin cambiar el tamaño; se recorta un poco para no meter esquinas negras. */
    private static BufferedImage tilt(BufferedImage img, int degrees) {
        int w = img.getWidth(), h = img.getHeight();
        AffineTransform t = AffineTransform.getRotateInstance(Math.toRadians(degrees), w / 2.0, h / 2.0);
        BufferedImage out = new BufferedImage(w, h, BufferedImage.TYPE_INT_RGB);
        new AffineTransformOp(t, AffineTransformOp.TYPE_BILINEAR).filter(toRgb(img), out);
        return center(out, 0.9);
    }

    private static BufferedImage toRgb(BufferedImage img) {
        if (img.getType() == BufferedImage.TYPE_INT_RGB) return img;
        return ImageFingerprint.resize(img, img.getWidth(), img.getHeight());
    }
}
