part of 'register_bloc.dart';

abstract class RegisterEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class RegisterWithUsernameButtonPressed extends RegisterEvent {
  final RegisterDto registerDto;

  RegisterWithUsernameButtonPressed(this.registerDto);
}
