part of 'edit_bloc.dart';

abstract class EditUserState extends Equatable {
  const EditUserState();

  @override
  List<Object> get props => [];
}

class EditUserInitial extends EditUserState {}

class EditUserSuccessState extends EditUserState {
  final User user;

  const EditUserSuccessState(this.user);

  @override
  List<Object> get props => [user];
}

class EditUserErrorState extends EditUserState {
  final ErrorResponse error;

  const EditUserErrorState(this.error);

  @override
  List<Object> get props => [error];
}
