package com.salesianos.triana.backend.Animangav4.service;

import com.salesianos.triana.backend.Animangav4.dtos.CreateMangaDto;
import com.salesianos.triana.backend.Animangav4.dtos.GetMangaDto;
import com.salesianos.triana.backend.Animangav4.dtos.MangaDtoConverter;
import com.salesianos.triana.backend.Animangav4.exception.EmptyMangaListException;
import com.salesianos.triana.backend.Animangav4.exception.EntityNotFoundException;
import com.salesianos.triana.backend.Animangav4.exception.ForbiddenException;
import com.salesianos.triana.backend.Animangav4.models.Category;
import com.salesianos.triana.backend.Animangav4.models.Manga;
import com.salesianos.triana.backend.Animangav4.models.User;
import com.salesianos.triana.backend.Animangav4.models.UserRole;
import com.salesianos.triana.backend.Animangav4.repository.CategoryRepository;
import com.salesianos.triana.backend.Animangav4.repository.MangaRepository;
import com.salesianos.triana.backend.Animangav4.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.awt.print.Book;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class MangaService {

    private final MangaRepository mangaRepository;
    private final StorageService storageService;
    private final MangaDtoConverter mangaDtoConverter;
    private final UserRepository userRepository;
    private final CategoryRepository categoryRepository;


    public Manga save(CreateMangaDto createMangaDto, MultipartFile file, User user) {
        Optional<User> u = userRepository.findById(user.getId());
        if (u.isEmpty()) {
            throw new EntityNotFoundException(user.getId().toString(), User.class);
        } else {
            String uri = storageService.store(file);
         //   uri = storageService.uriComplete(uri);
            Manga m = mangaDtoConverter.createMangaDtoToManga(createMangaDto, uri);
            List<Category> list = new ArrayList<>();
            for (Category c : createMangaDto.getCategories()) {
                Category c1 = categoryRepository.findById(c.getId()).get();
                list.add(c1);
            }
            m.getCategories().addAll(list);
            return mangaRepository.save(m);
        }
    }

    public Manga findById(UUID id) {
        return mangaRepository.findById(id)
                .orElseThrow(() -> new EntityNotFoundException(id.toString(), Manga.class));
    }

    public Manga editManga(CreateMangaDto m, User user, UUID id) {

        Optional<Manga> m1 = mangaRepository.findById(id);

        if (m1.isEmpty()) {
            throw new EntityNotFoundException(id.toString(), Book.class);
        } else {
            Optional<User> u = userRepository.findById(user.getId());

            if (user.getRole().equals(UserRole.ADMIN)) {
                m1.get().setName(m.getName());
                m1.get().setDescription(m.getDescription());
                List<Category> list = new ArrayList<>();
                for (Category g : m.getCategories()) {
                    list.add(categoryRepository.findById(g.getId()).get());
                }
                m1.get().setCategories(list);
                return mangaRepository.save(m1.get());
            } else {
                throw new ForbiddenException("No tiene permisos para realizar esta acción");
            }
        }
    }

    public void deleteManga(UUID id) {
        Optional<Manga> m = mangaRepository.findById(id);
        if (m.isEmpty()) {
            throw new EntityNotFoundException(id.toString(), Manga.class);
        } else {
            storageService.deleteFile(m.get().getPosterPath());
            mangaRepository.deleteById(id);
        }
    }

    public Page<GetMangaDto> findAllMangas(Pageable pageable) {
        Page<Manga> list= mangaRepository.findAll(pageable);

        if (list.isEmpty()) {
            throw new EmptyMangaListException(Manga.class);
        } else {
            return list.map(mangaDtoConverter::mangaToGetMangaDto);
        }
    }
}