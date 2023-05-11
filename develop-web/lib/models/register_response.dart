class RegisterResponse {
  RegisterResponse({
    required this.id,
    required this.name,
    required this.email,
    required this.image,
    required this.username,
    required this.fullName,
    required this.createdAt,
  });
  late final String id;
  late final String name;
  late final String email;
  late final String image;
  late final String username;
  late final String fullName;
  late final String createdAt;
  
  RegisterResponse.fromJson(Map<String, dynamic> json){
    id = json['id'];
    name = json['name'];
    email = json['email'];
    image = json['image'];
    username = json['username'];
    fullName = json['fullName'];
    createdAt = json['createdAt'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['id'] = id;
    _data['name'] = name;
    _data['email'] = email;
    _data['image'] = image;
    _data['username'] = username;
    _data['fullName'] = fullName;
    _data['createdAt'] = createdAt;
    return _data;
  }
}