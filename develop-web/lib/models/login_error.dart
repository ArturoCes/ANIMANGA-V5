class LoginError {
  LoginError({
    required this.status,
    required this.message,
    required this.path,
    required this.dateTime,
  });
  late final String status;
  late final String message;
  late final String path;
  late final String dateTime;
  
  LoginError.fromJson(Map<String, dynamic> json){
    status = json['status'];
    message = json['message'];
    path = json['path'];
    dateTime = json['dateTime'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['status'] = status;
    _data['message'] = message;
    _data['path'] = path;
    _data['dateTime'] = dateTime;
    return _data;
  }
}