class PurchaseResponse {
  PurchaseResponse({
    required this.content,
    required this.pageable,
    required this.totalPages,
    required this.totalElements,
    required this.last,
    required this.size,
    required this.number,
    required this.sort,
    required this.numberOfElements,
    required this.first,
    required this.empty,
  });
  late final List<Purchase> content;
  late final Pageable pageable;
  late final int totalPages;
  late final int totalElements;
  late final bool last;
  late final int size;
  late final int number;
  late final Sort sort;
  late final int numberOfElements;
  late final bool first;
  late final bool empty;
  
  PurchaseResponse.fromJson(Map<String, dynamic> json){
    content = List.from(json['content']).map((e)=>Purchase.fromJson(e)).toList();
    pageable = Pageable.fromJson(json['pageable']);
    totalPages = json['totalPages'];
    totalElements = json['totalElements'];
    last = json['last'];
    size = json['size'];
    number = json['number'];
    sort = Sort.fromJson(json['sort']);
    numberOfElements = json['numberOfElements'];
    first = json['first'];
    empty = json['empty'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['content'] = content.map((e)=>e.toJson()).toList();
    _data['pageable'] = pageable.toJson();
    _data['totalPages'] = totalPages;
    _data['totalElements'] = totalElements;
    _data['last'] = last;
    _data['size'] = size;
    _data['number'] = number;
    _data['sort'] = sort.toJson();
    _data['numberOfElements'] = numberOfElements;
    _data['first'] = first;
    _data['empty'] = empty;
    return _data;
  }
}

class Purchase {
  Purchase({
    required this.idPurchase,
    required this.numCreditCard,
    required this.idCart,
    required this.idUser,
    required this.idVolumen,
    required this.precio,
    required this.fullName,
    required this.purchaseDate,
  });
  late final String idPurchase;
  late final String numCreditCard;
  late final String idCart;
  late final String idUser;
  late final String idVolumen;
  late final double precio;
  late final String fullName;
  late final String purchaseDate;
  
  Purchase.fromJson(Map<String, dynamic> json){
    idPurchase = json['idPurchase'];
    numCreditCard = json['numCreditCard'];
    idCart = json['idCart'];
    idUser = json['idUser'];
    idVolumen = json['idVolumen'];
    precio = json['precio'];
    fullName = json['fullName'];
    purchaseDate = json['purchaseDate'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['idPurchase'] = idPurchase;
    _data['numCreditCard'] = numCreditCard;
    _data['idCart'] = idCart;
    _data['idUser'] = idUser;
    _data['idVolumen'] = idVolumen;
    _data['precio'] = precio;
    _data['fullName'] = fullName;
    _data['purchaseDate'] = purchaseDate;
    return _data;
  }
}

class Pageable {
  Pageable({
    required this.sort,
    required this.offset,
    required this.pageSize,
    required this.pageNumber,
    required this.paged,
    required this.unpaged,
  });
  late final Sort sort;
  late final int offset;
  late final int pageSize;
  late final int pageNumber;
  late final bool paged;
  late final bool unpaged;
  
  Pageable.fromJson(Map<String, dynamic> json){
    sort = Sort.fromJson(json['sort']);
    offset = json['offset'];
    pageSize = json['pageSize'];
    pageNumber = json['pageNumber'];
    paged = json['paged'];
    unpaged = json['unpaged'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['sort'] = sort.toJson();
    _data['offset'] = offset;
    _data['pageSize'] = pageSize;
    _data['pageNumber'] = pageNumber;
    _data['paged'] = paged;
    _data['unpaged'] = unpaged;
    return _data;
  }
}

class Sort {
  Sort({
    required this.empty,
    required this.unsorted,
    required this.sorted,
  });
  late final bool empty;
  late final bool unsorted;
  late final bool sorted;
  
  Sort.fromJson(Map<String, dynamic> json){
    empty = json['empty'];
    unsorted = json['unsorted'];
    sorted = json['sorted'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['empty'] = empty;
    _data['unsorted'] = unsorted;
    _data['sorted'] = sorted;
    return _data;
  }
}