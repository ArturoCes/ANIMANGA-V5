import 'package:animangav4frontend/models/errors.dart';
import 'package:animangav4frontend/models/purchaseResponse.dart';
import 'package:animangav4frontend/services/services.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../models/cart.dart';
import '../../models/purchaseDto.dart';

part 'cart_event.dart';
part 'cart_state.dart';

class CartBloc extends Bloc<CartEvent, CartState> {
  final UserService _userService;

  CartBloc(UserService userService)
      : assert(userService != null),
        _userService = userService,
        super(CartInitial()) {
    on<addToCart>(_addItem);
    on<removeFromCart>(_removeItem);
    on<FetchCart>(_findAllVolumes);
    on<PurchaseEvent>(_purchase);
  }
  void _addItem(addToCart event, Emitter<CartState> emit) async {
    try {
      var message =
          await _userService.addVolumenToCart(event.idUser, event.idVolumen);
      emit(ItemsFetched(message: message));
    } on ErrorResponse catch (e) {
      emit(CartFetchError(e));
    }
  }

  void _removeItem(removeFromCart event, Emitter<CartState> emit) async {
    try {
      var message = await _userService.removeVolumenFromCart(
          event.idUser, event.idVolumen);
      emit(ItemsFetched(message: message));
    } on ErrorResponse catch (e) {
      emit(CartFetchError(e));
    }
  }
 void _findAllVolumes(FetchCart event, Emitter<CartState> emit) async {
    try {
      var cartResponse = await _userService.findAllVolumesFromCart(event.idCart);
         
      emit(ItemsToCart(items: cartResponse.content));
    } on ErrorResponse catch (e) {
      emit(CartFetchError(e));
    }
  }

   void _purchase(PurchaseEvent event, Emitter<CartState> emit) async {
    try {
      var purchases = await _userService.purchase(event.purchaseDto);
      emit(Purchased(purchases: purchases.content));
    } on ErrorResponse catch (e) {
      emit(PurchasedError(e));
    }
  }
}
