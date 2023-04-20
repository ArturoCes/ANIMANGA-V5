package com.salesianos.triana.backend.Animangav4.dtos;

import com.salesianos.triana.backend.Animangav4.models.Character;
import org.springframework.stereotype.Component;

@Component
public class CharacterDtoConverter {

    public Character characterDtoToEntity(CharacterDto dto) {
        Character entity = new Character();
        entity.setId(dto.getId());
        entity.setName(dto.getName());
        entity.setAge(dto.getAge());
        entity.setDescription(dto.getDescription());
        // otros atributos

        return entity;
    }

    public CharacterDto entityToCharacterDto(Character entity) {
        CharacterDto dto = new CharacterDto();
        dto.setId(entity.getId());
        dto.setName(entity.getName());
        dto.setAge(entity.getAge());
        dto.setDescription(entity.getDescription());
        // otros atributos

        return dto;
    }
}