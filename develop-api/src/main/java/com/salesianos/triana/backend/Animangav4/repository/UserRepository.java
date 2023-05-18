package com.salesianos.triana.backend.Animangav4.repository;

import com.salesianos.triana.backend.Animangav4.models.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import java.util.Optional;
import java.util.UUID;

public interface UserRepository extends JpaRepository<User, UUID> {

    Optional<User> findFirstByUsername(String username);

    boolean existsByUsername(String username);

    boolean existsByEmail(String email);


    @Query("SELECT u.email FROM User u WHERE u.username = :username")
    String existsEmailWithUsername(String username);
}
