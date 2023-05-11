package com.salesianos.triana.backend.Animangav4.security.jwt.refresh;

import com.salesianos.triana.backend.Animangav4.security.errorhandling.JwtTokenException;

public class RefreshTokenException extends JwtTokenException {

    public RefreshTokenException(String msg) {
        super(msg);
    }

}