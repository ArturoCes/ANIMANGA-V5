package com.salesianos.triana.backend.Animangav4.exception;

import com.salesianos.triana.backend.Animangav4.models.Character;
import com.salesianos.triana.backend.Animangav4.models.Manga;

import javax.persistence.EntityNotFoundException;

public class EmptyCharacterListException extends EntityNotFoundException {
    public EmptyCharacterListException(Class<Character> characterClass) {
        super("No characters were found with the search criteria");
    }

}
