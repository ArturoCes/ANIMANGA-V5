import 'dart:convert';
import 'package:animangav4frontend/models/character.dart';
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
}
