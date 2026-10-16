package com.salesianos.triana.animanga.user;

import com.salesianos.triana.animanga.common.PageResponse;
import com.salesianos.triana.animanga.user.UserDtos.*;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.UUID;

@Tag(name = "Administración · Usuarios")
@RestController
@RequestMapping("/admin/users")
@RequiredArgsConstructor
public class AdminUserController {

    private final UserService userService;

    @Operation(summary = "Buscar usuarios por texto y rol")
    @GetMapping
    public PageResponse<UserDto> search(@RequestParam(required = false) String q,
                                        @RequestParam(required = false) Role role,
                                        @RequestParam(defaultValue = "0") int page,
                                        @RequestParam(defaultValue = "10") int size) {
        return userService.search(q, role, page, size);
    }

    @Operation(summary = "Editar nombre y email de un usuario")
    @PutMapping("/{id}")
    public UserDto update(@PathVariable UUID id, @Valid @RequestBody UpdateProfileRequest req) {
        return userService.adminUpdate(id, req);
    }

    @Operation(summary = "Cambiar el rol de un usuario")
    @PatchMapping("/{id}/role")
    public UserDto role(@AuthenticationPrincipal User admin, @PathVariable UUID id, @Valid @RequestBody RoleRequest req) {
        return userService.changeRole(admin, id, req.role());
    }

    @Operation(summary = "Eliminar un usuario sin pedidos")
    @DeleteMapping("/{id}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void delete(@AuthenticationPrincipal User admin, @PathVariable UUID id) {
        userService.delete(admin, id);
    }
}
