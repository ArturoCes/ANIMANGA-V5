package com.salesianos.triana.animanga.user;

import com.salesianos.triana.animanga.catalog.CatalogDtos.MangaSummary;
import com.salesianos.triana.animanga.user.UserDtos.*;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;
import java.util.UUID;

@Tag(name = "Mi cuenta")
@RestController
@RequestMapping("/users/me")
@RequiredArgsConstructor
public class MeController {

    private final UserService userService;

    @Operation(summary = "Datos del usuario autenticado")
    @GetMapping
    public UserDto me(@AuthenticationPrincipal User user) {
        return userService.me(user);
    }

    @Operation(summary = "Editar nombre y email")
    @PutMapping
    public UserDto update(@AuthenticationPrincipal User user, @Valid @RequestBody UpdateProfileRequest req) {
        return userService.updateProfile(user, req);
    }

    @Operation(summary = "Cambiar la foto de perfil")
    @PutMapping(value = "/avatar", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public UserDto avatar(@AuthenticationPrincipal User user, @RequestPart("image") MultipartFile image) {
        return userService.updateAvatar(user, image);
    }

    @Operation(summary = "Cambiar la contraseña")
    @PutMapping("/password")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void password(@AuthenticationPrincipal User user, @Valid @RequestBody ChangePasswordRequest req) {
        userService.changePassword(user, req);
    }

    @Operation(summary = "Mis mangas favoritos")
    @GetMapping("/favorites")
    public List<MangaSummary> favorites(@AuthenticationPrincipal User user) {
        return userService.favorites(user);
    }

    @Operation(summary = "Añadir un manga a favoritos")
    @PutMapping("/favorites/{mangaId}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void addFavorite(@AuthenticationPrincipal User user, @PathVariable UUID mangaId) {
        userService.setFavorite(user, mangaId, true);
    }

    @Operation(summary = "Quitar un manga de favoritos")
    @DeleteMapping("/favorites/{mangaId}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void removeFavorite(@AuthenticationPrincipal User user, @PathVariable UUID mangaId) {
        userService.setFavorite(user, mangaId, false);
    }
}
