part of 'profile_bloc.dart';

abstract class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object> get props => [];
}

class ProfileInitial extends ProfileState {}

class UserLoggedFetched extends ProfileState {
  final User userLogged;

  const UserLoggedFetched(this.userLogged);

  @override
  List<Object> get props => [userLogged];
}

class UserLoggedFetchError extends ProfileState {
  final String message;
  const UserLoggedFetchError(this.message);

  @override
  List<Object> get props => [message];
}
