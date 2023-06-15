package com.salesianos.triana.backend.Animangav4.dtos;


import com.salesianos.triana.backend.Animangav4.models.Character;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

import java.util.UUID;

@Component
@RequiredArgsConstructor
public class CharacterDtoConverter {


        public CharacterDto entityToDto(Character character) {
            CharacterDto dto = new CharacterDto();
            dto.setId(character.getId().toString());
            dto.setName(character.getName());
            dto.setDescription(character.getDescription());
            dto.setImageUrl(character.getImageUrl());
            return dto;
        }

        public Character dtoToEntity(CharacterDto dto) {
            Character character = new Character();
            character.setId(UUID.fromString(dto.getId()));
            character.setName(dto.getName());
            character.setDescription(dto.getDescription());
            character.setImageUrl(dto.getImageUrl());
            return character;
        }
    }


