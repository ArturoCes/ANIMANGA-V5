part of 'cart_bloc.dart';


abstract class CartEvent extends Equatable {
  const CartEvent();

  @override
  List<Object> get props => [];
}

class addToCart extends CartEvent {

  final String idUser;
  final String idVolumen;

  const addToCart(this.idUser, this.idVolumen);

  @override
  List<Object> get props => [idUser, idVolumen];
}

class removeFromCart extends CartEvent {

  final String idUser;
  final String idVolumen;

  const removeFromCart(this.idUser, this.idVolumen);

  @override
  List<Object> get props => [idUser, idVolumen];
}

class FetchCart extends CartEvent {

  final String idCart;

  const FetchCart(this.idCart);

  @override
  List<Object> get props => [idCart];
}

class PurchaseEvent extends CartEvent {

  final PurchaseDto purchaseDto;

  const PurchaseEvent(this.purchaseDto);

  @override
  List<Object> get props => [purchaseDto];
}