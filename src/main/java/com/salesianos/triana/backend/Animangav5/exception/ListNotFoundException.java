package com.salesianos.triana.backend.Animangav5.exception;

public class ListNotFoundException extends EntityNotFound {

    public ListNotFoundException(Class clazz) {
        super(String.format("No se pueden encontrar elementos del tipo %s ", clazz.getName()));
    }

}


