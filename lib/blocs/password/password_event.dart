part of 'password_bloc.dart';

abstract class ChangePasswordEvent extends Equatable {
  const ChangePasswordEvent();

  @override
  List<Object> get props => [];
}

class  ChangePassEvent extends ChangePasswordEvent {
  final PasswordDto passwordDto;

  const ChangePassEvent(this.passwordDto);

  @override
  List<Object> get props => [passwordDto];
}