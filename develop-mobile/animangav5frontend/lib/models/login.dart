class LoginResponse {
  LoginResponse({
    required this.id,
    required this.email,
    required this.image,
    required this.username,
    required this.fullName,
    required this.createdAt,
    required this.token,
    required this.refreshToken,
  });
  late final String id;
  late final String email;
  late final String image;
  late final String username;
  late final String fullName;

  late final String createdAt;
  late final String token;
  late final String refreshToken;
  
  LoginResponse.fromJson(Map<String, dynamic> json){
    id = json['id'];
    email = json['email'];
    image = json['image'];
    username = json['username'];
    fullName = json['fullName'];
    createdAt = json['createdAt'];
    token = json['token'];
    refreshToken = json['refreshToken'];
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
