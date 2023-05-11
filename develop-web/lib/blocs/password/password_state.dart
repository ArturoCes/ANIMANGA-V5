part of 'password_bloc.dart';

abstract class ChangePasswordState extends Equatable {
  const ChangePasswordState();
  
  @override
  List<Object> get props => [];
}

class ChangePasswordInitial extends ChangePasswordState {}

class ChangePasswordSuccessState extends ChangePasswordState {
  final User user;

  const ChangePasswordSuccessState( this.user);

  @override
  List<Object> get props => [user];
}

class ChangePasswordErrorState extends ChangePasswordState {
  final ErrorResponse error;

  const ChangePasswordErrorState(this.error);

  @override
  List<Object> get props => [error];
}