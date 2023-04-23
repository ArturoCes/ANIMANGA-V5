package com.salesianos.triana.backend.Animangav5.service;

import com.salesianos.triana.backend.Animangav5.dtos.*;
import com.salesianos.triana.backend.Animangav5.exception.EmptyMangaListException;
import com.salesianos.triana.backend.Animangav5.exception.EntityNotFoundException;
import com.salesianos.triana.backend.Animangav5.exception.ExceptionFav;
import com.salesianos.triana.backend.Animangav5.exception.ForbiddenException;
import com.salesianos.triana.backend.Animangav5.models.Category;
import com.salesianos.triana.backend.Animangav5.models.Character;
import com.salesianos.triana.backend.Animangav5.models.Manga;
import com.salesianos.triana.backend.Animangav5.models.User;
import com.salesianos.triana.backend.Animangav5.models.UserRole;
import com.salesianos.triana.backend.Animangav5.repository.CategoryRepository;
import com.salesianos.triana.backend.Animangav5.repository.CharacterRepository;
import com.salesianos.triana.backend.Animangav5.repository.MangaRepository;
import com.salesianos.triana.backend.Animangav5.repository.UserRepository;
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

    private final CharacterDtoConverter characterDtoConverter;
    private final CharacterRepository characterRepository;

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
        return mangaRepository.findById(id).orElseThrow(() -> new EntityNotFoundException(id.toString(), Manga.class));
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
        Page<Manga> list = mangaRepository.findAll(pageable);

        if (list.isEmpty()) {
            throw new EmptyMangaListException(Manga.class);
        } else {
            return list.map(mangaDtoConverter::mangaToGetMangaDto);
        }
    }

    public Manga addMangaToWishList(UUID idManga, User user) {
        Optional<User> u = userRepository.findById(user.getId());
        if (u.isEmpty()) {
            throw new EntityNotFoundException(user.getId().toString(), User.class);
        } else {
            Optional<Manga> m = mangaRepository.findById(idManga);
            if (m.isEmpty()) {
                throw new EntityNotFoundException(idManga.toString(), Book.class);
            } else {
                if (!m.get().getListaDeDeseos().contains(u.get())) {
                    u.get().addMangaToWishList(m.get());
                    return mangaRepository.save(m.get());
                } else {
                    throw new ExceptionFav("El manga ya esta añadido en la lista de deseos");
                }
            }
        }
    }

    public void removeMangaFromWishList(UUID idManga, User user) {
        Optional<User> u = userRepository.findById(user.getId());
        if (u.isEmpty()) {
            throw new EntityNotFoundException(user.getId().toString(), User.class);
        } else {
            Optional<Manga> m = mangaRepository.findById(idManga);
            if (m.isEmpty()) {
                throw new EntityNotFoundException(idManga.toString(), Manga.class);
            } else {
                if (m.get().getListaDeDeseos().contains(u.get())) {
                    u.get().removeMangaFromWishList(m.get());
                    mangaRepository.save(m.get());
                } else {
                    throw new ExceptionFav("El manga no se encuentra en la lista de deseos");
                }
            }
        }
    }

    public boolean isFavorite(UUID idManga, User user) {
        Optional<User> u = userRepository.findById(user.getId());
        if (u.isEmpty()) {
            throw new EntityNotFoundException(user.getId().toString(), User.class);
        } else {
            return mangaRepository.existsByIdInWishList(idManga, u.get());
        }
    }

    public Manga addCharacterToManga(UUID idManga, CharacterDto characterDto) {
        Optional<Manga> optionalManga = mangaRepository.findById(idManga);
        if (optionalManga.isEmpty()) {
            throw new EntityNotFoundException(idManga.toString(), Manga.class);
        }
        Manga manga = optionalManga.get();
        Character character = characterDtoConverter.characterDtoToEntity(characterDto);

        manga.getCharacters().add(character);
        character.setManga(manga);


        mangaRepository.save(manga);

        return manga;
    }
}