package com.salesianos.triana.animanga.catalog;

import com.salesianos.triana.animanga.cart.CartItemRepository;
import com.salesianos.triana.animanga.catalog.CatalogDtos.*;
import com.salesianos.triana.animanga.common.ApiException;
import com.salesianos.triana.animanga.common.PageResponse;
import com.salesianos.triana.animanga.order.OrderRepository;
import com.salesianos.triana.animanga.review.ReviewRepository;
import com.salesianos.triana.animanga.storage.StorageService;
import com.salesianos.triana.animanga.user.User;
import com.salesianos.triana.animanga.user.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import java.util.*;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class CatalogService {

    private static final int HOME_SIZE = 10;

    private final MangaRepository mangas;
    private final VolumeRepository volumes;
    private final CharacterRepository characters;
    private final CategoryRepository categories;
    private final UserRepository users;
    private final ReviewRepository reviews;
    private final OrderRepository orders;
    private final CartItemRepository cartItems;
    private final StorageService storage;
    private final MangaStatsUpdater stats;

    // =================================================================== Consulta

    @Transactional(readOnly = true)
    public PageResponse<MangaSummary> search(MangaSpecifications.Filter filter, String sort, int page, int size) {
        var pageable = PageRequest.of(page, Math.min(Math.max(size, 1), 60), MangaSpecifications.sort(sort));
        return PageResponse.of(mangas.findAll(MangaSpecifications.matching(filter), pageable), CatalogMapper::summary);
    }

    @Transactional(readOnly = true)
    public MangaDetail detail(UUID id, User principal) {
        Manga manga = loadManga(id);
        boolean favorite = false;
        Integer myRating = null;
        if (principal != null) {
            User user = users.findById(principal.getId()).orElse(null);
            if (user != null) {
                favorite = user.getFavorites().contains(manga);
                myRating = reviews.findByUserAndManga(user, manga).map(r -> r.getRating()).orElse(null);
            }
        }
        return CatalogMapper.detail(manga, favorite, myRating);
    }

    @Transactional(readOnly = true)
    public HomeResponse home(User principal) {
        var latest = top(Sort.by(Sort.Order.desc("releaseDate").nullsLast()));
        var bestSellers = top(Sort.by(Sort.Order.desc("unitsSold"), Sort.Order.asc("title")));
        var topRated = top(Sort.by(Sort.Order.desc("ratingAverage"), Sort.Order.desc("ratingCount")));
        return new HomeResponse(latest, bestSellers, topRated, recommended(principal, topRated));
    }

    /**
     * Recomendaciones según las categorías de los favoritos y compras del usuario,
     * excluyendo lo que ya tiene. Sin historial, se devuelven los mejor valorados.
     */
    private List<MangaSummary> recommended(User principal, List<MangaSummary> fallback) {
        if (principal == null) return fallback;
        User user = users.findById(principal.getId()).orElse(null);
        if (user == null) return fallback;

        Set<UUID> owned = new HashSet<>(orders.purchasedMangaIds(user));
        user.getFavorites().forEach(m -> owned.add(m.getId()));
        if (owned.isEmpty()) return fallback;

        Set<UUID> categoryIds = mangas.findAllById(owned).stream()
                .flatMap(m -> m.getCategories().stream())
                .map(Category::getId)
                .collect(Collectors.toSet());
        if (categoryIds.isEmpty()) return fallback;

        var result = mangas.findRecommended(categoryIds, owned, PageRequest.of(0, HOME_SIZE)).stream()
                .map(CatalogMapper::summary).toList();
        return result.isEmpty() ? fallback : result;
    }

    private List<MangaSummary> top(Sort sort) {
        return mangas.findAll(PageRequest.of(0, HOME_SIZE, sort)).map(CatalogMapper::summary).getContent();
    }

    @Transactional(readOnly = true)
    public List<String> publishers() {
        return mangas.findPublishers();
    }

    @Transactional(readOnly = true)
    public List<CategoryDto> categories() {
        return categories.findAllByOrderByNameAsc().stream().map(CatalogMapper::category).toList();
    }

    // =================================================================== Mangas (admin)

    @Transactional
    public MangaDetail createManga(MangaRequest req, MultipartFile cover) {
        Manga manga = Manga.builder().coverImage(storage.store(cover)).build();
        apply(manga, req);
        stats.refresh(mangas.save(manga));
        return CatalogMapper.detail(manga, false, null);
    }

    @Transactional
    public MangaDetail updateManga(UUID id, MangaRequest req) {
        Manga manga = loadManga(id);
        apply(manga, req);
        return CatalogMapper.detail(manga, false, null);
    }

    @Transactional
    public MangaDetail updateMangaCover(UUID id, MultipartFile cover) {
        Manga manga = loadManga(id);
        String old = manga.getCoverImage();
        manga.setCoverImage(storage.store(cover));
        storage.delete(old);
        return CatalogMapper.detail(manga, false, null);
    }

    /**
     * Borra un manga con sus volúmenes, personajes y reseñas. Los pedidos antiguos se
     * conservan porque guardan una copia de los datos de cada línea.
     */
    @Transactional
    public void deleteManga(UUID id) {
        Manga manga = loadManga(id);
        for (Volume v : manga.getVolumes()) {
            orders.detachVolume(v.getId());
            cartItems.deleteByVolume(v);
            storage.delete(v.getCoverImage());
        }
        manga.getCharacters().forEach(c -> storage.delete(c.getImage()));
        reviews.deleteByManga(manga);
        mangas.deleteFavorites(manga.getId());
        storage.delete(manga.getCoverImage());
        mangas.delete(manga);
    }

    private void apply(Manga manga, MangaRequest req) {
        manga.setTitle(req.title().trim());
        manga.setAuthor(trim(req.author()));
        manga.setPublisher(trim(req.publisher()));
        manga.setReleaseDate(req.releaseDate());
        manga.setSynopsis(req.synopsis().trim());
        List<Category> found = categories.findAllById(req.categoryIds());
        if (found.size() != new HashSet<>(req.categoryIds()).size()) throw ApiException.badRequest("Alguna categoría no existe");
        manga.setCategories(new HashSet<>(found));
    }

    // =================================================================== Volúmenes (admin)

    @Transactional
    public VolumeDto createVolume(UUID mangaId, VolumeRequest req, MultipartFile cover) {
        Manga manga = loadManga(mangaId);
        if (volumes.existsByMangaAndNumber(manga, req.number())) {
            throw ApiException.conflict("Ya existe el tomo " + req.number() + " de este manga");
        }
        Volume volume = Volume.builder().coverImage(storage.store(cover)).build();
        apply(volume, manga, req);
        manga.addVolume(volume);
        volumes.save(volume);
        stats.refreshStock(manga);
        return CatalogMapper.volume(volume);
    }

    @Transactional
    public VolumeDto updateVolume(UUID id, VolumeRequest req) {
        Volume volume = loadVolume(id);
        if (volumes.existsByMangaAndNumberAndIdNot(volume.getManga(), req.number(), id)) {
            throw ApiException.conflict("Ya existe el tomo " + req.number() + " de este manga");
        }
        apply(volume, volume.getManga(), req);
        stats.refreshStock(volume.getManga());
        return CatalogMapper.volume(volume);
    }

    @Transactional
    public VolumeDto updateVolumeCover(UUID id, MultipartFile cover) {
        Volume volume = loadVolume(id);
        String old = volume.getCoverImage();
        volume.setCoverImage(storage.store(cover));
        storage.delete(old);
        return CatalogMapper.volume(volume);
    }

    @Transactional
    public void deleteVolume(UUID id) {
        Volume volume = loadVolume(id);
        Manga manga = volume.getManga();
        orders.detachVolume(id);
        cartItems.deleteByVolume(volume);
        manga.getVolumes().remove(volume);
        storage.delete(volume.getCoverImage());
        stats.refreshStock(manga);
    }

    private void apply(Volume volume, Manga manga, VolumeRequest req) {
        volume.setNumber(req.number());
        volume.setTitle(req.title() == null || req.title().isBlank()
                ? manga.getTitle() + " " + req.number() : req.title().trim());
        volume.setPrice(req.price());
        volume.setIsbn(req.isbn() == null || req.isbn().isBlank() ? null : req.isbn());
        volume.setStock(req.stock());
    }

    // =================================================================== Personajes (admin)

    @Transactional
    public CharacterDto createCharacter(UUID mangaId, CharacterRequest req, MultipartFile image) {
        Manga manga = loadManga(mangaId);
        MangaCharacter character = MangaCharacter.builder()
                .name(req.name().trim()).age(req.age()).description(trim(req.description()))
                .image(image == null || image.isEmpty() ? null : storage.store(image))
                .build();
        manga.addCharacter(character);
        characters.save(character);
        return CatalogMapper.character(character);
    }

    @Transactional
    public CharacterDto updateCharacter(UUID id, CharacterRequest req) {
        MangaCharacter character = loadCharacter(id);
        character.setName(req.name().trim());
        character.setAge(req.age());
        character.setDescription(trim(req.description()));
        return CatalogMapper.character(character);
    }

    @Transactional
    public CharacterDto updateCharacterImage(UUID id, MultipartFile image) {
        MangaCharacter character = loadCharacter(id);
        String old = character.getImage();
        character.setImage(storage.store(image));
        storage.delete(old);
        return CatalogMapper.character(character);
    }

    @Transactional
    public void deleteCharacter(UUID id) {
        MangaCharacter character = loadCharacter(id);
        character.getManga().getCharacters().remove(character);
        storage.delete(character.getImage());
    }

    // =================================================================== Categorías (admin)

    @Transactional
    public CategoryDto createCategory(CategoryRequest req) {
        if (categories.existsByNameIgnoreCase(req.name().trim())) throw ApiException.conflict("Esa categoría ya existe");
        return CatalogMapper.category(categories.save(
                Category.builder().name(req.name().trim()).description(trim(req.description())).build()));
    }

    @Transactional
    public CategoryDto updateCategory(UUID id, CategoryRequest req) {
        Category category = categories.findById(id).orElseThrow(() -> ApiException.notFound("Categoría"));
        if (categories.existsByNameIgnoreCaseAndIdNot(req.name().trim(), id)) {
            throw ApiException.conflict("Esa categoría ya existe");
        }
        category.setName(req.name().trim());
        category.setDescription(trim(req.description()));
        return CatalogMapper.category(category);
    }

    /** Se desvincula de los mangas antes de borrarla. */
    @Transactional
    public void deleteCategory(UUID id) {
        Category category = categories.findById(id).orElseThrow(() -> ApiException.notFound("Categoría"));
        mangas.findAllByCategoriesContains(category).forEach(m -> m.getCategories().remove(category));
        categories.delete(category);
    }

    // =================================================================== Utilidades

    private Manga loadManga(UUID id) {
        return mangas.findById(id).orElseThrow(() -> ApiException.notFound("Manga"));
    }

    private Volume loadVolume(UUID id) {
        return volumes.findById(id).orElseThrow(() -> ApiException.notFound("Volumen"));
    }

    private MangaCharacter loadCharacter(UUID id) {
        return characters.findById(id).orElseThrow(() -> ApiException.notFound("Personaje"));
    }

    private static String trim(String value) {
        return value == null || value.isBlank() ? null : value.trim();
    }
}
