package com.salesianos.triana.backend.Animangav5.service;
import com.salesianos.triana.backend.Animangav5.dtos.CharacterDto;
import com.salesianos.triana.backend.Animangav5.dtos.CharacterDtoConverter;
import com.salesianos.triana.backend.Animangav5.exception.EmptyListException;
import com.salesianos.triana.backend.Animangav5.models.Character;
import com.salesianos.triana.backend.Animangav5.repository.CharacterRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class CharacterService {
    private final CharacterRepository characterRepository;

    private final CharacterDtoConverter characterDtoConverter;

    public Page<CharacterDto> findAllCharacters(Pageable pageable) {
        Page<Character> list= characterRepository.findAll(pageable);

        if (list.isEmpty()) {
            throw new EmptyListException(Character.class);
        } else {
            return list.map(characterDtoConverter::entityToCharacterDto);
        }
    }
}
