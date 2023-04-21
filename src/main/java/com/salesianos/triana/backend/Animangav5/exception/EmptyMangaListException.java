package com.salesianos.triana.backend.Animangav5.exception;

import com.salesianos.triana.backend.Animangav5.models.Manga;

import javax.persistence.EntityNotFoundException;

public class EmptyMangaListException extends EntityNotFoundException {

    public EmptyMangaListException(Class<Manga> mangaClass) {
        super("No mangas were found with the search criteria");
    }


}