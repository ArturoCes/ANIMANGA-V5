package com.salesianos.triana.backend.Animangav5.exception;


import javax.persistence.EntityNotFoundException;

public class EmptyListException extends EntityNotFoundException {

    public EmptyListException(Class<?> Class) {
        super("Empty list");
    }

}


