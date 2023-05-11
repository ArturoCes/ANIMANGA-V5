class PasswordDto {
  PasswordDto({
    required this.password,
    required this.passwordNew,
    required this.passwordNewVerify,
  });
  late final String password;
  late final String passwordNew;
  late final String passwordNewVerify;

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['password'] = password;
    _data['passwordNew'] = passwordNew;
    _data['passwordNewVerify'] = passwordNewVerify;
    return _data;
  }
}