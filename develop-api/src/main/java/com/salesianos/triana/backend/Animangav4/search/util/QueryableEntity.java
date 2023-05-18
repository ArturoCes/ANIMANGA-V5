package com.salesianos.triana.backend.Animangav4.search.util;

import java.util.Arrays;
import java.lang.reflect.Field;

public interface QueryableEntity {

    static boolean checkQueryParam(Class clazz, String fieldName) {

        return Arrays.stream(clazz.getDeclaredFields())
                .map(Field::getName)
                .anyMatch(n -> n.equalsIgnoreCase(fieldName));
        //return Arrays.stream(getClass().getQueryFields()).anyMatch(n -> n.equalsIgnoreCase(fieldName));
    }


}