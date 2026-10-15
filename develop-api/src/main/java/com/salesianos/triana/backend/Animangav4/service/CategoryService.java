package com.salesianos.triana.backend.Animangav4.service;

import com.salesianos.triana.backend.Animangav4.dtos.CategoryDtoConverter;
import com.salesianos.triana.backend.Animangav4.dtos.CreateCategoryDto;
import com.salesianos.triana.backend.Animangav4.dtos.GetCategoryDto;
import com.salesianos.triana.backend.Animangav4.dtos.SearchCategoryDto;
import com.salesianos.triana.backend.Animangav4.exception.EntityNotFoundException;
import com.salesianos.triana.backend.Animangav4.exception.ForbiddenException;
import com.salesianos.triana.backend.Animangav4.exception.ListNotFoundException;
import com.salesianos.triana.backend.Animangav4.models.Category;
import com.salesianos.triana.backend.Animangav4.models.User;
import com.salesianos.triana.backend.Animangav4.models.UserRole;
import com.salesianos.triana.backend.Animangav4.repository.CategoryRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.domain.Specification;
import org.springframework.stereotype.Service;

import org.springframework.transaction.annotation.Transactional;
import com.salesianos.triana.backend.Animangav4.models.Manga;
import com.salesianos.triana.backend.Animangav4.repository.MangaRepository;
import java.util.UUID;

import java.util.Optional;

@Service
@RequiredArgsConstructor
public class CategoryService {

    private final CategoryRepository categoryRepository;

    private final CategoryDtoConverter categoryDtoConverter;
    private final MangaRepository mangaRepository;


    public GetCategoryDto save(CreateCategoryDto createCategoryDto, User user){
        if(user.getRole().equals(UserRole.ADMIN)){
            Category category = categoryDtoConverter.createCategoryDtoToCategory(createCategoryDto);
            categoryRepository.save(category);
            return categoryDtoConverter.categoryToCategoryDto(category);
        } else {
            throw new ForbiddenException("No tiene permisos para realizar esta acción");
        }
    }

    public Category findById (UUID id) {
        return categoryRepository.findById(id)
                .orElseThrow(() -> new EntityNotFoundException(id.toString(), Category.class));
    }

    public Category editCategory (CreateCategoryDto c, User user, UUID id) {

        Optional<Category> g1 = categoryRepository.findById(id);

        if(g1.isEmpty()){
            throw new EntityNotFoundException(id.toString(), Category.class);
        } else {
            if(user.getRole().equals(UserRole.ADMIN)){
                g1.get().setName(c.getName());
                g1.get().setDescription(c.getDescription());
                return categoryRepository.save(g1.get());
            } else {
                throw new ForbiddenException("No tiene permisos para realizar esta acción");
            }
        }
    }

    @Transactional
    public void deleteCategory (UUID id) {
        Category c = categoryRepository.findById(id)
                .orElseThrow(() -> new EntityNotFoundException(id.toString(), Category.class));
        // Se desvincula de los mangas antes de borrarla para no romper la FK
        for (Manga m : mangaRepository.findAllByCategoriesContains(c)) {
            m.getCategories().remove(c);
            mangaRepository.save(m);
        }
        categoryRepository.delete(c);
    }

    public Page<GetCategoryDto> findAllCategories (Pageable pageable) {
        return categoryRepository.findAll(pageable).map(categoryDtoConverter::categoryToCategoryDto);
    }

    public Page<GetCategoryDto> searchCategory(User user, SearchCategoryDto s, Pageable pageable){
        if(user.getRole().equals(UserRole.ADMIN)){
            Page<Category> lista = search(Optional.ofNullable(s.getName()),
                    Optional.ofNullable(s.getDescription()), pageable);
            return lista.map(categoryDtoConverter::categoryToCategoryDto);
        }else{
            throw new ForbiddenException("No tiene permisos para realizar esta acción");
        }
    }

    private Page<Category> search(Optional<String> name, Optional<String> description, Pageable pageable) {
        Specification<Category> specName = (root, query, criteriaBuilder) -> {
            if (name.isPresent()) {
                return criteriaBuilder.like(criteriaBuilder.lower(root.get("name")), "%" + name.get().toLowerCase() + "%");
            } else {
                return criteriaBuilder.isTrue(criteriaBuilder.literal(true));
            }
        };

        Specification<Category> specDescription = (root, query, criteriaBuilder) -> {
            if (description.isPresent()) {
                return criteriaBuilder.like(criteriaBuilder.lower(root.get("description")), "%" + description.get().toLowerCase() + "%");
            } else {
                return criteriaBuilder.isTrue(criteriaBuilder.literal(true));
            }
        };

        Specification<Category> todas =
                specName
                        .or(specDescription);

        return this.categoryRepository.findAll(todas, pageable);
    }

}