import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/models.dart';
import '../data/repositories.dart';

class CartState {
  const CartState({this.items = const [], this.loading = false, this.busyVolumen});

  final List<CartItem> items;
  final bool loading;

  /// Volumen sobre el que hay una operación en curso (para deshabilitar botones).
  final String? busyVolumen;

  int get count => items.fold(0, (sum, i) => sum + i.quantity);
  double get total => items.fold(0, (sum, i) => sum + i.subtotal);

  int quantityOf(String volumenId) =>
      items.where((i) => i.volumen.id == volumenId).fold(0, (sum, i) => sum + i.quantity);

  CartState copyWith({List<CartItem>? items, bool? loading, String? busyVolumen, bool clearBusy = false}) => CartState(
        items: items ?? this.items,
        loading: loading ?? this.loading,
        busyVolumen: clearBusy ? null : busyVolumen ?? this.busyVolumen,
      );
}

/// Carrito del usuario autenticado. Los errores se relanzan para que la UI los muestre.
class CartCubit extends Cubit<CartState> {
  CartCubit(this._repo, this._user) : super(const CartState());

  final ShopRepository _repo;
  final User _user;

  Future<void> load() async {
    emit(state.copyWith(loading: true));
    try {
      emit(CartState(items: await _repo.cart(_user.idCart)));
    } catch (_) {
      emit(state.copyWith(loading: false));
      rethrow;
    }
  }

  Future<void> add(Volumen volumen) => _mutate(volumen.id, () => _repo.addToCart(_user.id, volumen.id));

  Future<void> removeOne(Volumen volumen) => _mutate(volumen.id, () => _repo.removeOne(_user.id, volumen.id));

  Future<void> removeAll(CartItem item) => _mutate(item.volumen.id, () async {
        for (var i = 0; i < item.quantity; i++) {
          await _repo.removeOne(_user.id, item.volumen.id);
        }
      });

  Future<void> checkout(String cardNumber) async {
    await _repo.checkout(_user.idCart, cardNumber);
    emit(const CartState());
  }

  Future<void> _mutate(String volumenId, Future<void> Function() action) async {
    emit(state.copyWith(busyVolumen: volumenId));
    try {
      await action();
      emit(CartState(items: await _repo.cart(_user.idCart)));
    } catch (_) {
      emit(state.copyWith(clearBusy: true));
      rethrow;
    }
  }
}
