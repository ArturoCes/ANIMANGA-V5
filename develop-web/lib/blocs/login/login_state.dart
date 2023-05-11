import 'package:equatable/equatable.dart';
import '../../models/login_error.dart';

abstract class LoginState extends Equatable {
  @override
  List<Object> get props => [];
}

class LoginInitial extends LoginState {}

class LoginLoading extends LoginState {}

class LoginSuccess extends LoginState {}

class LoginFailure extends LoginState {
  final LoginError error;

  LoginFailure({required this.error});

  @override
  List<Object> get props => [error];
}
