package com.salesianos.triana.animanga.storage;

import org.apache.tika.Tika;

import java.util.Map;
import java.util.UUID;
import java.util.regex.Pattern;

/** Comprueba el tipo real del fichero por su contenido y genera nombres seguros. */
public final class ImageValidator {

    private static final Tika TIKA = new Tika();
    private static final Pattern SAFE_NAME = Pattern.compile("^[a-zA-Z0-9][a-zA-Z0-9._-]{0,120}$");
    private static final Map<String, String> EXTENSIONS = Map.of(
            "image/jpeg", "jpg",
            "image/png", "png",
            "image/webp", "webp",
            "image/gif", "gif");

    private ImageValidator() {}

    /** Devuelve el tipo MIME si es una imagen admitida; si no, lanza {@link StorageException}. */
    public static String validate(byte[] data, String originalName) {
        if (data == null || data.length == 0) throw new StorageException("El fichero está vacío");
        String detected = TIKA.detect(data, originalName);
        if (!EXTENSIONS.containsKey(detected)) {
            throw new StorageException("Solo se admiten imágenes JPG, PNG, WEBP o GIF");
        }
        return detected;
    }

    public static String generateName(String contentType) {
        return UUID.randomUUID() + "." + EXTENSIONS.getOrDefault(contentType, "img");
    }

    /** Evita rutas como "../../etc/passwd": solo nombres planos. */
    public static void checkName(String name) {
        if (name == null || !SAFE_NAME.matcher(name).matches() || name.contains("..")) {
            throw new StorageException("Nombre de fichero no válido");
        }
    }

    public static String contentTypeOf(String name) {
        String lower = name.toLowerCase();
        if (lower.endsWith(".png")) return "image/png";
        if (lower.endsWith(".webp")) return "image/webp";
        if (lower.endsWith(".gif")) return "image/gif";
        return "image/jpeg";
    }
}
