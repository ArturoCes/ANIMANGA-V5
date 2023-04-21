class LoginDto {
  LoginDto({
    required this.username,
    required this.password,
  });
  late final String username;
  late final String password;

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['username'] = username;
    _data['password'] = password;
    return _data;
  }
}