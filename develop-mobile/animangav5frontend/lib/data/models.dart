/// Modelos de la API. Solo se mapean los campos que usa la app.
library;

double _toDouble(Object? v) => (v as num?)?.toDouble() ?? 0;

class PageResult<T> {
  PageResult({required this.content, required this.totalElements, required this.last, required this.page});

  factory PageResult.fromJson(Map<String, dynamic> json, T Function(Map<String, dynamic>) item) => PageResult(
        content: (json['content'] as List? ?? []).map((e) => item(e as Map<String, dynamic>)).toList(),
        totalElements: json['totalElements'] as int? ?? 0,
        last: json['last'] as bool? ?? true,
        page: json['page'] as int? ?? 0,
      );

  final List<T> content;
  final int totalElements;
  final bool last;
  final int page;
}

class Category {
  Category({required this.id, required this.name, this.description});

  factory Category.fromJson(Map<String, dynamic> json) => Category(
        id: json['id'] as String,
        name: json['name'] as String? ?? '',
        description: json['description'] as String?,
      );

  final String id;
  final String name;
  final String? description;
}

class Volume {
  Volume({
    required this.id,
    required this.mangaId,
    required this.mangaTitle,
    required this.number,
    required this.title,
    required this.price,
    required this.isbn,
    required this.stock,
    required this.coverImage,
  });

  factory Volume.fromJson(Map<String, dynamic> json) => Volume(
        id: json['id'] as String,
        mangaId: json['mangaId'] as String? ?? '',
        mangaTitle: json['mangaTitle'] as String? ?? '',
        number: json['number'] as int? ?? 0,
        title: json['title'] as String? ?? '',
        price: _toDouble(json['price']),
        isbn: json['isbn'] as String?,
        stock: json['stock'] as int? ?? 0,
        coverImage: json['coverImage'] as String? ?? '',
      );

  final String id;
  final String mangaId;
  final String mangaTitle;
  final int number;
  final String title;
  final double price;
  final String? isbn;
  final int stock;
  final String coverImage;

  bool get soldOut => stock <= 0;
}

class MangaCharacter {
  MangaCharacter({required this.id, required this.name, this.age, this.description, this.image});

  factory MangaCharacter.fromJson(Map<String, dynamic> json) => MangaCharacter(
        id: json['id'] as String,
        name: json['name'] as String? ?? '',
        age: json['age'] as int?,
        description: json['description'] as String?,
        image: json['image'] as String?,
      );

  final String id;
  final String name;
  final int? age;
  final String? description;
  final String? image;
}

/// Manga en listados (catálogo, portada, favoritos).
class MangaSummary {
  MangaSummary({
    required this.id,
    required this.title,
    required this.author,
    required this.publisher,
    required this.releaseDate,
    required this.coverImage,
    required this.categories,
    required this.minPrice,
    required this.ratingAverage,
    required this.ratingCount,
    required this.inStock,
  });

  factory MangaSummary.fromJson(Map<String, dynamic> json) => MangaSummary(
        id: json['id'] as String,
        title: json['title'] as String? ?? '',
        author: json['author'] as String? ?? '',
        publisher: json['publisher'] as String? ?? '',
        releaseDate: DateTime.tryParse(json['releaseDate'] as String? ?? ''),
        coverImage: json['coverImage'] as String? ?? '',
        categories: (json['categories'] as List? ?? []).map((e) => e['name'] as String).toList(),
        minPrice: (json['minPrice'] as num?)?.toDouble(),
        ratingAverage: _toDouble(json['ratingAverage']),
        ratingCount: json['ratingCount'] as int? ?? 0,
        inStock: json['inStock'] as bool? ?? false,
      );

  final String id;
  final String title;
  final String author;
  final String publisher;
  final DateTime? releaseDate;
  final String coverImage;
  final List<String> categories;
  final double? minPrice;
  final double ratingAverage;
  final int ratingCount;
  final bool inStock;
}

/// Ficha completa de un manga.
class MangaDetail extends MangaSummary {
  MangaDetail({
    required super.id,
    required super.title,
    required super.author,
    required super.publisher,
    required super.releaseDate,
    required super.coverImage,
    required super.categories,
    required super.minPrice,
    required super.ratingAverage,
    required super.ratingCount,
    required super.inStock,
    required this.synopsis,
    required this.volumes,
    required this.characters,
    required this.favorite,
    required this.myRating,
  });

  factory MangaDetail.fromJson(Map<String, dynamic> json) {
    final s = MangaSummary.fromJson(json);
    return MangaDetail(
      id: s.id,
      title: s.title,
      author: s.author,
      publisher: s.publisher,
      releaseDate: s.releaseDate,
      coverImage: s.coverImage,
      categories: s.categories,
      minPrice: s.minPrice,
      ratingAverage: s.ratingAverage,
      ratingCount: s.ratingCount,
      inStock: s.inStock,
      synopsis: json['synopsis'] as String? ?? '',
      volumes: (json['volumes'] as List? ?? []).map((e) => Volume.fromJson(e as Map<String, dynamic>)).toList(),
      characters:
          (json['characters'] as List? ?? []).map((e) => MangaCharacter.fromJson(e as Map<String, dynamic>)).toList(),
      favorite: json['favorite'] as bool? ?? false,
      myRating: json['myRating'] as int?,
    );
  }

  final String synopsis;
  final List<Volume> volumes;
  final List<MangaCharacter> characters;
  final bool favorite;
  final int? myRating;
}

class HomeSections {
  HomeSections({required this.latest, required this.bestSellers, required this.topRated, required this.recommended});

  factory HomeSections.fromJson(Map<String, dynamic> json) {
    List<MangaSummary> list(String key) =>
        (json[key] as List? ?? []).map((e) => MangaSummary.fromJson(e as Map<String, dynamic>)).toList();
    return HomeSections(
      latest: list('latest'),
      bestSellers: list('bestSellers'),
      topRated: list('topRated'),
      recommended: list('recommended'),
    );
  }

  final List<MangaSummary> latest;
  final List<MangaSummary> bestSellers;
  final List<MangaSummary> topRated;
  final List<MangaSummary> recommended;
}

class Review {
  Review({
    required this.id,
    required this.rating,
    required this.comment,
    required this.createdAt,
    required this.authorName,
    required this.authorUsername,
    required this.authorAvatar,
    required this.verifiedPurchase,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    final author = json['author'] as Map<String, dynamic>? ?? {};
    return Review(
      id: json['id'] as String,
      rating: json['rating'] as int? ?? 0,
      comment: json['comment'] as String?,
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
      authorName: author['fullName'] as String? ?? '',
      authorUsername: author['username'] as String? ?? '',
      authorAvatar: author['avatar'] as String?,
      verifiedPurchase: json['verifiedPurchase'] as bool? ?? false,
    );
  }

  final String id;
  final int rating;
  final String? comment;
  final DateTime createdAt;
  final String authorName;
  final String authorUsername;
  final String? authorAvatar;
  final bool verifiedPurchase;
}

class User {
  User({
    required this.id,
    required this.username,
    required this.fullName,
    required this.email,
    required this.avatar,
    required this.role,
    required this.emailVerified,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json['id'] as String,
        username: json['username'] as String? ?? '',
        fullName: json['fullName'] as String? ?? '',
        email: json['email'] as String? ?? '',
        avatar: json['avatar'] as String?,
        role: json['role'] as String? ?? 'USER',
        emailVerified: json['emailVerified'] as bool? ?? false,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'username': username,
        'fullName': fullName,
        'email': email,
        'avatar': avatar,
        'role': role,
        'emailVerified': emailVerified,
      };

  final String id;
  final String username;
  final String fullName;
  final String email;
  final String? avatar;
  final String role;
  final bool emailVerified;
}

class CartLine {
  CartLine({required this.volume, required this.quantity, required this.subtotal});

  factory CartLine.fromJson(Map<String, dynamic> json) => CartLine(
        volume: Volume.fromJson(json['volume'] as Map<String, dynamic>),
        quantity: json['quantity'] as int? ?? 1,
        subtotal: _toDouble(json['subtotal']),
      );

  final Volume volume;
  final int quantity;
  final double subtotal;
}

class Cart {
  const Cart({this.items = const [], this.totalItems = 0, this.total = 0});

  factory Cart.fromJson(Map<String, dynamic> json) => Cart(
        items: (json['items'] as List? ?? []).map((e) => CartLine.fromJson(e as Map<String, dynamic>)).toList(),
        totalItems: json['totalItems'] as int? ?? 0,
        total: _toDouble(json['total']),
      );

  final List<CartLine> items;
  final int totalItems;
  final double total;

  int quantityOf(String volumeId) => items.where((i) => i.volume.id == volumeId).fold(0, (sum, i) => sum + i.quantity);
}

enum OrderStatus {
  paid('PAID', 'Pagado'),
  shipped('SHIPPED', 'Enviado'),
  delivered('DELIVERED', 'Entregado'),
  cancelled('CANCELLED', 'Cancelado');

  const OrderStatus(this.code, this.label);
  final String code;
  final String label;

  static OrderStatus parse(String? code) => values.firstWhere((s) => s.code == code, orElse: () => paid);
}

class ShippingAddress {
  const ShippingAddress({
    required this.fullName,
    required this.address,
    required this.city,
    required this.postalCode,
    required this.phone,
  });

  factory ShippingAddress.fromJson(Map<String, dynamic> json) => ShippingAddress(
        fullName: json['fullName'] as String? ?? '',
        address: json['address'] as String? ?? '',
        city: json['city'] as String? ?? '',
        postalCode: json['postalCode'] as String? ?? '',
        phone: json['phone'] as String? ?? '',
      );

  Map<String, dynamic> toJson() =>
      {'fullName': fullName, 'address': address, 'city': city, 'postalCode': postalCode, 'phone': phone};

  final String fullName;
  final String address;
  final String city;
  final String postalCode;
  final String phone;
}

class OrderLine {
  OrderLine({
    required this.mangaId,
    required this.volumeTitle,
    required this.coverImage,
    required this.unitPrice,
    required this.quantity,
    required this.subtotal,
  });

  factory OrderLine.fromJson(Map<String, dynamic> json) => OrderLine(
        mangaId: json['mangaId'] as String?,
        volumeTitle: json['volumeTitle'] as String? ?? '',
        coverImage: json['coverImage'] as String?,
        unitPrice: _toDouble(json['unitPrice']),
        quantity: json['quantity'] as int? ?? 1,
        subtotal: _toDouble(json['subtotal']),
      );

  final String? mangaId;
  final String volumeTitle;
  final String? coverImage;
  final double unitPrice;
  final int quantity;
  final double subtotal;
}

class Order {
  Order({
    required this.id,
    required this.number,
    required this.status,
    required this.createdAt,
    required this.shipping,
    required this.cardLast4,
    required this.total,
    required this.totalUnits,
    required this.items,
  });

  factory Order.fromJson(Map<String, dynamic> json) => Order(
        id: json['id'] as String,
        number: json['number'] as String? ?? '',
        status: OrderStatus.parse(json['status'] as String?),
        createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
        shipping: ShippingAddress.fromJson(json['shipping'] as Map<String, dynamic>? ?? {}),
        cardLast4: json['cardLast4'] as String? ?? '',
        total: _toDouble(json['total']),
        totalUnits: json['totalUnits'] as int? ?? 0,
        items: (json['items'] as List? ?? []).map((e) => OrderLine.fromJson(e as Map<String, dynamic>)).toList(),
      );

  final String id;
  final String number;
  final OrderStatus status;
  final DateTime createdAt;
  final ShippingAddress shipping;
  final String cardLast4;
  final double total;
  final int totalUnits;
  final List<OrderLine> items;
}

/// Filtros del catálogo.
class CatalogFilter {
  const CatalogFilter({
    this.q = '',
    this.category,
    this.publisher,
    this.maxPrice,
    this.inStock = false,
    this.sort = 'title',
  });

  final String q;
  final String? category;
  final String? publisher;
  final double? maxPrice;
  final bool inStock;
  final String sort;

  int get activeCount =>
      (category != null ? 1 : 0) + (publisher != null ? 1 : 0) + (maxPrice != null ? 1 : 0) + (inStock ? 1 : 0);

  CatalogFilter copyWith({
    String? q,
    String? Function()? category,
    String? Function()? publisher,
    double? Function()? maxPrice,
    bool? inStock,
    String? sort,
  }) =>
      CatalogFilter(
        q: q ?? this.q,
        category: category != null ? category() : this.category,
        publisher: publisher != null ? publisher() : this.publisher,
        maxPrice: maxPrice != null ? maxPrice() : this.maxPrice,
        inStock: inStock ?? this.inStock,
        sort: sort ?? this.sort,
      );

  Map<String, dynamic> toQuery() => {
        'q': q.trim(),
        'category': category,
        'publisher': publisher,
        'maxPrice': maxPrice,
        'inStock': inStock ? true : null,
        'sort': sort,
      };
}
