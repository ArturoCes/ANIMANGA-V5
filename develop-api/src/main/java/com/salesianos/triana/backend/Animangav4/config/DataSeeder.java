package com.salesianos.triana.backend.Animangav4.config;

import com.salesianos.triana.backend.Animangav4.models.*;
import com.salesianos.triana.backend.Animangav4.repository.CartRepository;
import com.salesianos.triana.backend.Animangav4.repository.PurchaseRepository;
import com.salesianos.triana.backend.Animangav4.repository.UserRepository;
import com.salesianos.triana.backend.Animangav4.repository.VolumenRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.java.Log;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.context.event.ApplicationReadyEvent;
import org.springframework.context.ApplicationListener;
import org.springframework.core.io.Resource;
import org.springframework.core.io.support.PathMatchingResourcePatternResolver;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

import java.io.IOException;
import java.io.InputStream;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.UUID;

/**
 * Prepara la aplicación para la demo:
 * - copia las portadas de ejemplo al directorio de subidas,
 * - crea los usuarios de demostración (con contraseña cifrada) y su carrito,
 * - registra un par de compras de ejemplo para que el panel no aparezca vacío.
 */
@Log
@Component
@RequiredArgsConstructor
public class DataSeeder implements ApplicationListener<ApplicationReadyEvent> {

    private final UserRepository userRepository;
    private final CartRepository cartRepository;
    private final VolumenRepository volumenRepository;
    private final PurchaseRepository purchaseRepository;
    private final PasswordEncoder passwordEncoder;

    @Value("${storage.location}")
    private String storageLocation;

    @Value("${app.demo.admin-password:Admin1234}")
    private String adminPassword;

    @Value("${app.demo.user-password:Demo1234}")
    private String demoPassword;

    @Override
    @Transactional
    public void onApplicationEvent(ApplicationReadyEvent event) {
        copySeedCovers();

        createUserIfMissing("admin", "Administrador", "admin@animanga.dev", adminPassword, UserRole.ADMIN);
        User demo = createUserIfMissing("demo", "Usuario Demo", "demo@animanga.dev", demoPassword, UserRole.USER);
        createUserIfMissing("laura", "Laura Martín", "laura@animanga.dev", demoPassword, UserRole.USER);

        // Cualquier usuario sin carrito (p. ej. de una versión anterior) recibe uno
        userRepository.findAll().stream()
                .filter(u -> u.getCarrito() == null)
                .forEach(this::createCart);

        if (purchaseRepository.count() == 0) {
            seedPurchase(demo, "b0b0b0b0-0000-4000-8000-000000000001", 1);
            seedPurchase(demo, "b0b0b0b0-0000-4000-8000-000000000100", 2);
        }
    }

    private User createUserIfMissing(String username, String fullName, String email, String rawPassword, UserRole role) {
        return userRepository.findFirstByUsername(username).orElseGet(() -> {
            User user = userRepository.save(User.builder()
                    .username(username)
                    .fullName(fullName)
                    .email(email)
                    .password(passwordEncoder.encode(rawPassword))
                    .image("https://ui-avatars.com/api/?background=7b1fa2&color=fff&name=" + fullName.replace(" ", "+"))
                    .role(role)
                    .build());
            createCart(user);
            return user;
        });
    }

    private void createCart(User user) {
        Cart cart = new Cart();
        cart.setUser(user);
        cartRepository.save(cart);
        user.setCarrito(cart);
        userRepository.save(user);
    }

    private void seedPurchase(User user, String volumenId, int quantity) {
        volumenRepository.findById(UUID.fromString(volumenId)).ifPresent(v ->
                purchaseRepository.save(Purchase.builder()
                        .cart(user.getCarrito())
                        .volumen(v)
                        .quantity(quantity)
                        .unitPrice(v.getPrecio())
                        .numCreditCard("**** **** **** 4242")
                        .build()));
    }

    private void copySeedCovers() {
        try {
            Path target = Paths.get(storageLocation);
            Files.createDirectories(target);
            Resource[] covers = new PathMatchingResourcePatternResolver().getResources("classpath:seed/covers/*");
            for (Resource cover : covers) {
                Path dest = target.resolve(cover.getFilename());
                if (!Files.exists(dest)) {
                    try (InputStream in = cover.getInputStream()) {
                        Files.copy(in, dest);
                    }
                }
            }
        } catch (IOException e) {
            log.warning("No se pudieron copiar las portadas de ejemplo: " + e.getMessage());
        }
    }
}
