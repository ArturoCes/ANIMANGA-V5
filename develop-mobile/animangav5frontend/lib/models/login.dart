class LoginResponse {
  LoginResponse(
      {required this.id,
      required this.email,
      required this.image,
      required this.username,
      required this.fullName,
      required this.createdAt,
      required this.token,
      required this.refreshToken,
      required this.idCart});
  late final String id;
  late final String email;
  late final String image;
  late final String username;
  late final String fullName;

  late final String createdAt;
  late final String token;
  late final String refreshToken;
  late final String idCart;

  LoginResponse.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    email = json['email'];
    image = json['image'];
    username = json['username'];
    fullName = json['fullName'];
    createdAt = json['createdAt'];
    token = json['token'];
    refreshToken = json['refreshToken'];
    idCart = json['idCart'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['id'] = id;
    _data['email'] = email;
    _data['image'] = image;
    _data['username'] = username;
    _data['fullName'] = fullName;
    _data['createdAt'] = createdAt;
    _data['token'] = token;
    _data['refreshToken'] = refreshToken;
    _data['idCart'] = idCart;
    return _data;
  }
}

class LoginRequest {
  String? username;
  String? password;

  LoginRequest({this.username, this.password});

  LoginRequest.fromJson(Map<String, dynamic> json) {
    username = json['username'];
    password = json['password'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['username'] = username;
    data['password'] = password;
    return data;
  }
}
