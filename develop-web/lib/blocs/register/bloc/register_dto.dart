class RegisterDto{
  RegisterDto({
    required this.username,
    required this.password,
    required this.verifyPassword,
    required this.email,
    required this.fullName
  });
  late final String username;
  late final String password;
  late final String verifyPassword;
  late final String email;
  late final String fullName;

  Map<String,dynamic>toJson(){
    final _data= <String, dynamic>{};
    _data['username'] = username;
    _data['password']= password;
    _data['verifyPassword'] = verifyPassword;
    _data['email']= email;
    _data['fullName']= fullName;
    return _data;
  }
}