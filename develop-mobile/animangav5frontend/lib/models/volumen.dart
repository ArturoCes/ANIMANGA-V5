import 'package:animangav4frontend/models/category.dart';

class Volumen {
  Volumen({
    required this.id,
    required this.idManga,
    required this.nombre,
    required this.precio,
    required this.isbn,
    required this.cantidad,
    required this.posterPath,
    required this.nameManga,
    required this.descriptionManga,
    required this.releaseDateManga,
    required this.posterPathManga,
    required this.authorManga,
    required this.categoriesManga,
  });
  late final String id;
  late final String idManga;
  late final String nombre;
  late final double precio;
  late final String isbn;
  late final int cantidad;
  late final String posterPath;
  late final String nameManga;
  late final String descriptionManga;
  late final String releaseDateManga;
  late final String posterPathManga;
  late final String authorManga;
  late final List<Category> categoriesManga;

  Volumen.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    nombre = json['nombre'];
    precio = json['precio'];
    isbn = json['isbn'];
    cantidad = json['cantidad'];
    posterPath = json['posterPath'];
    nameManga = json['nameManga'];
    descriptionManga = json['descriptionManga'];
    releaseDateManga = json['releaseDateManga'];
    posterPathManga = json['posterPathManga'];
    authorManga = json['authorManga'];
    categoriesManga =  List.from(json['categoriesManga']).map((e)=>Category.fromJson(e)).toList();
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['id'] = id;
    _data['nombre'] = nombre;
    _data['precio'] = precio;
    _data['isbn'] = isbn;
    _data['cantidad'] = cantidad;
    _data['posterPath'] = posterPath;
    _data['nameManga'] = nameManga;
    _data['descriptionManga'] = descriptionManga;
    _data['releaseDateManga'] = releaseDateManga;
    _data['posterPathManga'] = posterPathManga;
    _data['authorManga'] = authorManga;
    _data['categoriesManga'] = categoriesManga.map((e)=>e.toJson()).toList();;

    return _data;
  }
}

