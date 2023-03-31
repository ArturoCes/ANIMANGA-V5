package com.salesianos.triana.backend.Animangav4.exception;

public class ForbiddenException extends RuntimeException{

    public ForbiddenException(String message) {
        super(String.format(message));
    }

}
