import 'package:animangav4frontend/models/cart.dart';
import 'package:animangav4frontend/models/edit_user_dto.dart';
import 'package:animangav4frontend/models/password_dto.dart';
import 'package:animangav4frontend/models/purchaseResponse.dart';
import 'package:animangav4frontend/models/user.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import '../models/purchaseDto.dart';
import '../repositories/user_repository.dart';

abstract class UserServiceI {
  Future<User> uploadImage(String filename, String id, String tipo);
  Future<User> userLogged();
  Future<dynamic> edit(EditUserDto editUserDto);
  Future<dynamic> changePassword(PasswordDto passwordDto);
  Future<dynamic> addVolumenToCart(String idUser, String idVolumen);
  Future<dynamic> removeVolumenFromCart(String idUser, String idVolumen);
  Future<dynamic> findAllVolumesFromCart(String idCart);
  Future<PurchaseResponse> purchase(PurchaseDto purchaseDto);
}

@Order(6)
@singleton
class UserService extends UserServiceI {
  late UserRepository _userRepository;

  UserService() {
    _userRepository = GetIt.I.get<UserRepository>();
  }

  @override
  Future<User> uploadImage(String filename, String id, String tipo) async {
    dynamic response = await _userRepository.uploadImage(filename, id, tipo);
    return response;
  }

  @override
  Future<User> userLogged() async {
    dynamic response = await _userRepository.userLogged();
    if (response != null) {
      return response;
    } else {
      throw Exception("Upss, algo ha salido mal");
    }
  }

  @override
  Future<User> edit(EditUserDto editUserDto) async {
    dynamic response = await _userRepository.edit(editUserDto);
    return response;
  }

  @override
  Future<User> changePassword(PasswordDto passwordDto) async {
    dynamic response = await _userRepository.editPassword(passwordDto);
    return response;
  }

  @override
  Future<dynamic> addVolumenToCart(String idUser, String idVolumen) async {
    dynamic response =
        await _userRepository.addVolumenToCart(idUser, idVolumen);
    return response;
  }

  @override
  Future<dynamic> removeVolumenFromCart(String idUser, String idVolumen) async {
    dynamic response =
        await _userRepository.addVolumenToCart(idUser, idVolumen);
    return response;
  }

  @override
  Future<CartResponse> findAllVolumesFromCart(String idCart) async {
    dynamic response = await _userRepository.findAllVolumesFromCart(idCart);
    return response;
  }

  @override
  Future<PurchaseResponse> purchase(PurchaseDto purchaseDto) async {
    dynamic response = await _userRepository.purchase(purchaseDto);
    return response;
  }
}
