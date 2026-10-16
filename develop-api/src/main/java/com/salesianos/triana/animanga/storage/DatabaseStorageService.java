package com.salesianos.triana.animanga.storage;

import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.Optional;

/**
 * Guarda las imágenes en la base de datos. En hostings gratuitos el disco es efímero,
 * así que las portadas subidas sobreviven a reinicios y despliegues.
 */
@Service
@ConditionalOnProperty(name = "app.storage.type", havingValue = "database")
public class DatabaseStorageService implements StorageService {

    private final StoredFileRepository repository;

    public DatabaseStorageService(StoredFileRepository repository) {
        this.repository = repository;
    }

    @Override
    @Transactional
    public String save(String name, byte[] data, String contentType) {
        ImageValidator.checkName(name);
        repository.save(new StoredFile(name, contentType, data));
        return name;
    }

    @Override
    @Transactional(readOnly = true)
    public Optional<StoredImage> load(String name) {
        ImageValidator.checkName(name);
        return repository.findById(name).map(f -> new StoredImage(f.getData(), f.getContentType()));
    }

    @Override
    @Transactional(readOnly = true)
    public boolean exists(String name) {
        ImageValidator.checkName(name);
        return repository.existsById(name);
    }

    @Override
    @Transactional
    public void delete(String name) {
        if (name == null || name.startsWith("http")) return;
        repository.deleteById(name);
    }
}
