import 'package:animangav4frontend/models/volumen.dart';

import 'category.dart';

class CartResponse {
  late final List<Item> content;
  late final Pageable pageable;
  late final bool last;
  late final int totalPages;
  late final int totalElements;
  late final int size;
  late final int number;
  late final Sort sort;
  late final bool first;
  late final int numberOfElements;
  late final bool empty;

  CartResponse(
      {required this.content,
      required this.pageable,
      required this.last,
      required this.totalPages,
      required this.totalElements,
      required this.size,
      required this.number,
      required this.sort,
      required this.first,
      required this.numberOfElements,
      required this.empty});

  CartResponse.fromJson(Map<String, dynamic> json) {
    content = List.from(json['content']).map((e) => Item.fromJson(e)).toList();
    pageable = Pageable.fromJson(json['pageable']);
    last = json['last'];
    totalPages = json['totalPages'];
    totalElements = json['totalElements'];
    size = json['size'];
    number = json['number'];
    sort = Sort.fromJson(json['sort']);
    first = json['first'];
    numberOfElements = json['numberOfElements'];
    empty = json['empty'];
  }

 Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['content'] = content.map((e) => e.toJson()).toList();
    _data['pageable'] = pageable.toJson();
    _data['last'] = last;
    _data['totalPages'] = totalPages;
    _data['totalElements'] = totalElements;
    _data['size'] = size;
    _data['number'] = number;
    _data['sort'] = sort.toJson();
    _data['first'] = first;
    _data['numberOfElements'] = numberOfElements;
    _data['empty'] = empty;
    return _data;
  }
}

class Item {
  late final String id;
  late final String idCarrito;
  late final int quantity;
  late final Volumen volumen;

  Item(
      {required this.id,
      required this.idCarrito,
      required this.quantity,
      required this.volumen});

  Item.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    idCarrito = json['idCarrito'];
    quantity = json['quantity'];
    volumen = Volumen.fromJson(json['volumen']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['idCarrito'] = this.idCarrito;
    data['quantity'] = this.quantity;
    data['volumen'] = volumen.toJson();
    return data;
  }
}
