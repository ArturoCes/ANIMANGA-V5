package com.salesianos.triana.backend.Animangav4.exception;

import javax.persistence.EntityNotFoundException;

public class MangaNotFoundException extends EntityNotFoundException {

    public MangaNotFoundException() {
        super("The manga could not be found");
    }

    public MangaNotFoundException(Long id) {
        super(String.format("The manga with id %d could not be found", id));
    }
}
