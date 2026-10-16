package com.salesianos.triana.animanga.storage;

import com.salesianos.triana.animanga.config.AppProperties;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.stereotype.Service;

import java.io.IOException;
import java.io.UncheckedIOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.Optional;

/** Guarda las imágenes en disco (desarrollo y demo). */
@Service
@ConditionalOnProperty(name = "app.storage.type", havingValue = "filesystem", matchIfMissing = true)
public class FileSystemStorageService implements StorageService {

    private final Path root;

    public FileSystemStorageService(AppProperties props) {
        this.root = Path.of(props.storage().location()).toAbsolutePath().normalize();
        try {
            Files.createDirectories(root);
        } catch (IOException e) {
            throw new UncheckedIOException("No se pudo crear el directorio de imágenes " + root, e);
        }
    }

    @Override
    public String save(String name, byte[] data, String contentType) {
        try {
            Files.write(resolve(name), data);
            return name;
        } catch (IOException e) {
            throw new UncheckedIOException(e);
        }
    }

    @Override
    public Optional<StoredImage> load(String name) {
        Path file = resolve(name);
        if (!Files.isRegularFile(file)) return Optional.empty();
        try {
            return Optional.of(new StoredImage(Files.readAllBytes(file), ImageValidator.contentTypeOf(name)));
        } catch (IOException e) {
            throw new UncheckedIOException(e);
        }
    }

    @Override
    public boolean exists(String name) {
        return Files.isRegularFile(resolve(name));
    }

    @Override
    public void delete(String name) {
        if (name == null || name.startsWith("http")) return;
        try {
            Files.deleteIfExists(resolve(name));
        } catch (IOException ignored) {
            // No es crítico: el fichero puede no existir
        }
    }

    private Path resolve(String name) {
        ImageValidator.checkName(name);
        Path file = root.resolve(name).normalize();
        if (!file.startsWith(root)) throw new StorageException("Ruta no permitida");
        return file;
    }
}
