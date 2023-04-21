package com.salesianos.triana.backend.Animangav5.exception;

public class ForbiddenException extends RuntimeException{

    public ForbiddenException(String message) {
        super(String.format(message));
    }

}
