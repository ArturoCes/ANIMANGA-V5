package com.salesianos.triana.backend.Animangav4.service;

import com.salesianos.triana.backend.Animangav4.dtos.*;
import com.salesianos.triana.backend.Animangav4.exception.BadRequestException;
import com.salesianos.triana.backend.Animangav4.exception.EntityNotFoundException;
import com.salesianos.triana.backend.Animangav4.exception.ForbiddenException;
import com.salesianos.triana.backend.Animangav4.models.*;
import com.salesianos.triana.backend.Animangav4.repository.ItemRepository;
import com.salesianos.triana.backend.Animangav4.repository.MangaRepository;
import com.salesianos.triana.backend.Animangav4.repository.PurchaseRepository;
import com.salesianos.triana.backend.Animangav4.repository.VolumenRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import java.util.UUID;

@Service
@RequiredArgsConstructor
public class VolumenService {

    private final VolumenRepository volumenRepository;
    private final StorageService storageService;
    private final MangaRepository mangaRepository;
    private final VolumenDtoConverter volumenDtoConverter;
    private final PurchaseRepository purchaseRepository;
    private final ItemRepository itemRepository;

    @Transactional
    public Volumen save(UUID mangaId, CreateVolumenDto dto, MultipartFile file) {
        Manga manga = mangaRepository.findById(mangaId)
                .orElseThrow(() -> new EntityNotFoundException(mangaId.toString(), Manga.class));
        validate(dto);
        String uri = storageService.store(file);
        Volumen v = volumenDtoConverter.createVolumenDtoToVolumen(dto, uri);
        v.addVolumenFromManga(manga);
        return volumenRepository.save(v);
    }

    public Volumen findById(UUID id) {
        return volumenRepository.findById(id)
                .orElseThrow(() -> new EntityNotFoundException(id.toString(), Volumen.class));
    }

    @Transactional
    public Volumen editVolumen(CreateVolumenDto dto, User user, UUID id) {
        checkAdmin(user);
        validate(dto);
        Volumen v = findById(id);
        if (dto.getIdManga() != null && (v.getManga() == null || !v.getManga().getId().equals(dto.getIdManga()))) {
            Manga manga = mangaRepository.findById(dto.getIdManga())
                    .orElseThrow(() -> new EntityNotFoundException(dto.getIdManga().toString(), Manga.class));
            if (v.getManga() != null) v.removeVolumenFromManga(v.getManga());
            v.addVolumenFromManga(manga);
        }
        v.setNombre(dto.getNombre());
        v.setCantidad(dto.getCantidad());
        v.setPrecio(dto.getPrecio());
        if (dto.getIsbn() != null) v.setIsbn(dto.getIsbn());
        return volumenRepository.save(v);
    }

    @Transactional
    public void deleteVolumen(UUID id) {
        Volumen v = findById(id);
        if (purchaseRepository.existsByVolumen(v)) {
            throw new BadRequestException("No se puede borrar un volumen con compras registradas");
        }
        itemRepository.deleteByVolumen(v);
        if (v.getManga() != null) {
            v.removeVolumenFromManga(v.getManga());
        }
        volumenRepository.delete(v);
        storageService.deleteFileQuietly(v.getPosterPath());
    }

    public Page<GetVolumenDto> findAllVolums(Pageable pageable) {
        return volumenRepository.findAll(pageable).map(volumenDtoConverter::volumenToGetVolumenDto);
    }

    @Transactional
    public Volumen editPosterPath(User user, MultipartFile file, UUID id) {
        checkAdmin(user);
        Volumen v = findById(id);
        String uri = storageService.store(file);
        storageService.deleteFileQuietly(v.getPosterPath());
        v.setPosterPath(uri);
        return volumenRepository.save(v);
    }

    private void validate(CreateVolumenDto dto) {
        if (dto.getNombre() == null || dto.getNombre().isBlank()) {
            throw new BadRequestException("Debe introducir el nombre del volumen");
        }
        if (dto.getPrecio() == null || dto.getPrecio() < 0) {
            throw new BadRequestException("El precio debe ser un número positivo");
        }
        if (dto.getCantidad() == null || dto.getCantidad() < 0) {
            throw new BadRequestException("El stock debe ser un número positivo");
        }
    }

    private void checkAdmin(User user) {
        if (user.getRole() != UserRole.ADMIN) {
            throw new ForbiddenException("No tiene permisos para realizar esta acción");
        }
    }
}
