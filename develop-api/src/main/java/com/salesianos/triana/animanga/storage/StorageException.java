package com.salesianos.triana.animanga.storage;

import lombok.Getter;

@Getter
public class StorageException extends RuntimeException {

    private final boolean notFound;

    public StorageException(String message) {
        this(message, false);
    }

    public StorageException(String message, boolean notFound) {
        super(message);
        this.notFound = notFound;
    }
}
