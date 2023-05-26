import 'dart:convert';
import 'package:animangav4frontend/models/character.dart';
import 'package:animangav4frontend/models/manga.dart';
import 'package:animangav4frontend/rest/rest_client.dart';
import 'package:get_it/get_it.dart';
import 'package:get_storage/get_storage.dart';
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
}
