package com.salesianos.triana.backend.Animangav4.service;


import com.salesianos.triana.backend.Animangav4.dtos.*;
import com.salesianos.triana.backend.Animangav4.exception.BadRequestException;
import com.salesianos.triana.backend.Animangav4.exception.EntityNotFoundException;
import com.salesianos.triana.backend.Animangav4.exception.ForbiddenException;
import com.salesianos.triana.backend.Animangav4.exception.ListNotFoundException;
import com.salesianos.triana.backend.Animangav4.models.Cart;
import com.salesianos.triana.backend.Animangav4.models.User;
import com.salesianos.triana.backend.Animangav4.models.UserRole;
import com.salesianos.triana.backend.Animangav4.repository.CartRepository;
import com.salesianos.triana.backend.Animangav4.repository.PurchaseRepository;
import com.salesianos.triana.backend.Animangav4.security.jwt.refresh.RefreshTokenRepository;
import com.salesianos.triana.backend.Animangav4.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.domain.Specification;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class UserService {

    private final PasswordEncoder passwordEncoder;
    private final UserRepository userRepository;
    private final StorageService storageService;
    private final UserDtoConverter userDtoConverter;

    private final CartRepository cartRepository;
    private final PurchaseRepository purchaseRepository;
    private final RefreshTokenRepository refreshTokenRepository;

    public User createUser(CreateUserDto createUserRequest, UserRole role) {
        Cart c = new Cart();
        User user = User.builder().username(createUserRequest
                        .getUsername()).fullName(createUserRequest.getFullName())
                .email(createUserRequest.getEmail())
                .password(passwordEncoder.encode(createUserRequest.getPassword()))
                .image(createUserRequest.getImage() == null ? "https://ui-avatars.com/api/?background=7b1fa2&color=fff&name=" + createUserRequest.getFullName().trim().replace(" ", "+") : createUserRequest.getImage())
                .role(role).build();
        userRepository.save(user);
        c.setUser(user);
        cartRepository.save(c);
        user.setCarrito(c);
        return userRepository.save(user);
    }

    public User createUserWithUserRole(CreateUserDto createUserRequest) {
        return createUser(createUserRequest, UserRole.USER);
    }

    public User createUserWithAdminRole(CreateUserDto createUserRequest) {
        return createUser(createUserRequest, UserRole.ADMIN);
    }

    public List<User> findAll() {
        return userRepository.findAll();
    }

    public Optional<User> findById(UUID id) {
        return userRepository.findById(id);
    }

    public GetUserDto findById2(UUID id, User principal) {
        if (!principal.getId().equals(id) && principal.getRole() != UserRole.ADMIN) {
            throw new ForbiddenException("Permisos insuficientes");
        }
        Optional<User> u = userRepository.findById(id);
        if (u.isPresent()) {
            return userDtoConverter.userToGetUserDto(u.get());
        }
        throw new EntityNotFoundException("No se ha encontrado el usuario con el id: " + id, User.class);
    }

    public Optional<User> findByUsername(String username) {
        return userRepository.findFirstByUsername(username);
    }

    public User editUser(EditUserDto editUserDto, User user, UUID id) {
        Optional<User> u = userRepository.findById(id);
        if(u.isEmpty()){
            throw new EntityNotFoundException(user.getId().toString(), User.class);
        } else {
            if(user.getId().equals(id) || user.getRole().equals(UserRole.ADMIN)) {
                u.get().setFullName(editUserDto.getFullName());
                if(editUserDto.getEmail()!=null) {
                    u.get().setEmail(editUserDto.getEmail());
                }
                return userRepository.save(u.get());
            } else {
                throw new ForbiddenException("Permisos insuficientes");
            }
        }
    }
    public User uploadImage (MultipartFile file, User user, UUID id) {
        Optional<User> u1 = userRepository.findById(id);
        if(u1.isEmpty()){
            throw new EntityNotFoundException(user.getId().toString(), User.class);
        }else{
            if(user.getId().equals(id) || user.getRole().equals(UserRole.ADMIN)) {
                String uri = storageService.store(file);
                u1.get().setImage(storageService.uriComplete(uri));
                return userRepository.save(u1.get());
            } else {
                throw new ForbiddenException("Permisos insuficientes");
            }
        }
    }

    public User giveAdmin (User user, UUID idUser){
        if(user.getRole().equals(UserRole.ADMIN)){
            Optional<User> u = userRepository.findById(idUser);
            if(u.isPresent()){
                u.get().setRole(UserRole.ADMIN);
                return userRepository.save(u.get());
            } else {
                throw new EntityNotFoundException(idUser.toString(), User.class);
            }
        }else{
            throw new ForbiddenException("No tiene permisos para realizar esta acción");
        }
    }

    public User removeAdmin (User user, UUID idUser){
        if (user.getId().equals(idUser)) {
            throw new BadRequestException("No puede quitarse el rol de administrador a sí mismo");
        }
        if(user.getRole().equals(UserRole.ADMIN)){
            Optional<User> u = userRepository.findById(idUser);
            if(u.isPresent()){
                u.get().setRole(UserRole.USER);
                return userRepository.save(u.get());
            } else {
                throw new EntityNotFoundException(idUser.toString(), User.class);
            }
        }else{
            throw new ForbiddenException("No tiene permisos para realizar esta acción");
        }
    }


    public Optional<User> editPassword(UUID userId, String newPassword) {

        // Aquí no se realizan comprobaciones de seguridad. Tan solo se modifica

        return userRepository.findById(userId).map(u -> {
            u.setPassword(passwordEncoder.encode(newPassword));
            return userRepository.save(u);
        }).or(() -> Optional.empty());

    }

    public void delete(User user) {
        deleteById(user.getId());
    }

    public void deleteById(UUID id) {
        // Prevenimos errores al intentar borrar algo que no existe
        if (userRepository.existsById(id)) userRepository.deleteById(id);
    }

    public boolean passwordMatch(User user, String clearPassword) {
        return passwordEncoder.matches(clearPassword, user.getPassword());
    }
    public User changePassword(PasswordDto passwordDto, User user) {
        User u = userRepository.findById(user.getId())
                .orElseThrow(() -> new EntityNotFoundException(user.getId().toString(), User.class));

        if (!passwordEncoder.matches(passwordDto.getPassword(), u.getPassword())) {
            throw new BadRequestException("La contraseña actual no es correcta");
        }
        if (!passwordDto.getPasswordNew().equals(passwordDto.getPasswordNewVerify())) {
            throw new BadRequestException("Las contraseñas nuevas no coinciden");
        }
        u.setPassword(passwordEncoder.encode(passwordDto.getPasswordNew()));
        u.setLastPasswordChangeAt(LocalDateTime.now());
        return userRepository.save(u);
    }

    @Transactional
    public void deleteUser(User principal, UUID id) {
        if (principal.getRole() != UserRole.ADMIN) {
            throw new ForbiddenException("No tiene permisos para realizar esta acción");
        }
        if (principal.getId().equals(id)) {
            throw new BadRequestException("No puede eliminar su propia cuenta");
        }
        User u = userRepository.findById(id)
                .orElseThrow(() -> new EntityNotFoundException(id.toString(), User.class));
        if (!purchaseRepository.findByCartUserOrderByPurchaseDateDesc(u, Pageable.ofSize(1)).isEmpty()) {
            throw new BadRequestException("No se puede eliminar un usuario con compras registradas");
        }
        refreshTokenRepository.deleteByUser(u);
        u.getFavoritos().forEach(m -> m.getUsersMangaFavorite().remove(u));
        u.getFavoritos().clear();
        userRepository.delete(u);
    }

    public Page<GetUserDto> findAllUsers (Pageable pageable) {
        return userRepository.findAll(pageable).map(userDtoConverter::userToGetUserDto);
    }
    private Page<User> find(Optional<String> username, Optional<String> fullname, Optional<String> email
            , Optional<UserRole> role, Pageable pageable) {
        Specification<User> specUsername = (username.isPresent() && !username.get().isEmpty())
                ? (root, query, criteriaBuilder) ->
                criteriaBuilder.like(criteriaBuilder.lower(root.get("username")), "%" + username.get().toLowerCase() + "%")
                : null;

        Specification<User> specFullname = (fullname.isPresent() && !fullname.get().isEmpty())
                ? (root, query, criteriaBuilder) ->
                criteriaBuilder.like(criteriaBuilder.lower(root.get("fullName")), "%" + fullname.get().toLowerCase() + "%")
                : null;

        Specification<User> specEmail = (email.isPresent() && !email.get().isEmpty())
                ? (root, query, criteriaBuilder) ->
                criteriaBuilder.like(criteriaBuilder.lower(root.get("email")), "%" + email.get().toLowerCase() + "%")
                : null;

        Specification<User> specRole = role.isPresent()
                ? (root, query, criteriaBuilder) ->
                criteriaBuilder.equal(root.get("role"), role.get())
                : null;

        Specification<User> spec = Specification.where(specUsername)
                .or(specFullname)
                .or(specEmail)
                .and(specRole);

        return this.userRepository.findAll(spec, pageable);
    }

    public Page<GetUserDto> findUser(User user, SearchUserDto u, Pageable pageable){

        if(user.getRole().equals(UserRole.ADMIN)){
            Page<User> lista = find(Optional.ofNullable(u.getUsername()),
                    Optional.ofNullable(u.getFullName()),
                    Optional.ofNullable(u.getEmail()),
                    Optional.ofNullable(u.getRole()),
                    pageable);

                return lista.map(userDtoConverter::userToGetUserDto);

        }else{
            throw new ForbiddenException("No tiene permisos para realizar esta acción");
        }
    }

}
