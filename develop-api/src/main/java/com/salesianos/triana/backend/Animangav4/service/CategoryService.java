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
import java.util.UUID;

import java.util.Optional;

@Service
@RequiredArgsConstructor
public class CategoryService {

    private final CategoryRepository categoryRepository;

    private final CategoryDtoConverter categoryDtoConverter;


    public GetCategoryDto save(CreateCategoryDto createCategoryDto, User user){
        System.out.println(user.getRole());
        if(user.getRole().equals(UserRole.USER)){
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

    public void deleteCategory (UUID id) {
        Optional<Category> c = categoryRepository.findById(id);

        if(c.isEmpty()) {
            throw new EntityNotFoundException(id.toString(), Category.class);
        } else {
            categoryRepository.deleteById(id);
        }
    }

    public Page<GetCategoryDto> findAllCategories (Pageable pageable) {
        Page<Category> lista = categoryRepository.findAll(pageable);

        if(lista.isEmpty()) {
            throw new ListNotFoundException(Category.class);
        } else {
            return lista.map(categoryDtoConverter::categoryToCategoryDto);
        }
    }

    public Page<GetCategoryDto> searchCategory(User user, SearchCategoryDto s, Pageable pageable){
        if(user.getRole().equals(UserRole.ADMIN)){
            Page<Category> lista = search(Optional.ofNullable(s.getName()),
                    Optional.ofNullable(s.getDescription()), pageable);
            if(lista.isEmpty()){
                throw new ListNotFoundException(Category.class);
            } else {
                return lista.map(categoryDtoConverter::categoryToCategoryDto);
            }
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