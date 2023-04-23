package com.salesianos.triana.backend.Animangav5.repository;

import com.salesianos.triana.backend.Animangav5.models.Category;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.domain.Specification;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.UUID;

public interface CategoryRepository extends JpaRepository<Category, UUID> {


    Page<Category> findAll(Specification<Category> todas, Pageable pageable);
}
