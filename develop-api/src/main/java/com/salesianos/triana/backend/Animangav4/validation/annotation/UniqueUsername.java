package com.salesianos.triana.backend.Animangav4.validation.annotation;

import com.salesianos.triana.backend.Animangav4.validation.validators.UniqueUsernameValidator;

import javax.validation.Constraint;
import javax.validation.Payload;
import java.lang.annotation.*;

@Target({ElementType.METHOD, ElementType.FIELD})
@Retention(RetentionPolicy.RUNTIME)
@Constraint(validatedBy = UniqueUsernameValidator.class)
@Documented
public @interface UniqueUsername {

    String message() default "El nick debe ser único";

    Class<?>[] groups() default {};

    Class<? extends Payload>[] payload() default {};
}