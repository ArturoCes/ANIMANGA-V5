package com.salesianos.triana.backend.Animangav4.service;

import com.salesianos.triana.backend.Animangav4.dtos.*;
import com.salesianos.triana.backend.Animangav4.exception.*;
import com.salesianos.triana.backend.Animangav4.models.*;
import com.salesianos.triana.backend.Animangav4.repository.*;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import java.util.ArrayList;
import java.util.List;
import java.util.UUID;


@Service
@RequiredArgsConstructor
public class MangaService {

    private final MangaRepository mangaRepository;
    private final StorageService storageService;
    private final MangaDtoConverter mangaDtoConverter;
    private final UserService userService;
    private final UserRepository userRepository;
    private final CategoryRepository categoryRepository;
    private final VolumenRepository volumenRepository;
    private final ItemRepository itemRepository;
    private final PurchaseRepository purchaseRepository;


    @Transactional
    public Manga save(CreateMangaDto createMangaDto, MultipartFile file) {
        String uri = storageService.store(file);
        Manga m = mangaDtoConverter.createMangaDtoToManga(createMangaDto, uri);
        m.getCategories().addAll(resolveCategories(createMangaDto.getCategories()));
        return mangaRepository.save(m);
    }

    public Page<GetMangaDto> findByName(String name, Pageable pageable) {
        return mangaRepository.findByNameIgnoreCaseContains(name == null ? "" : name.trim(), pageable)
                .map(mangaDtoConverter::mangaToGetMangaDto);
    }

    public Manga findById(UUID id) {
        return mangaRepository.findById(id)
                .orElseThrow(() -> new EntityNotFoundException(id.toString(), Manga.class));
    }

    @Transactional
    public Manga editManga(CreateMangaDto dto, User user, UUID id) {
        checkAdmin(user);
        Manga m = findById(id);
        m.setName(dto.getName());
        m.setDescription(dto.getDescription());
        if (dto.getAuthor() != null) m.setAuthor(dto.getAuthor());
        if (dto.getPublisher() != null) m.setPublisher(dto.getPublisher());
        if (dto.getReleaseDate() != null) m.setReleaseDate(dto.getReleaseDate());
        m.setCategories(resolveCategories(dto.getCategories()));
        return mangaRepository.save(m);
    }

    @Transactional
    public void deleteManga(UUID id) {
        Manga m = findById(id);
        for (Volumen v : m.getTomos()) {
            if (purchaseRepository.existsByVolumen(v)) {
                throw new BadRequestException("No se puede borrar un manga con volúmenes ya vendidos");
            }
        }
        for (Volumen v : m.getTomos()) {
            itemRepository.deleteByVolumen(v);
            storageService.deleteFileQuietly(v.getPosterPath());
        }
        volumenRepository.deleteAll(new ArrayList<>(m.getTomos()));
        m.getTomos().clear();

        for (User u : new ArrayList<>(m.getUsersMangaFavorite())) {
            u.removeMangaFavorite(m);
            userRepository.save(u);
        }
        mangaRepository.delete(m);
        storageService.deleteFileQuietly(m.getPosterPath());
    }

    @Transactional
    public Manga addFavorite(UUID idManga, User user) {
        User u = userRepository.findById(user.getId())
                .orElseThrow(() -> new EntityNotFoundException(user.getId().toString(), User.class));
        Manga m = findById(idManga);
        if (m.getUsersMangaFavorite().contains(u)) {
            throw new FavoriteException("El manga ya esta marcado como favorito");
        }
        u.addMangaFavorite(m);
        userRepository.save(u);
        return m;
    }

    @Transactional
    public Manga removeFavorite(UUID idManga, User user) {
        User u = userRepository.findById(user.getId())
                .orElseThrow(() -> new EntityNotFoundException(user.getId().toString(), User.class));
        Manga m = findById(idManga);
        if (!m.getUsersMangaFavorite().contains(u)) {
            throw new FavoriteException("El manga no esta marcado como favorito");
        }
        u.removeMangaFavorite(m);
        userRepository.save(u);
        return m;
    }

    public Page<GetMangaDto> findAllFavoriteMangas(String username, Pageable pageable) {
        User u = userService.findByUsername(username)
                .orElseThrow(() -> new EntityNotFound("No se pudo encontrar el usuario con nick: " + username));
        return mangaRepository.findByUsersMangaFavorite(u, pageable)
                .map(mangaDtoConverter::mangaToGetMangaDto);
    }

    public Page<GetMangaDto> findAllMangas(Pageable pageable) {
        return mangaRepository.findAll(pageable).map(mangaDtoConverter::mangaToGetMangaDto);
    }

    public boolean isFavorite(UUID idManga, User user) {
        return mangaRepository.existsByIdAndUsersMangaFavorite(idManga, user);
    }

    public Page<Manga> findAllMangasByCategory(String name, Pageable pageable) {
        return mangaRepository.findByCategoryName(name, pageable);
    }

    @Transactional
    public Manga editPosterPath(User user, MultipartFile file, UUID id) {
        checkAdmin(user);
        Manga m = findById(id);
        String uri = storageService.store(file);
        storageService.deleteFileQuietly(m.getPosterPath());
        m.setPosterPath(uri);
        return mangaRepository.save(m);
    }

    private List<Category> resolveCategories(List<Category> categories) {
        List<Category> list = new ArrayList<>();
        if (categories == null) return list;
        for (Category c : categories) {
            list.add(categoryRepository.findById(c.getId())
                    .orElseThrow(() -> new EntityNotFoundException(c.getId().toString(), Category.class)));
        }
        return list;
    }

    private void checkAdmin(User user) {
        if (user.getRole() != UserRole.ADMIN) {
            throw new ForbiddenException("No tiene permisos para realizar esta acción");
        }
    }
}
