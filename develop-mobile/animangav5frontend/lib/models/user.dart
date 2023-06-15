class User {
  User({
    required this.id,
    required this.image,
    required this.username,
    required this.fullName,
    required this.email,
    required this.createdAt,
    required this.idCart
  });
  late final String id;
  late final String image;
  late final String username;
  late final String fullName;
  late final String email;
  late final String createdAt;
  late final String idCart;

  User.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    image = json['image'];
    username = json['username'];
    fullName = json['fullName'];
    email = json['email'];
    createdAt = json['createdAt'];
    idCart = json['idCart'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['id'] = id;
    _data['image'] = image;
    _data['username'] = username;
    _data['fullName'] = fullName;
    _data['email'] = email;
    _data['createdAt'] = createdAt;
    _data['idCart'] = idCart;
    return _data;
  }
}
