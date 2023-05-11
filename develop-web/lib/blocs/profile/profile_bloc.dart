import 'package:animangav4frontend/models/user.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../services/user_service.dart';

part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final UserServiceI userService;

  ProfileBloc(this.userService) : super(ProfileInitial()) {
    on<FetchUserLogged>(_userLoggedFetched);
  }

  void _userLoggedFetched(
      FetchUserLogged event, Emitter<ProfileState> emit) async {
    try {
      final userLogged = await userService.userLogged();
      emit(UserLoggedFetched(userLogged));
      return;
    } on Exception catch (e) {
      emit(UserLoggedFetchError(e.toString()));
    }
  }
}
