import 'dart:convert';
import 'package:animangav4frontend/models/SearchDto.dart';
import 'package:animangav4frontend/models/category.dart';
import 'package:animangav4frontend/models/character.dart';
import 'package:animangav4frontend/models/favoriteDto.dart';
import 'package:animangav4frontend/models/manga.dart';
import 'package:animangav4frontend/rest/rest_client.dart';
import 'package:get_it/get_it.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart';
import 'package:injectable/injectable.dart';

@Order(-1)
@singleton
class MangasRepository {
  late RestClient _client;
  final box = GetStorage();
  MangasRepository() {
    _client = GetIt.I.get<RestClient>();
    //_client = RestClient();
  }

  Future<dynamic> findAll(int startIndex) async {
    String url = "/manga/all?size=$startIndex";

    Map<String, String> headers = {
      'Authorization': 'Bearer ${box.read('token')}'
    };

    var jsonResponse = await _client.get(url, headers: headers);
    return MangaResponse.fromJson(jsonDecode(jsonResponse));
  }

  Future<dynamic> findMangaById(String id) async {
    String url = "/manga/${id}";
    Map<String, String> headers = {
      'Authorization': 'Bearer ${box.read('token')}'
    };
    var jsonResponse = await _client.get(url, headers: headers);
    return Manga.fromJson(jsonDecode(jsonResponse));
  }

  Future<dynamic> findCharactersByMangaId(String id) async {
    String url = "/manga/${id}/characters?size=5";
    Map<String, String> headers = {
      'Authorization': 'Bearer ${box.read('token')}'
    };

    var jsonResponse = await _client.get(url, headers: headers);
    return CharacterResponse.fromJson(jsonDecode(jsonResponse));
  }

  Future<dynamic>findAllCategories() async {
    String url =  "/category/all";
    Map<String, String> headers = {
      'Authorization': 'Bearer ${box.read('token')}'
    };

    var jsonResponse = await _client.get(url, headers: headers);
    return CategoryResponse.fromJson(jsonDecode(jsonResponse));

  }
  
  Future<dynamic>findAllCategoriesManga(String name) async {
    String url =  "/manga/all/categories/${name}";
    Map<String, String> headers = {
      'Authorization': 'Bearer ${box.read('token')}'
    };

    var jsonResponse = await _client.get(url, headers: headers);
    return MangaResponse.fromJson(jsonDecode(jsonResponse));

  }

  Future<dynamic>addMangaFavorite(String id) async {
    String url =  "/manga/favorite/${id}";
    Map<String, String> headers = {
      'Authorization': 'Bearer ${box.read('token')}'
    };

    var jsonResponse = await _client.post2(url, headers: headers);
    return Manga.fromJson(jsonDecode(jsonResponse));

  }

   Future<dynamic>isMangaFavorite(String id) async {
    String url =  "/manga/favorite/bool/${id}";
    Map<String, String> headers = {
      'Authorization': 'Bearer ${box.read('token')}'
    };

    var jsonResponse = await _client.get(url, headers: headers);
    return FavoriteResponse.fromJson(jsonDecode(jsonResponse));

  }
   Future<dynamic>removeMangaFavorite(String id) async {
    String url =  "/manga/favorite/remove/${id}";
    Map<String, String> headers = {
      'Authorization': 'Bearer ${box.read('token')}'
    };

    var jsonResponse = await _client.post2(url, headers: headers);
    return Manga.fromJson(jsonDecode(jsonResponse));

  }
  Future<dynamic>findAllFavoritesMangas(String username) async {
    String url =  "/manga/all/favorite/${username}";
    Map<String, String> headers = {
      'Authorization': 'Bearer ${box.read('token')}'
    };

    var jsonResponse = await _client.get(url, headers: headers);
    return MangaResponse.fromJson(jsonDecode(jsonResponse));

  }

   Future<dynamic>findMangaByName(SearchDto searchDto) async {
    String url =  "/manga/search/all";
    String bodyName = 'search';

    var jsonResponse = await _client.multipartRequestGeneric(url, searchDto, bodyName);
    return jsonResponse;

  }
  }
