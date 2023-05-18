package com.salesianos.triana.backend.Animangav4.validation.validators;

import com.salesianos.triana.backend.Animangav4.repository.UserRepository;
import com.salesianos.triana.backend.Animangav4.validation.annotation.EditEmail;
import org.springframework.beans.PropertyAccessorFactory;
import org.springframework.beans.factory.annotation.Autowired;

import javax.validation.ConstraintValidator;
import javax.validation.ConstraintValidatorContext;

public class EditEmailValidator implements ConstraintValidator<EditEmail, Object> {

    private String usernameField;
    private String emailField;

    @Autowired
    private UserRepository repository;

    @Override
    public void initialize(EditEmail constraintAnnotation) {
        usernameField = constraintAnnotation.usernameField();
        emailField = constraintAnnotation.emailField();
    }

    @Override
    public boolean isValid(Object value, ConstraintValidatorContext constraintValidatorContext) {
        String username = (String) PropertyAccessorFactory.forBeanPropertyAccess(value).getPropertyValue(usernameField);
        String email = (String) PropertyAccessorFactory.forBeanPropertyAccess(value).getPropertyValue(emailField);

        return !repository.existsByEmail(email) || email.equals(repository.existsEmailWithUsername(username));


    }
}