import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/theme.dart';
import '../../data/models.dart';
import '../../state/auth_cubit.dart';
import '../../state/cart_cubit.dart';
import '../catalog/manga_detail_page.dart';
import '../home_shell.dart';
import '../widgets/common.dart';
import 'checkout_page.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  Future<void> _run(BuildContext context, Future<void> Function() action) async {
    try {
      await action();
    } catch (e) {
      if (context.mounted) showMessage(context, e.toString(), error: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loggedIn = context.select((AuthCubit c) => c.state.isLoggedIn);

    return Scaffold(
      appBar: AppBar(title: const Text('Carrito')),
      body: !loggedIn
          ? const LoginRequired(
              icon: Icons.shopping_bag_outlined, message: 'Inicia sesión para añadir mangas a tu carrito.')
          : BlocBuilder<CartCubit, CartState>(
              builder: (context, state) {
                final cubit = context.read<CartCubit>();
                final cart = state.cart;
                if (state.loading && cart.items.isEmpty) return const Center(child: CircularProgressIndicator());
                if (cart.items.isEmpty) {
                  return RefreshIndicator(
                    onRefresh: () => _run(context, cubit.load),
                    child: ListView(children: [
                      const SizedBox(height: 80),
                      EmptyState(
                        icon: Icons.shopping_bag_outlined,
                        title: 'Tu carrito está vacío',
                        message: 'Añade volúmenes desde la ficha de cada manga.',
                        action: 'Explorar el catálogo',
                        onAction: () => HomeShell.goTo(context, HomeShell.tabCatalog),
                      ),
                    ]),
                  );
                }
                return ContentWidth(
                  maxWidth: 760,
                  child: Column(
                    children: [
                      Expanded(
                        child: RefreshIndicator(
                          onRefresh: () => _run(context, cubit.load),
                          child: ListView.separated(
                            padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                            itemCount: cart.items.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 10),
                            itemBuilder: (context, i) {
                              final line = cart.items[i];
                              return _CartTile(
                                line: line,
                                busy: state.busyVolume == line.volume.id,
                                onQuantity: (q) => _run(context, () => cubit.setQuantity(line.volume, q)),
                                onDelete: () => _run(context, () => cubit.remove(line.volume)),
                              );
                            },
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                        decoration: BoxDecoration(
                          color: theme.cardTheme.color,
                          border: Border(top: BorderSide(color: theme.colorScheme.outlineVariant)),
                        ),
                        child: SafeArea(
                          top: false,
                          child: Column(children: [
                            Row(children: [
                              Text('Total (${cart.totalItems} artículos)', style: theme.textTheme.titleMedium),
                              const Spacer(),
                              Text(formatPrice(cart.total),
                                  style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
                            ]),
                            const SizedBox(height: 4),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text('Envío gratis · IVA incluido',
                                  style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline)),
                            ),
                            const SizedBox(height: 14),
                            SizedBox(
                              width: double.infinity,
                              child: FilledButton.icon(
                                icon: const Icon(Icons.lock_outline),
                                label: const Text('Tramitar pedido'),
                                onPressed: () =>
                                    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const CheckoutPage())),
                              ),
                            ),
                          ]),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}

class _CartTile extends StatelessWidget {
  const _CartTile({required this.line, required this.busy, required this.onQuantity, required this.onDelete});

  final CartLine line;
  final bool busy;
  final void Function(int quantity) onQuantity;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final v = line.volume;
    final maxQuantity = v.stock.clamp(0, 20);
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => openMangaDetail(context, v.mangaId),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              CoverImage(v.coverImage, width: 60, height: 88, radius: 8),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(v.title, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                    Text('${formatPrice(v.price)} / ud.',
                        style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline)),
                    const SizedBox(height: 8),
                    Row(children: [
                      _QtyButton(
                        icon: Icons.remove,
                        tooltip: 'Quitar uno',
                        onPressed: busy ? null : () => line.quantity > 1 ? onQuantity(line.quantity - 1) : onDelete(),
                      ),
                      SizedBox(
                        width: 36,
                        child: busy
                            ? const Center(
                                child: SizedBox.square(dimension: 16, child: CircularProgressIndicator(strokeWidth: 2)))
                            : Text('${line.quantity}', textAlign: TextAlign.center, style: theme.textTheme.titleMedium),
                      ),
                      _QtyButton(
                        icon: Icons.add,
                        tooltip: 'Añadir uno',
                        onPressed: busy || line.quantity >= maxQuantity ? null : () => onQuantity(line.quantity + 1),
                      ),
                    ]),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  IconButton(
                      tooltip: 'Eliminar', icon: const Icon(Icons.delete_outline), onPressed: busy ? null : onDelete),
                  Text(formatPrice(line.subtotal),
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QtyButton extends StatelessWidget {
  const _QtyButton({required this.icon, required this.onPressed, required this.tooltip});
  final IconData icon;
  final VoidCallback? onPressed;
  final String tooltip;

  @override
  Widget build(BuildContext context) => IconButton.outlined(
        tooltip: tooltip,
        visualDensity: VisualDensity.compact,
        iconSize: 18,
        onPressed: onPressed,
        icon: Icon(icon),
      );
}
