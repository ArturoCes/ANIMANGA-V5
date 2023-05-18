part of 'profile_bloc.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object> get props => [];
}

class FetchUserLogged extends ProfileEvent {
  const FetchUserLogged();

  @override
  List<Object> get props => [];
}
