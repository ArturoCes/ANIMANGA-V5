package com.salesianos.triana.backend.Animangav4.service;

import com.salesianos.triana.backend.Animangav4.dtos.*;
import com.salesianos.triana.backend.Animangav4.exception.*;
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
import java.util.*;


@Service
@RequiredArgsConstructor
public class MangaService {

    private final MangaRepository mangaRepository;
    private final StorageService storageService;
    private final MangaDtoConverter mangaDtoConverter;
    private final UserService userService;
    private final UserRepository userRepository;
    private final CategoryRepository categoryRepository;

    private final CharacterDtoConverter characterDtoConverter;


    public Manga save(CreateMangaDto createMangaDto, MultipartFile file) {

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


    public Page<GetMangaDto> findByName (String name, Pageable pageable) {
        Page<Manga> lista = mangaRepository.findByNameIgnoreCaseContains(name, pageable);

        if(lista.isEmpty()) {
            throw new ListNotFoundException(Manga.class);
        } else {
            return lista.map(mangaDtoConverter::mangaToGetMangaDto);

        }
    }
    public Manga findById(UUID id) {
        return mangaRepository.findById(id)
                .orElseThrow(() -> new EntityNotFoundException(id.toString(), Manga.class));
    }

    public Manga editManga(CreateMangaDto m, User user, UUID id) {

        Optional<Manga> m1 = mangaRepository.findById(id);

        if (m1.isEmpty()) {
            throw new EntityNotFoundException(id.toString(), Manga.class);
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
//            storageService.deleteFile(m.get().getPosterPath());
            mangaRepository.deleteById(id);
        }
    }

    //TODO Terminar añadir y quitar favoritos para poder pintarlos.
    public Manga addFavorite(UUID idManga, User user) {
        Optional<User> u = userRepository.findById(user.getId());
        if (u.isEmpty()) {
            throw new EntityNotFoundException(user.getId().toString(), User.class);
        } else {
            Optional<Manga> m = mangaRepository.findById(idManga);
            if (m.isEmpty()) {
                throw new EntityNotFoundException(idManga.toString(), Manga.class);
            } else {
                if (!m.get().getUsersMangaFavorite().contains(u.get())) {
                    u.get().addMangaFavorite(m.get());
                    return mangaRepository.save(m.get());
                } else {
                    throw new FavoriteException("El manga ya esta marcado como favorito");
                }
            }
        }
    }

    public Manga removeFavorite(UUID idManga, User user) {
        Optional<User> u = userRepository.findById(user.getId());
        if (u.isEmpty()) {
            throw new EntityNotFoundException(user.getId().toString(), User.class);
        } else {
            Optional<Manga> m = mangaRepository.findById(idManga);
            if (m.isEmpty()) {
                throw new EntityNotFoundException(idManga.toString(), Manga.class);
            } else {
                if (m.get().getUsersMangaFavorite().contains(u.get())) {
                    u.get().removeMangaFavorite(m.get());
                    return mangaRepository.save(m.get());
                } else {
                    throw new FavoriteException("El manga no esta marcado como favorito");
                }
            }
        }
    }
    public Page<GetMangaDto> findAllFavoriteMangas (String username, Pageable pageable) {
        Optional<User> u1 = userService.findByUsername(username);

        if(u1.isEmpty()) {
            throw new EntityNotFound("No se pudo encontrar el usuario con nick: "+ username );
        } else {
            Page<Manga> lista = mangaRepository.findByUsersMangaFavorite(u1.get(), pageable);

            if(lista.isEmpty()) {
                throw new ListNotFoundException(Manga.class);
            } else {
                return lista.map(mangaDtoConverter::mangaToGetMangaDto);
            }
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

    public boolean isFavorite(UUID idManga, User user){
        Optional<User> u = userRepository.findById(user.getId());
        if(u.isEmpty()) {
            throw new EntityNotFoundException(user.getId().toString(), User.class);
        } else {
            return  mangaRepository.existsByIdAndUsersMangaFavorite(idManga, u.get());
        }
    }

    public Page<Manga> findAllMangasByCategory(String name, Pageable pageable) {

        return mangaRepository.findByCategoryName(name, pageable);

    }
    public Manga editPosterPath(User user,MultipartFile file, UUID id) {

        Optional<Manga> m1 = mangaRepository.findById(id);

        if(m1.isEmpty()){
            throw new EntityNotFoundException(id.toString(), Manga.class);
        } else {
            Optional<User> u = userRepository.findById(user.getId());

            if(user.getRole().equals(UserRole.ADMIN)){
                String uri = storageService.store(file);
             //   uri = storageService.uriComplete(uri);

                if(!m1.get().getPosterPath().isEmpty()) {
                    storageService.deleteFile(m1.get().getPosterPath());
                }
                m1.get().setPosterPath(uri);
                return mangaRepository.save(m1.get());
            } else {
                throw new ForbiddenException("No tiene permisos para realizar esta acción");
            }
        }
    }

}