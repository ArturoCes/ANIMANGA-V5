package com.salesianos.triana.backend.Animangav4.service;

import com.salesianos.triana.backend.Animangav4.dtos.*;
import com.salesianos.triana.backend.Animangav4.exception.EmptyMangaListException;
import com.salesianos.triana.backend.Animangav4.exception.EntityNotFoundException;
import com.salesianos.triana.backend.Animangav4.exception.FavoriteException;
import com.salesianos.triana.backend.Animangav4.exception.ForbiddenException;
import com.salesianos.triana.backend.Animangav4.models.*;
import com.salesianos.triana.backend.Animangav4.repository.MangaRepository;
import com.salesianos.triana.backend.Animangav4.repository.UserRepository;
import com.salesianos.triana.backend.Animangav4.repository.VolumenRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;


import java.util.Optional;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class VolumenService {

    private final VolumenRepository volumenRepository;

    private final StorageService storageService;

    private final MangaRepository mangaRepository;

    private final VolumenDtoConverter volumenDtoConverter;

    private final UserRepository userRepository;

    public Volumen save(UUID mangaId, CreateVolumenDto createVolumenDto, MultipartFile file) {

        String uri = storageService.store(file);
        //   uri = storageService.uriComplete(uri);
        Optional<Manga> m = mangaRepository.findById(mangaId);

        if (m.isPresent()) {
            Volumen v = volumenDtoConverter.createVolumenDtoToVolumen(createVolumenDto, uri);
            v.addVolumenFromManga(m.get());
            return volumenRepository.save(v);
        } else {
            throw new EntityNotFoundException(mangaId.toString(), Manga.class);
        }
    }

    public Volumen findById(UUID id) {
        return volumenRepository.findById(id)
                .orElseThrow(() -> new EntityNotFoundException(id.toString(), Volumen.class));
    }

    public Volumen editVolumen(CreateVolumenDto cv, User user, UUID id) {
        Optional<Manga> m = mangaRepository.findById(cv.getIdManga());
        Optional<Volumen> v = volumenRepository.findById(id);

        if (v.isEmpty()) {
            throw new EntityNotFoundException(id.toString(), Volumen.class);
        } else {
            Optional<User> u = userRepository.findById(user.getId());

            if (user.getRole().equals(UserRole.ADMIN)) {

                if (m.isPresent()) {
                    v.get().removeVolumenFromManga(v.get().getManga());
                    v.get().addVolumenFromManga(m.get());
                }
                v.get().setNombre(cv.getNombre());
                v.get().setCantidad(cv.getCantidad());
                v.get().setPrecio(cv.getPrecio());

                return volumenRepository.save(v.get());
            } else {
                throw new ForbiddenException("No tiene permisos para realizar esta acción");
            }
        }
    }



    public void deleteVolumen(UUID id) {
        Optional<Volumen> v = volumenRepository.findById(id);
        if (v.isEmpty()) {
            throw new EntityNotFoundException(id.toString(), Volumen.class);
        } else {
            storageService.deleteFile(v.get().getPosterPath());
            volumenRepository.deleteById(id);
        }
    }

    public Page<GetVolumenDto> findAllVolums(Pageable pageable) {
        Page<Volumen> list = volumenRepository.findAll(pageable);

        if (list.isEmpty()) {
            throw new EmptyMangaListException(Manga.class);
        } else {
            return list.map(volumenDtoConverter::volumenToGetVolumenDto);
        }
    }

    public Volumen editPosterPath(User user, MultipartFile file, UUID id) {

        Optional<Volumen> v1 = volumenRepository.findById(id);

        if (v1.isEmpty()) {
            throw new EntityNotFoundException(id.toString(), Manga.class);
        } else {
            Optional<User> u = userRepository.findById(user.getId());

            if (user.getRole().equals(UserRole.ADMIN)) {
                String uri = storageService.store(file);
                uri = storageService.uriComplete(uri);

                if (!v1.get().getPosterPath().isEmpty()) {
                    storageService.deleteFile(v1.get().getPosterPath());
                }
                v1.get().setPosterPath(uri);
                return volumenRepository.save(v1.get());
            } else {
                throw new ForbiddenException("No tiene permisos para realizar esta acción");
            }
        }
    }
}
