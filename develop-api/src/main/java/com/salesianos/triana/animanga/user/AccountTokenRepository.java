package com.salesianos.triana.animanga.user;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;

import java.util.Optional;
import java.util.UUID;

public interface AccountTokenRepository extends JpaRepository<AccountToken, UUID> {

    Optional<AccountToken> findByTokenHashAndType(String tokenHash, AccountToken.Type type);

    @Modifying
    @Query("delete from AccountToken t where t.user = :user and t.type = :type")
    void deleteByUserAndType(User user, AccountToken.Type type);

    @Modifying
    @Query("delete from AccountToken t where t.user = :user")
    void deleteByUser(User user);
}
