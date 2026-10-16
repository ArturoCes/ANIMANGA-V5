package com.salesianos.triana.animanga.imagesearch;

import java.awt.Graphics2D;
import java.awt.RenderingHints;
import java.awt.image.BufferedImage;

/**
 * Huella de una imagen para compararla con otras aunque cambie el tamaño, la compresión o el brillo.
 * <ul>
 *   <li>{@code hash}: hash perceptual (pHash) de 64 bits sobre la DCT de la imagen en grises.</li>
 *   <li>{@code colors}: histograma de color HSV normalizado, para desempatar portadas de composición parecida.</li>
 * </ul>
 */
public record ImageFingerprint(long hash, float[] colors) {

    private static final int DCT_SIZE = 32;
    private static final int HASH_SIZE = 8;
    private static final int HUE_BINS = 18, SAT_BINS = 3, VAL_BINS = 3;
    private static final double[][] COS = cosTable();

    public static ImageFingerprint of(BufferedImage image) {
        return new ImageFingerprint(perceptualHash(image), colorHistogram(image));
    }

    /** Similitud de 0 (nada que ver) a 1 (la misma imagen). */
    public double similarity(ImageFingerprint other) {
        int distance = Long.bitCount(hash ^ other.hash);
        // Dos imágenes sin relación difieren en ~32 de 64 bits: eso cuenta como 0
        double shape = Math.max(0, 1 - distance / 32.0);
        double color = 0;
        for (int i = 0; i < colors.length; i++) color += Math.min(colors[i], other.colors[i]);
        return 0.7 * shape + 0.3 * color;
    }

    private static long perceptualHash(BufferedImage image) {
        BufferedImage small = resize(image, DCT_SIZE, DCT_SIZE);
        double[][] gray = new double[DCT_SIZE][DCT_SIZE];
        for (int y = 0; y < DCT_SIZE; y++) {
            for (int x = 0; x < DCT_SIZE; x++) {
                int rgb = small.getRGB(x, y);
                gray[y][x] = 0.299 * (rgb >> 16 & 0xff) + 0.587 * (rgb >> 8 & 0xff) + 0.114 * (rgb & 0xff);
            }
        }
        // DCT 2D, solo las frecuencias bajas (las que describen la forma general)
        double[] low = new double[HASH_SIZE * HASH_SIZE];
        for (int u = 0; u < HASH_SIZE; u++) {
            for (int v = 0; v < HASH_SIZE; v++) {
                double sum = 0;
                for (int y = 0; y < DCT_SIZE; y++) {
                    for (int x = 0; x < DCT_SIZE; x++) sum += gray[y][x] * COS[u][y] * COS[v][x];
                }
                low[u * HASH_SIZE + v] = sum;
            }
        }
        // Mediana sin el componente continuo (el brillo medio), para que no influya la exposición
        double[] sorted = java.util.Arrays.copyOfRange(low, 1, low.length);
        java.util.Arrays.sort(sorted);
        double median = sorted[sorted.length / 2];
        long hash = 0;
        for (int i = 0; i < 64; i++) if (low[i] > median) hash |= 1L << i;
        return hash;
    }

    private static float[] colorHistogram(BufferedImage image) {
        BufferedImage small = resize(image, 48, 72);
        float[] bins = new float[HUE_BINS * SAT_BINS * VAL_BINS];
        float[] hsv = new float[3];
        int total = small.getWidth() * small.getHeight();
        for (int y = 0; y < small.getHeight(); y++) {
            for (int x = 0; x < small.getWidth(); x++) {
                int rgb = small.getRGB(x, y);
                java.awt.Color.RGBtoHSB(rgb >> 16 & 0xff, rgb >> 8 & 0xff, rgb & 0xff, hsv);
                int h = Math.min(HUE_BINS - 1, (int) (hsv[0] * HUE_BINS));
                int s = Math.min(SAT_BINS - 1, (int) (hsv[1] * SAT_BINS));
                int v = Math.min(VAL_BINS - 1, (int) (hsv[2] * VAL_BINS));
                bins[(h * SAT_BINS + s) * VAL_BINS + v] += 1f / total;
            }
        }
        return bins;
    }

    static BufferedImage resize(BufferedImage image, int width, int height) {
        BufferedImage out = new BufferedImage(width, height, BufferedImage.TYPE_INT_RGB);
        Graphics2D g = out.createGraphics();
        g.setRenderingHint(RenderingHints.KEY_INTERPOLATION, RenderingHints.VALUE_INTERPOLATION_BILINEAR);
        g.setRenderingHint(RenderingHints.KEY_RENDERING, RenderingHints.VALUE_RENDER_QUALITY);
        g.drawImage(image, 0, 0, width, height, null);
        g.dispose();
        return out;
    }

    private static double[][] cosTable() {
        double[][] table = new double[HASH_SIZE][DCT_SIZE];
        for (int u = 0; u < HASH_SIZE; u++) {
            for (int x = 0; x < DCT_SIZE; x++) table[u][x] = Math.cos((2 * x + 1) * u * Math.PI / (2 * DCT_SIZE));
        }
        return table;
    }
}
