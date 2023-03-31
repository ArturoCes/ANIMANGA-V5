import 'package:animangav4frontend/models/errors.dart';
import 'package:animangav4frontend/models/password_dto.dart';
import 'package:animangav4frontend/models/user.dart';
import 'package:animangav4frontend/services/services.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_storage/get_storage.dart';

part 'password_event.dart';
part 'password_state.dart';

class ChangePasswordBloc
    extends Bloc<ChangePasswordEvent, ChangePasswordState> {
  final UserServiceI _userService;
  final box = GetStorage();

  ChangePasswordBloc(UserServiceI userService)
      : assert(userService != null),
        _userService = userService,
        super(ChangePasswordInitial()) {
    on<ChangePassEvent>(_changepassword);
  }

  void _changepassword(
      ChangePassEvent event, Emitter<ChangePasswordState> emit) async {
    try {
      var user = await _userService.changePassword(event.passwordDto);

      emit(ChangePasswordSuccessState(user));
    } on ErrorResponse catch (e) {
      emit(ChangePasswordErrorState(e));
    }
  }
}
