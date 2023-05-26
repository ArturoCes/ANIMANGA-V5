package com.salesianos.triana.backend.Animangav4.service;

import com.salesianos.triana.backend.Animangav4.dtos.CharacterDto;
import com.salesianos.triana.backend.Animangav4.dtos.CharacterDtoConverter;
import com.salesianos.triana.backend.Animangav4.dtos.GetMangaDto;
import com.salesianos.triana.backend.Animangav4.exception.EmptyCharacterListException;
import com.salesianos.triana.backend.Animangav4.exception.EmptyMangaListException;
import com.salesianos.triana.backend.Animangav4.exception.MangaNotFoundException;
import com.salesianos.triana.backend.Animangav4.models.Character;
import com.salesianos.triana.backend.Animangav4.models.Manga;
import com.salesianos.triana.backend.Animangav4.repository.CharacterRepository;
import com.salesianos.triana.backend.Animangav4.repository.MangaRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;

import java.util.UUID;

@Service
@RequiredArgsConstructor
public class CharacterService {
    private final CharacterRepository characterRepository;

    private final CharacterDtoConverter characterDtoConverter;

    private final MangaRepository mangaRepository;


    public Page<CharacterDto> findAllCharactersByMangaId(UUID id, Pageable pageable) {
        Manga manga = mangaRepository.findById(id).orElseThrow(() -> new MangaNotFoundException());
        Page<Character> characters = characterRepository.findByManga(manga, pageable);

        if (characters.isEmpty()) {
            throw new EmptyCharacterListException(Character.class);
        } else {
            return characters.map(characterDtoConverter::entityToDto);
        }
    }


}


