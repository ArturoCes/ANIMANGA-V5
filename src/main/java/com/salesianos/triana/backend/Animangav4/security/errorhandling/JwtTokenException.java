package com.salesianos.triana.backend.Animangav4.security.errorhandling;


public class JwtTokenException extends RuntimeException{

    public JwtTokenException(String msg) {
        super(msg);
    }


}
