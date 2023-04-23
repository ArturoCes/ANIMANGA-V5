package com.salesianos.triana.backend.Animangav5.security.jwt.refresh;

import com.salesianos.triana.backend.Animangav5.security.errorhandling.JwtTokenException;

public class RefreshTokenException extends JwtTokenException {

    public RefreshTokenException(String msg) {
        super(msg);
    }

}