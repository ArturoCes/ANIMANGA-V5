/// Modelos de la API. Solo se mapean los campos que usa la app.
library;

class PageResult<T> {
  PageResult({required this.content, required this.totalElements, required this.last});

  factory PageResult.fromJson(Map<String, dynamic> json, T Function(Map<String, dynamic>) item) => PageResult(
        content: (json['content'] as List? ?? []).map((e) => item(e as Map<String, dynamic>)).toList(),
        totalElements: json['totalElements'] as int? ?? 0,
        last: json['last'] as bool? ?? true,
      );

  final List<T> content;
  final int totalElements;
  final bool last;
}

class Category {
  Category({required this.id, required this.name, required this.description});

  factory Category.fromJson(Map<String, dynamic> json) => Category(
        id: json['id'] as String,
        name: json['name'] as String? ?? '',
        description: json['description'] as String? ?? '',
      );

  final String id;
  final String name;
  final String description;
}

class Volumen {
  Volumen({
    required this.id,
    required this.nombre,
    required this.precio,
    required this.cantidad,
    required this.isbn,
    required this.posterPath,
    required this.idManga,
    required this.nameManga,
  });

  factory Volumen.fromJson(Map<String, dynamic> json) => Volumen(
        id: json['id'] as String,
        nombre: json['nombre'] as String? ?? '',
        precio: (json['precio'] as num?)?.toDouble() ?? 0,
        cantidad: json['cantidad'] as int? ?? 0,
        isbn: json['isbn'] as String? ?? '',
        posterPath: json['posterPath'] as String? ?? '',
        idManga: json['idManga'] as String? ?? '',
        nameManga: json['nameManga'] as String? ?? '',
      );

  final String id;
  final String nombre;
  final double precio;
  final int cantidad;
  final String isbn;
  final String posterPath;
  final String idManga;
  final String nameManga;

  bool get soldOut => cantidad <= 0;
}

class Manga {
  Manga({
    required this.id,
    required this.name,
    required this.description,
    required this.author,
    required this.publisher,
    required this.releaseDate,
    required this.posterPath,
    required this.categories,
    required this.volumenes,
  });

  factory Manga.fromJson(Map<String, dynamic> json) {
    final volumes = (json['volumenes'] as List? ?? []).map((e) => Volumen.fromJson(e as Map<String, dynamic>)).toList()
      ..sort((a, b) => _naturalCompare(a.nombre, b.nombre));
    return Manga(
      id: json['id'] as String,
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      author: json['author'] as String? ?? '',
      publisher: json['publisher'] as String? ?? '',
      releaseDate: DateTime.tryParse(json['releaseDate'] as String? ?? ''),
      posterPath: json['posterPath'] as String? ?? '',
      categories: (json['categories'] as List? ?? []).map((e) => Category.fromJson(e as Map<String, dynamic>)).toList(),
      volumenes: volumes,
    );
  }

  final String id;
  final String name;
  final String description;
  final String author;
  final String publisher;
  final DateTime? releaseDate;
  final String posterPath;
  final List<Category> categories;
  final List<Volumen> volumenes;

  double? get minPrice => volumenes.isEmpty ? null : volumenes.map((v) => v.precio).reduce((a, b) => a < b ? a : b);
}

class Character {
  Character(
      {required this.id, required this.name, required this.age, required this.description, required this.imageUrl});

  factory Character.fromJson(Map<String, dynamic> json) => Character(
        id: json['id'] as String,
        name: json['name'] as String? ?? '',
        age: json['age'] as int?,
        description: json['description'] as String? ?? '',
        imageUrl: json['imageUrl'] as String? ?? '',
      );

  final String id;
  final String name;
  final int? age;
  final String description;
  final String imageUrl;
}

class User {
  User({
    required this.id,
    required this.username,
    required this.fullName,
    required this.email,
    required this.image,
    required this.role,
    required this.idCart,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json['id'] as String,
        username: json['username'] as String? ?? '',
        fullName: json['fullName'] as String? ?? '',
        email: json['email'] as String? ?? '',
        image: json['image'] as String? ?? '',
        role: json['role'] as String? ?? 'USER',
        idCart: json['idCart'] as String? ?? '',
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'username': username,
        'fullName': fullName,
        'email': email,
        'image': image,
        'role': role,
        'idCart': idCart,
      };

  final String id;
  final String username;
  final String fullName;
  final String email;
  final String image;
  final String role;
  final String idCart;
}

class CartItem {
  CartItem({required this.id, required this.quantity, required this.volumen});

  factory CartItem.fromJson(Map<String, dynamic> json) => CartItem(
        id: json['id'] as String,
        quantity: json['quantity'] as int? ?? 1,
        volumen: Volumen.fromJson(json['volumen'] as Map<String, dynamic>),
      );

  final String id;
  final int quantity;
  final Volumen volumen;

  double get subtotal => volumen.precio * quantity;
}

class Purchase {
  Purchase({
    required this.id,
    required this.card,
    required this.nombreVolumen,
    required this.nameManga,
    required this.posterPath,
    required this.quantity,
    required this.precio,
    required this.total,
    required this.date,
  });

  factory Purchase.fromJson(Map<String, dynamic> json) => Purchase(
        id: json['idPurchase'] as String,
        card: json['numCreditCard'] as String? ?? '',
        nombreVolumen: json['nombreVolumen'] as String? ?? '',
        nameManga: json['nameManga'] as String? ?? '',
        posterPath: json['posterPath'] as String? ?? '',
        quantity: json['quantity'] as int? ?? 1,
        precio: (json['precio'] as num?)?.toDouble() ?? 0,
        total: (json['total'] as num?)?.toDouble() ?? 0,
        date: DateTime.tryParse(json['purchaseDate'] as String? ?? '') ?? DateTime.now(),
      );

  final String id;
  final String card;
  final String nombreVolumen;
  final String nameManga;
  final String posterPath;
  final int quantity;
  final double precio;
  final double total;
  final DateTime date;
}

/// Ordena "Tomo 2" antes que "Tomo 10".
int _naturalCompare(String a, String b) {
  final re = RegExp(r'(\d+)$');
  final ma = re.firstMatch(a), mb = re.firstMatch(b);
  if (ma != null && mb != null && a.substring(0, ma.start) == b.substring(0, mb.start)) {
    return int.parse(ma.group(1)!).compareTo(int.parse(mb.group(1)!));
  }
  return a.compareTo(b);
}
