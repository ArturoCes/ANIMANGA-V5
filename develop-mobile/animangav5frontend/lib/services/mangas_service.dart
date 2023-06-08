import 'dart:convert';
import 'package:animangav4frontend/models/SearchDto.dart';
import 'package:animangav4frontend/models/category.dart';
import 'package:animangav4frontend/models/character.dart';
import 'package:animangav4frontend/models/favoriteDto.dart';
import 'package:animangav4frontend/models/manga.dart';
import 'package:animangav4frontend/repositories/mangasRepository.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

import 'localstorage_service.dart';

//import '../exceptions/exceptions.dart';

abstract class MangasService {
  Future<MangaResponse> findAll(int startIndex);
  Future<Manga> findMangaById(String id);
  Future<CharacterResponse> findCharactersByMangaId(String id);
  Future<CategoryResponse> findAllCategories();
  Future<MangaResponse> findAllCategoriesManga(String name);
  Future<Manga> addMangaFavorite(String id);
  Future<FavoriteResponse> isMangaFavorite(String id);
  Future<Manga> removeMangaFavorite(String id);
  Future<MangaResponse> findAllFavoritesMangas(String username);
  Future<MangaResponse> findMangaByName(SearchDto searchDto);
}

//@Singleton(as: AuthenticationService)
@Order(3)
@singleton
class MangaService extends MangasService {
  late MangasRepository _mangasRepository;
  late LocalStorageService _localStorageService;

  MangaService() {
    _mangasRepository = GetIt.I.get<MangasRepository>();
    GetIt.I
        .getAsync<LocalStorageService>()
        .then((value) => _localStorageService = value);
  }

  @override
  Future<MangaResponse> findAll(int startIndex) async {
    dynamic response = await _mangasRepository.findAll(startIndex);
    if (response != null) {
      return response;
    } else {
      throw Exception('Error al cargar los Mangas');
    }
  }

  @override
  Future<Manga> findMangaById(String id) async {
    dynamic response = await _mangasRepository.findMangaById(id);
    if (response != null) {
      return response;
    } else {
      throw Exception('Error al cargar los Mangas');
    }
  }

  @override
  Future<CharacterResponse> findCharactersByMangaId(String id) async {
    dynamic response = await _mangasRepository.findCharactersByMangaId(id);

    return response;
  }

  @override
  Future<CategoryResponse> findAllCategories() async {
    dynamic response = await _mangasRepository.findAllCategories();
    return response;
  }

  @override
  Future<MangaResponse> findAllCategoriesManga(String name) async {
    dynamic response = await _mangasRepository.findAllCategoriesManga(name);
    return response;
  }

  @override
  Future<Manga> addMangaFavorite(String id) async {
    dynamic response = await _mangasRepository.addMangaFavorite(id);
    return response;
  }

  @override
  Future<FavoriteResponse> isMangaFavorite(String id) async {
    dynamic response = await _mangasRepository.isMangaFavorite(id);
    return response;
  }

  @override
  Future<Manga> removeMangaFavorite(String id) async {
    dynamic response = await _mangasRepository.removeMangaFavorite(id);
    return response;
  }

  @override
  Future<MangaResponse> findAllFavoritesMangas(String username) async {
    dynamic response = await _mangasRepository.findAllFavoritesMangas(username);
    return response;
  }

  @override
  Future<MangaResponse> findMangaByName(SearchDto searchDto) async {
    dynamic response = await _mangasRepository.findMangaByName(searchDto);
    return response;
  }
}
