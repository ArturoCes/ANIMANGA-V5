package com.salesianos.triana.backend.Animangav5.validation.validators;

import com.salesianos.triana.backend.Animangav5.repository.UserRepository;
import com.salesianos.triana.backend.Animangav5.validation.annotation.UniqueUsername;
import org.springframework.beans.factory.annotation.Autowired;

import javax.validation.ConstraintValidator;
import javax.validation.ConstraintValidatorContext;

public class UniqueUsernameValidator implements ConstraintValidator<UniqueUsername, String> {

    @Autowired
    private UserRepository repository;

    @Override
    public void initialize(UniqueUsername constraintAnnotation) {
    }

    @Override
    public boolean isValid(String username, ConstraintValidatorContext constraintValidatorContext) {
        return !repository.existsByUsername(username);
    }
}