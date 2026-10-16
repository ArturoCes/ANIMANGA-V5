import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/models.dart';
import '../data/repositories.dart';

class CartState {
  const CartState({this.cart = const Cart(), this.loading = false, this.busyVolume});

  final Cart cart;
  final bool loading;

  /// Volumen con una operación en curso (para deshabilitar sus botones).
  final String? busyVolume;

  CartState copyWith({Cart? cart, bool? loading, String? busyVolume, bool clearBusy = false}) => CartState(
        cart: cart ?? this.cart,
        loading: loading ?? this.loading,
        busyVolume: clearBusy ? null : busyVolume ?? this.busyVolume,
      );
}

/// Carrito del usuario. La API devuelve el carrito completo tras cada cambio.
/// Los errores se relanzan para que la pantalla los muestre.
class CartCubit extends Cubit<CartState> {
  CartCubit(this._repo) : super(const CartState());

  final ShopRepository _repo;

  Future<void> load() async {
    emit(state.copyWith(loading: true));
    try {
      emit(CartState(cart: await _repo.cart()));
    } catch (_) {
      emit(state.copyWith(loading: false));
      rethrow;
    }
  }

  Future<void> add(Volume volume) => _mutate(volume.id, () => _repo.add(volume.id));

  Future<void> setQuantity(Volume volume, int quantity) =>
      _mutate(volume.id, () => _repo.setQuantity(volume.id, quantity));

  Future<void> remove(Volume volume) => _mutate(volume.id, () => _repo.remove(volume.id));

  /// Tras pagar, el servidor vacía el carrito.
  void cleared() => emit(const CartState());

  Future<void> _mutate(String volumeId, Future<Cart> Function() action) async {
    emit(state.copyWith(busyVolume: volumeId));
    try {
      emit(CartState(cart: await action()));
    } catch (_) {
      emit(state.copyWith(clearBusy: true));
      rethrow;
    }
  }
}
