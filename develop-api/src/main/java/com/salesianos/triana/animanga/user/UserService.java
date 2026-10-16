package com.salesianos.triana.animanga.user;

import com.salesianos.triana.animanga.cart.CartItemRepository;
import com.salesianos.triana.animanga.catalog.CatalogDtos.MangaSummary;
import com.salesianos.triana.animanga.catalog.CatalogMapper;
import com.salesianos.triana.animanga.catalog.Manga;
import com.salesianos.triana.animanga.catalog.MangaRepository;
import com.salesianos.triana.animanga.common.ApiException;
import com.salesianos.triana.animanga.common.PageResponse;
import com.salesianos.triana.animanga.order.OrderRepository;
import com.salesianos.triana.animanga.review.ReviewRepository;
import com.salesianos.triana.animanga.storage.StorageService;
import com.salesianos.triana.animanga.user.UserDtos.*;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Sort;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import java.util.Comparator;
import java.util.List;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class UserService {

    private final UserRepository users;
    private final MangaRepository mangas;
    private final AccountTokenRepository tokens;
    private final CartItemRepository cartItems;
    private final ReviewRepository reviews;
    private final OrderRepository orders;
    private final PasswordEncoder passwordEncoder;
    private final StorageService storage;
    private final AuthService authService;

    // ---------- Perfil propio

    @Transactional(readOnly = true)
    public UserDto me(User principal) {
        return UserDto.from(load(principal.getId()));
    }

    @Transactional
    public UserDto updateProfile(User principal, UpdateProfileRequest req) {
        User user = load(principal.getId());
        applyProfile(user, req);
        return UserDto.from(user);
    }

    @Transactional
    public UserDto updateAvatar(User principal, MultipartFile image) {
        User user = load(principal.getId());
        String old = user.getAvatar();
        user.setAvatar(storage.store(image));
        storage.delete(old);
        return UserDto.from(user);
    }

    @Transactional
    public void changePassword(User principal, ChangePasswordRequest req) {
        User user = load(principal.getId());
        if (!passwordEncoder.matches(req.currentPassword(), user.getPassword())) {
            throw ApiException.badRequest("La contraseña actual no es correcta");
        }
        user.setPassword(passwordEncoder.encode(req.newPassword()));
    }

    // ---------- Favoritos

    @Transactional(readOnly = true)
    public List<MangaSummary> favorites(User principal) {
        return load(principal.getId()).getFavorites().stream()
                .sorted(Comparator.comparing(Manga::getTitle))
                .map(CatalogMapper::summary)
                .toList();
    }

    @Transactional
    public void setFavorite(User principal, UUID mangaId, boolean favorite) {
        User user = load(principal.getId());
        Manga manga = mangas.findById(mangaId).orElseThrow(() -> ApiException.notFound("Manga"));
        if (favorite) user.getFavorites().add(manga);
        else user.getFavorites().remove(manga);
    }

    // ---------- Administración

    @Transactional(readOnly = true)
    public PageResponse<UserDto> search(String q, Role role, int page, int size) {
        var pageable = PageRequest.of(page, Math.min(size, 100), Sort.by("fullName"));
        return PageResponse.of(users.findAll(UserRepository.search(q, role), pageable), UserDto::from);
    }

    @Transactional
    public UserDto adminUpdate(UUID id, UpdateProfileRequest req) {
        User user = load(id);
        applyProfile(user, req);
        return UserDto.from(user);
    }

    @Transactional
    public UserDto changeRole(User principal, UUID id, Role role) {
        if (principal.getId().equals(id)) throw ApiException.badRequest("No puedes cambiar tu propio rol");
        User user = load(id);
        user.setRole(role);
        return UserDto.from(user);
    }

    @Transactional
    public void delete(User principal, UUID id) {
        if (principal.getId().equals(id)) throw ApiException.badRequest("No puedes eliminar tu propia cuenta");
        User user = load(id);
        if (orders.existsByUser(user)) {
            throw ApiException.conflict("No se puede eliminar un usuario con pedidos registrados");
        }
        tokens.deleteByUser(user);
        cartItems.deleteByUser(user);
        reviews.deleteByUser(user);
        user.getFavorites().clear();
        storage.delete(user.getAvatar());
        users.delete(user);
    }

    private void applyProfile(User user, UpdateProfileRequest req) {
        String email = req.email().trim().toLowerCase();
        if (users.existsByEmailIgnoreCaseAndIdNot(email, user.getId())) {
            throw ApiException.conflict("Ya existe una cuenta con ese email");
        }
        boolean emailChanged = !email.equalsIgnoreCase(user.getEmail());
        user.setFullName(req.fullName().trim());
        user.setEmail(email);
        if (emailChanged) {
            // Un email nuevo tiene que volver a confirmarse
            user.setEmailVerified(false);
            authService.sendVerification(user);
        }
    }

    private User load(UUID id) {
        return users.findById(id).orElseThrow(() -> ApiException.notFound("Usuario"));
    }
}
