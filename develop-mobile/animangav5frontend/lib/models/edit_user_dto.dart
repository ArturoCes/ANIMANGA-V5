class EditUserDto {
  EditUserDto({
    required this.fullName,
    required this.email,
    required this.username,
  });
  late final String fullName;
  late final String email;
  late final String username;

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['fullName'] = fullName;
    _data['email'] = email;
    _data['username'] = username;
    return _data;
  }
}
