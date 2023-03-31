package com.salesianos.triana.backend.Animangav4.exception;

public class EntityNotFoundException extends EntityNotFound {


    public EntityNotFoundException(String id, Class clazz) {
        super(String.format("No se puede encontrar una entidad del tipo %s con ID: %s", clazz.getName(), id));
    }
}

