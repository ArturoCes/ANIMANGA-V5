part of 'cart_bloc.dart';

abstract class CartState extends Equatable {
  const CartState();

  @override
  List<Object> get props => [];
}

class CartInitial extends CartState {}

class ItemsFetched extends CartState {
  final String message;
  
  const ItemsFetched({required this.message});

  @override
  List<Object> get props => [message];

}

class ItemsToCart extends CartState {
  final List<Item> items;
  
  const ItemsToCart({required this.items});

  @override
  List<Object> get props => [items];
}

class CartIsLoading extends CartState {}

class CartFetchError extends CartState {
  final ErrorResponse error;

  const CartFetchError(this.error);

  @override
  List<Object> get props => [error];
}

class Purchased extends CartState {
  final List<Purchase> purchases;
  
  const Purchased({required this.purchases});

  @override
  List<Object> get props => [purchases];
}

class PurchasedError extends CartState {
  final ErrorResponse error;

  const PurchasedError(this.error);

  @override
  List<Object> get props => [error];
}
