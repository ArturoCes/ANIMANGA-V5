package com.salesianos.triana.backend.Animangav4.controller;


import com.salesianos.triana.backend.Animangav4.dtos.*;
import com.salesianos.triana.backend.Animangav4.models.Manga;
import com.salesianos.triana.backend.Animangav4.models.User;
import com.salesianos.triana.backend.Animangav4.security.jwt.access.JwtProvider;
import com.salesianos.triana.backend.Animangav4.security.jwt.refresh.RefreshToken;
import com.salesianos.triana.backend.Animangav4.security.jwt.refresh.RefreshTokenException;
import com.salesianos.triana.backend.Animangav4.security.jwt.refresh.RefreshTokenRequest;
import com.salesianos.triana.backend.Animangav4.security.jwt.refresh.RefreshTokenService;
import com.salesianos.triana.backend.Animangav4.service.UserService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.server.ResponseStatusException;

import javax.validation.Valid;
import java.util.Optional;
import java.util.UUID;

@RestController
@RequiredArgsConstructor
public class UserController {

    private final UserService userService;
    private final AuthenticationManager authManager;
    private final JwtProvider jwtProvider;
    private final RefreshTokenService refreshTokenService;

    private final UserDtoConverter userDtoConverter;

    @PostMapping("/auth/register")

    public ResponseEntity<UserResponse> createUserWithUserRole(@RequestBody @Valid CreateUserDto createUserRequest) {
        User user = userService.createUserWithUserRole(createUserRequest);

        return ResponseEntity.status(HttpStatus.CREATED).body(UserResponse.fromUser(user));
    }
    @PostMapping("/auth/register/admin")
    public ResponseEntity<UserResponse> createUserWithAdminRole(@RequestBody @Valid CreateUserDto createUserRequest) {
        User user = userService.createUserWithAdminRole(createUserRequest);

        return ResponseEntity.status(HttpStatus.CREATED).body(UserResponse.fromUser(user));
    }


    @PostMapping("/auth/login")
    public ResponseEntity<JwtUserResponse> login(@RequestBody LoginRequest loginRequest) {
        Authentication authentication =
                authManager.authenticate(
                        new UsernamePasswordAuthenticationToken(
                                loginRequest.getUsername(),
                                loginRequest.getPassword()
                        )
                );
        SecurityContextHolder.getContext().setAuthentication(authentication);
        String token = jwtProvider.generateToken(authentication);

        User user = (User) authentication.getPrincipal();
        refreshTokenService.deleteByUser(user);
        RefreshToken refreshToken = refreshTokenService.createRefreshToken(user);

        return ResponseEntity.status(HttpStatus.CREATED)
                .body(JwtUserResponse.of(user, token, refreshToken.getToken()));


    }

    @PostMapping("/refreshtoken")
    public ResponseEntity<?> refreshToken(@RequestBody RefreshTokenRequest refreshTokenRequest) {
        String refreshToken = refreshTokenRequest.getRefreshToken();
        return refreshTokenService.findByToken(refreshToken)
                .map(refreshTokenService::verify)
                .map(RefreshToken::getUser)
                .map(user -> {
                    String token = jwtProvider.generateToken(user);
                    refreshTokenService.deleteByUser(user);
                    RefreshToken refreshToken2 = refreshTokenService.createRefreshToken(user);
                    return ResponseEntity.status(HttpStatus.CREATED)
                            .body(JwtUserResponse.builder()
                                    .token(token)
                                    .refreshToken(refreshToken2.getToken())
                                    .build());
                })
                .orElseThrow(() -> new RefreshTokenException("Refresh token not found"));

    }



    @Operation(summary = "Cambiar contraseña")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200",
                    description = "Se cambia la contraseña del usuario correctamente",
                    content = {@Content(mediaType = "aplication/json",
                            schema = @Schema(implementation = User.class))}),
            @ApiResponse(responseCode = "400",
                    description = "Error en los datos",
                    content = @Content),
            @ApiResponse(responseCode = "404",
                    description = "No se encontró el usuario",
                    content = @Content),
    })
    @PutMapping("/change")
    public GetUserDto changePassword(@Valid @RequestPart("user") PasswordDto p,
                                     @AuthenticationPrincipal User user) {
        return userDtoConverter.userToGetUserDto(userService.changePassword(p, user));
    }


    @Operation(summary = "Obtener un usuario")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200",
                    description = "Se encuentra el usuario con el id proporcionado",
                    content = {@Content(mediaType = "aplication/json",
                            schema = @Schema(implementation = Manga.class))}),
            @ApiResponse(responseCode = "404",
                    description = "No se encontró ningún usuario",
                    content = @Content),
    })
    @GetMapping("/{id}")
    public GetUserDto findMangaById(@PathVariable UUID id) {
        return userService.findById2(id);
    }

    @Operation(summary = "Se muestra los datos del usuario logueado")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200",
                    description = "Se hace login",
                    content = {@Content(mediaType = "aplication/json",
                            schema = @Schema(implementation = User.class))}),
    })
    @GetMapping("/me")
    public ResponseEntity<?> me(@AuthenticationPrincipal User user) {
        Optional<User> u = userService.findByUsername(user.getUsername());
        return ResponseEntity.ok(userDtoConverter.userToGetUserDto(u.get()));
    }
    @Operation(summary = "Editar un usuario")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200",
                    description = "Se edita el usuario correctamente",
                    content = {@Content(mediaType = "aplication/json",
                            schema = @Schema(implementation = User.class))}),
            @ApiResponse(responseCode = "400",
                    description = "Error en los datos",
                    content = @Content),
            @ApiResponse(responseCode = "404",
                    description = "No se encontró el usuario",
                    content = @Content),
    })
    @PutMapping("/{id}")
    public GetUserDto editUser(@RequestPart("user") @Valid EditUserDto e,
                               @PathVariable UUID id,
                               @AuthenticationPrincipal User user) {
        return userDtoConverter.userToGetUserDto(userService.editUser(e, user, id));
    }
    @Operation(summary = "Subir imagen")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "201",
                    description = "Se sube la imagen correctamente",
                    content = {@Content(mediaType = "aplication/json",
                            schema = @Schema(implementation = User.class))}),
            @ApiResponse(responseCode = "404",
                    description = "No se encontro al usuario",
                    content = @Content),
    })
    @PutMapping("/image/{id}")
    public ResponseEntity<GetUserDto> uploadImage(@RequestPart("image") MultipartFile file,
                                                   @PathVariable UUID id,
                                                   @AuthenticationPrincipal User user) {
        return ResponseEntity.status(HttpStatus.OK).body(userDtoConverter
                .userToGetUserDto(userService.uploadImage(file, user, id)));

    }
}

