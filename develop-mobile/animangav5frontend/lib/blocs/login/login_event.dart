import 'package:equatable/equatable.dart';

import 'login_dto.dart';

abstract class LoginEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class LoginInWithUsernameButtonPressed extends LoginEvent {
  final LoginDto loginDto;

  LoginInWithUsernameButtonPressed(this.loginDto);
}
