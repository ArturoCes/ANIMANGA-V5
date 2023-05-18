import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_storage/get_storage.dart';
import 'package:image_picker/image_picker.dart';

import '../../services/user_service.dart';

part 'image_event.dart';
part 'image_state.dart';

class ImagePickBloc extends Bloc<ImagePickEvent, ImagePickState> {
  final UserServiceI _userService;
  final box = GetStorage();

  ImagePickBloc(UserServiceI userService)
      : assert(userService != null),
        _userService = userService,
        super(ImagePickInitial()) {
    on<SelectImageEvent>(_onSelectImage);
  }

  void _onSelectImage(
      SelectImageEvent event, Emitter<ImagePickState> emit) async {
    final ImagePicker _picker = ImagePicker();

    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: event.source,
      );
      if (pickedFile != null) {
        final user = await _userService.uploadImage(
            pickedFile.path, box.read("idUser") ?? "",'image');
        box.write('image', user.image);
        emit(ImageSelectedSuccessState(pickedFile));
      } else {
        emit(const ImageSelectedErrorState('Error in image selection'));
      }
    } catch (e) {
      emit(const ImageSelectedErrorState('Error in image selection'));
    }
  }
}
