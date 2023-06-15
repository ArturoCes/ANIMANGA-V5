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
import com.salesianos.triana.backend.Animangav4.utils.PaginationLinksUtils;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.web.PageableDefault;
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
import org.springframework.web.util.UriComponentsBuilder;

import javax.servlet.http.HttpServletRequest;
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

    private final PaginationLinksUtils paginationLinksUtils;

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
    @PutMapping("/user/{id}")
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

    @Operation(summary = "Listar todos los usuarios")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200",
                    description = "Se devuelve una lista con todos los usuarios",
                    content = {@Content(mediaType = "aplication/json",
                            schema = @Schema(implementation = User.class))}),
            @ApiResponse(responseCode = "404",
                    description = "La lista esta vacia",
                    content = @Content),
    })
    @GetMapping("/all")
    public ResponseEntity<Page<GetUserDto>> findAllUsers (@PageableDefault(size = 10, page = 0) Pageable pageable,
                                                          @AuthenticationPrincipal User user,
                                                          HttpServletRequest request) {
        Page<GetUserDto> lista = userService.findAllUsers(pageable);
        UriComponentsBuilder uriBuilder = UriComponentsBuilder.fromHttpUrl(request.getRequestURL().toString());
        return ResponseEntity.ok().header("link", paginationLinksUtils.createLinkHeader(lista, uriBuilder)).body(lista);
    }

    @Operation(summary = "Buscar usuarios")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200",
                    description = "Se devuelve una lista con los usuarios encontrados",
                    content = {@Content(mediaType = "aplication/json",
                            schema = @Schema(implementation = User.class))}),
            @ApiResponse(responseCode = "400",
                    description = "Error en los datos",
                    content = @Content),
            @ApiResponse(responseCode = "404",
                    description = "La lista esta vacia",
                    content = @Content),
    })
    @PostMapping("/find/")
    public ResponseEntity<Page<GetUserDto>> findUsers(@AuthenticationPrincipal User user,
                                                      @RequestPart("search") SearchUserDto u,
                                                      @PageableDefault(size = 10, page = 0) Pageable pageable,
                                                      HttpServletRequest request) {

        Page<GetUserDto> lista = userService.findUser(user,u,pageable);
        UriComponentsBuilder uriBuilder = UriComponentsBuilder.fromHttpUrl(request.getRequestURL().toString());
        return ResponseEntity.ok().header("link", paginationLinksUtils.createLinkHeader(lista, uriBuilder)).body(lista);
    }

    @Operation(summary = "Dar rol de admin")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200",
                    description = "Se cambia el rol de un usuario a admin",
                    content = {@Content(mediaType = "aplication/json",
                            schema = @Schema(implementation = User.class))}),
            @ApiResponse(responseCode = "400",
                    description = "Error en los datos",
                    content = @Content),
    })
    @PutMapping("/give/admin/{id}")
    public ResponseEntity<GetUserDto> giveAdmin(@AuthenticationPrincipal User user, @PathVariable UUID id) {
        return ResponseEntity.ok()
                .body(userDtoConverter.userToGetUserDto(
                        userService.giveAdmin(user, id)));
    }

    @Operation(summary = "Quitar rol de admin")
    @ApiResponses(value = {
            @ApiResponse(responseCode = "200",
                    description = "Se cambia el rol de un usuario a user",
                    content = {@Content(mediaType = "aplication/json",
                            schema = @Schema(implementation = User.class))}),
            @ApiResponse(responseCode = "400",
                    description = "Error en los datos",
                    content = @Content),
    })
    @PutMapping("/remove/admin/{id}")
    public ResponseEntity<GetUserDto> removeAdmin(@AuthenticationPrincipal User user, @PathVariable UUID id) {
        return ResponseEntity.ok()
                .body(userDtoConverter.userToGetUserDto(
                        userService.removeAdmin(user, id)));
    }
}

