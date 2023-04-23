package com.salesianos.triana.backend.Animangav5.security.errorhandling;


public class JwtTokenException extends RuntimeException{

    public JwtTokenException(String msg) {
        super(msg);
    }


}
